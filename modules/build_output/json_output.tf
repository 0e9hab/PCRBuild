data "aws_organizations_organization" "current" {}

data "azurerm_subscription" "current" {}

locals {
  RelationshipToMaster = data.aws_organizations_organization.current.master_account_id
  Email = var.member_account_owner_email
  S3AuditBucket = var.central_audit_bucket
  Name = var.member_account_name
  RelationshipToTooling = var.vod_tooling_account_id
  Id = var.member_account
  entitlement_id = data.azurerm_subscription.current.subscription_id

}

resource "local_file" "build_output" {
  filename = "${path.cwd}/${var.member_account}.json"
  content = templatefile("${path.module}/build_output.tmpl", { "RelationshipToMaster" = local.RelationshipToMaster, "Email" = local.Email, "S3AuditBucket" = local.S3AuditBucket, "Name" = local.Name, "RelationshipToTooling" = local.RelationshipToTooling, "Id" = local.Id } )
}

output "json_output" {
  value = templatefile("${path.module}/build_output.tmpl", { "RelationshipToMaster" = local.RelationshipToMaster, "Email" = local.Email, "S3AuditBucket" = local.S3AuditBucket, "Name" = local.Name, "RelationshipToTooling" = local.RelationshipToTooling, "Id" = local.Id, "entitlement_id" = local.entitlement_id } )
}