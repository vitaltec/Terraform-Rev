
# We are not done with this project yet.
# We still have to create a bucket policy for the bucket.
# We need to add more permissions to the  kms key.
# and a lot more.



# Creating a bucket with encryption
# The name of the bucket.The name must be globally unique. You have to provide
# the name of the bucket in the terraform.tfvars file create one if you don't have one.
# The `bucket_name` variable is defined in the `variable.tf` file.
resource "aws_s3_bucket" "data_team_bucket" {

  bucket = var.bucket_name   
  acl    = "private"  
  server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                kms_master_key_id = aws_kms_key.mykey.arn
                sse_algorithm     = "aws:kms"
            }
      }
  }

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
    Terraform = true    
  }
   

}


# creating the kms key
resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  enable_key_rotation = true
  policy = data.aws_iam_policy_document.key_policy.json
}

# This block of code allows the user to get the accout id of the current user dynamically.
# The aws_caller_identity has a property called account_id which is used to get the account id of the current user.
data "aws_caller_identity" "current"{}

# This block of code is used to create the key policy.
# This key policy grants the root user access to the kms key with full access.

# "${data.aws_caller_identity.current.account_id}" is a variable that is used to get the account id of the current user.

# We are using string interpolation place the account id in the arn we are forming for the root user.
# This makes the code dynamic and will work with any account
data "aws_iam_policy_document" "key_policy" {
 statement {
   sid = "allow root access to this key"
   effect = "Allow"
   principals {
       type ="AWS"
       identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"] 
   }
   actions = ["kms:*"]
   resources = ["*"]
 }
   
}
