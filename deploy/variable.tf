variable "dax_subnet_ids" {
  description = "daxが生成したvpcのサブネットID。まずdaxを作って、マネコンで確認して入れる。"
  type        = list(string)
}

variable "dax_security_group_ids" {
  description = "daxが生成したvpcのデフォルトsg_id。まずdaxを作って、マネコンで確認して入れる。"
  type        = list(string)
}
