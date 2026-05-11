variable "role_name" {
  type        = string
  description = "name of the role"
}
variable "assume_role_policy" {
  type        = string
  description = "assume role policy"
}
variable "policy_arns" {
  type        = list(string)
  description = "list of policy ARNs to attach to the role"
}
variable "tags" {
  type        = map(string)
  default     = {}
  description = "tags to apply to the role"
}
variable "max_session_duration" {
  type        = number
  default     = null
  description = "Maximum session duration (in seconds) for the role. If not set, AWS default (3600 seconds) will be used"
}
