####################################################################################################
# Provision S3 bucket
####################################################################################################

resource "random_id" "tc-rmstate" {
  byte_length = 2
}

resource "aws_s3_bucket" "terraform_remote_state" {
  bucket = "tc-remotestate-${random_id.tc-rmstate.dec}"
}

resource "aws_dynamodb_table" "terraform_statelock" {
  name           = "tc-remotestate-dynamodb-table"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
