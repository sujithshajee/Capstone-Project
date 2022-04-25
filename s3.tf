####################################################################################################
# Provision S3 bucket
####################################################################################################

resource "random_id" "tc-rmstate" {
  byte_length = 2
}

resource "aws_s3_bucket" "terraform_remote_state" {
  bucket = "tc-remotestate-${random_id.tc-rmstate.dec}"
}
