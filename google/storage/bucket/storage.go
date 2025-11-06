package bucket

import (
	"context"
	"errors"
	"fmt"
	"io"
	"mime"
	"net/http"
	"path/filepath"
	"time"

	"cloud.google.com/go/storage"
	"golang.org/x/oauth2/google"
	"google.golang.org/api/googleapi"
	"google.golang.org/api/iamcredentials/v1"
	"google.golang.org/api/iterator"
	"google.golang.org/api/option"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"

	storagepb "github.com/nitrictech/suga/proto/storage/v2"
	sugaStorage "github.com/nitrictech/suga/runtime/storage"
)

type gcsStorage struct {
	storagepb.UnimplementedStorageServer
	projectID string
	client    *storage.Client
}

var _ storagepb.StorageServer = &gcsStorage{}

// isPermissionDenied returns true if the given error is a Google API error with a StatusForbidden code
func isPermissionDenied(err error) bool {
	var ee *googleapi.Error
	if errors.As(err, &ee) {
		return ee.Code == http.StatusForbidden
	}
	return false
}

// detectContentType detects the content type of a file based on its extension or content
func detectContentType(filename string, content []byte) string {
	contentType := mime.TypeByExtension(filepath.Ext(filename))
	if contentType != "" {
		return contentType
	}
	return http.DetectContentType(content)
}

// Read retrieves an object from a GCS bucket
func (s *gcsStorage) Read(ctx context.Context, req *storagepb.StorageReadRequest) (*storagepb.StorageReadResponse, error) {
	bucket := s.client.Bucket(req.BucketName)
	obj := bucket.Object(req.Key)

	reader, err := obj.NewReader(ctx)
	if err != nil {
		if errors.Is(err, storage.ErrObjectNotExist) {
			return nil, status.Errorf(codes.NotFound, "object not found: %s", req.Key)
		}
		if isPermissionDenied(err) {
			return nil, status.Errorf(codes.PermissionDenied, "permission denied reading object")
		}
		return nil, status.Errorf(codes.Unknown, "error reading object: %v", err)
	}
	defer reader.Close()

	body, err := io.ReadAll(reader)
	if err != nil {
		return nil, status.Errorf(codes.Unknown, "error reading object content: %v", err)
	}

	return &storagepb.StorageReadResponse{
		Body: body,
	}, nil
}

// Write stores an object in a GCS bucket
func (s *gcsStorage) Write(ctx context.Context, req *storagepb.StorageWriteRequest) (*storagepb.StorageWriteResponse, error) {
	bucket := s.client.Bucket(req.BucketName)
	obj := bucket.Object(req.Key)

	writer := obj.NewWriter(ctx)
	writer.ContentType = detectContentType(req.Key, req.Body)

	if _, err := writer.Write(req.Body); err != nil {
		writer.Close()
		if isPermissionDenied(err) {
			return nil, status.Errorf(codes.PermissionDenied, "permission denied writing object")
		}
		return nil, status.Errorf(codes.Unknown, "error writing object: %v", err)
	}

	if err := writer.Close(); err != nil {
		if isPermissionDenied(err) {
			return nil, status.Errorf(codes.PermissionDenied, "permission denied writing object")
		}
		return nil, status.Errorf(codes.Unknown, "error closing writer: %v", err)
	}

	return &storagepb.StorageWriteResponse{}, nil
}

// Delete removes an object from a GCS bucket
func (s *gcsStorage) Delete(ctx context.Context, req *storagepb.StorageDeleteRequest) (*storagepb.StorageDeleteResponse, error) {
	bucket := s.client.Bucket(req.BucketName)
	obj := bucket.Object(req.Key)

	if err := obj.Delete(ctx); err != nil {
		if errors.Is(err, storage.ErrObjectNotExist) {
			return nil, status.Errorf(codes.NotFound, "object not found: %s", req.Key)
		}
		if isPermissionDenied(err) {
			return nil, status.Errorf(codes.PermissionDenied, "permission denied deleting object")
		}
		return nil, status.Errorf(codes.Unknown, "error deleting object: %v", err)
	}

	return &storagepb.StorageDeleteResponse{}, nil
}

// PreSignUrl generates a signed URL for temporary access to an object
func (s *gcsStorage) PreSignUrl(ctx context.Context, req *storagepb.StoragePreSignUrlRequest) (*storagepb.StoragePreSignUrlResponse, error) {
	bucket := s.client.Bucket(req.BucketName)

	// Set expiry based on request or default to 15 minutes
	expiry := time.Now().Add(15 * time.Minute)
	if req.Expiry != nil {
		expiry = time.Now().Add(req.Expiry.AsDuration())
	}

	// Determine HTTP method based on operation
	method := "GET"
	if req.Operation == storagepb.StoragePreSignUrlRequest_WRITE {
		method = "PUT"
	}

	opts := &storage.SignedURLOptions{
		Method:  method,
		Expires: expiry,
		Scheme:  storage.SigningSchemeV4,
	}

	url, err := bucket.SignedURL(req.Key, opts)
	if err != nil {
		if isPermissionDenied(err) {
			return nil, status.Errorf(codes.PermissionDenied, "permission denied generating signed URL")
		}
		return nil, status.Errorf(codes.Unknown, "error generating signed URL: %v", err)
	}

	return &storagepb.StoragePreSignUrlResponse{
		Url: url,
	}, nil
}

// ListBlobs lists objects in a GCS bucket
func (s *gcsStorage) ListBlobs(ctx context.Context, req *storagepb.StorageListBlobsRequest) (*storagepb.StorageListBlobsResponse, error) {
	bucket := s.client.Bucket(req.BucketName)

	query := &storage.Query{
		Prefix: req.Prefix,
	}

	iter := bucket.Objects(ctx, query)
	var blobs []*storagepb.Blob

	for {
		obj, err := iter.Next()
		if errors.Is(err, iterator.Done) {
			break
		}
		if err != nil {
			if isPermissionDenied(err) {
				return nil, status.Errorf(codes.PermissionDenied, "permission denied listing objects")
			}
			return nil, status.Errorf(codes.Unknown, "error listing objects: %v", err)
		}

		blobs = append(blobs, &storagepb.Blob{
			Key: obj.Name,
		})
	}

	return &storagepb.StorageListBlobsResponse{
		Blobs: blobs,
	}, nil
}

// Exists checks if an object exists in a GCS bucket
func (s *gcsStorage) Exists(ctx context.Context, req *storagepb.StorageExistsRequest) (*storagepb.StorageExistsResponse, error) {
	bucket := s.client.Bucket(req.BucketName)
	obj := bucket.Object(req.Key)

	_, err := obj.Attrs(ctx)
	if errors.Is(err, storage.ErrObjectNotExist) {
		return &storagepb.StorageExistsResponse{
			Exists: false,
		}, nil
	}
	if err != nil {
		if isPermissionDenied(err) {
			return nil, status.Errorf(codes.PermissionDenied, "permission denied checking object existence")
		}
		return nil, status.Errorf(codes.Unknown, "error checking object existence: %v", err)
	}

	return &storagepb.StorageExistsResponse{
		Exists: true,
	}, nil
}

// Plugin creates a new storage plugin for GCS
func Plugin() (sugaStorage.Storage, error) {
	ctx := context.Background()

	credentials, err := google.FindDefaultCredentials(ctx,
		storage.ScopeReadWrite,
		iamcredentials.CloudPlatformScope,
	)
	if err != nil {
		return nil, fmt.Errorf("GCP credentials error: %w", err)
	}

	client, err := storage.NewClient(ctx, option.WithCredentials(credentials))
	if err != nil {
		return nil, fmt.Errorf("storage client error: %w", err)
	}

	return &gcsStorage{
		client:    client,
		projectID: credentials.ProjectID,
	}, nil
}
