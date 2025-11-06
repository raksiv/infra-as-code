variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "dataset_id" {
  description = "Unique ID for the dataset being provisioned"
  type        = string
}

variable "dataset_name" {
  description = "Friendly name for the dataset being provisioned"
  type        = string
  default     = null
}

variable "description" {
  description = "Dataset description"
  type        = string
  default     = null
}

variable "location" {
  description = "The regional location for the dataset"
  type        = string
  default     = "US"
}

variable "default_table_expiration_ms" {
  description = "Default TTL for tables in milliseconds"
  type        = number
  default     = null
}

variable "delete_contents_on_destroy" {
  description = "If set to true, delete all the tables in the dataset when destroying the resource"
  type        = bool
  default     = false
}

variable "dataset_labels" {
  description = "Key-value pairs to apply to the dataset"
  type        = map(string)
  default     = {}
}

variable "tables" {
  description = "List of tables to create in the dataset"
  type = list(object({
    table_id           = string
    schema             = string
    clustering         = optional(list(string))
    time_partitioning  = optional(object({
      type                     = string
      field                    = optional(string)
      require_partition_filter = optional(bool)
      expiration_ms            = optional(number)
    }))
    range_partitioning = optional(object({
      field = string
      range = object({
        start    = number
        end      = number
        interval = number
      })
    }))
    expiration_time            = optional(number)
    labels                     = optional(map(string))
  }))
  default = []
}

variable "views" {
  description = "List of views to create in the dataset"
  type = list(object({
    view_id        = string
    query          = string
    use_legacy_sql = optional(bool)
    labels         = optional(map(string))
  }))
  default = []
}

variable "external_tables" {
  description = "List of external tables to create"
  type = list(object({
    table_id              = string
    autodetect            = optional(bool)
    compression           = optional(string)
    ignore_unknown_values = optional(bool)
    max_bad_records       = optional(number)
    schema                = optional(string)
    source_format         = string
    source_uris           = list(string)
    csv_options = optional(object({
      quote                 = string
      allow_jagged_rows     = optional(bool)
      allow_quoted_newlines = optional(bool)
      encoding              = optional(string)
      field_delimiter       = optional(string)
      skip_leading_rows     = optional(number)
    }))
    google_sheets_options = optional(object({
      range             = optional(string)
      skip_leading_rows = optional(number)
    }))
    hive_partitioning_options = optional(object({
      mode              = optional(string)
      source_uri_prefix = optional(string)
    }))
    labels = optional(map(string))
  }))
  default = []
}

variable "routines" {
  description = "List of routines to create in the dataset"
  type = list(object({
    routine_id      = string
    routine_type    = string
    language        = string
    definition_body = string
    description     = optional(string)
    arguments = optional(list(object({
      name          = string
      argument_kind = optional(string)
      mode          = optional(string)
      data_type     = string
    })))
    return_type = optional(string)
  }))
  default = []
}

variable "access" {
  description = "Access controls on the dataset"
  type = list(object({
    role          = optional(string)
    user_by_email = optional(string)
    group_by_email = optional(string)
    domain         = optional(string)
    special_group  = optional(string)
    iam_member     = optional(string)
    view = optional(object({
      project_id = string
      dataset_id = string
      table_id   = string
    }))
    dataset = optional(object({
      dataset = object({
        project_id = string
        dataset_id = string
      })
      target_types = list(string)
    }))
    routine = optional(object({
      project_id = string
      dataset_id = string
      routine_id = string
    }))
  }))
  default = []
}
