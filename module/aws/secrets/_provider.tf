# Aliased Regions
provider "aws" {
  alias   = "us-east-1"
  profile = "saml"
  region  = "us-east-1"
}

provider "aws" {
  alias   = "us-east-2"
  profile = "saml"
  region  = "us-east-2"
}

provider "aws" {
  alias   = "us-west-1"
  profile = "saml"
  region  = "us-west-1"
}

provider "aws" {
  alias   = "us-west-2"
  profile = "saml"
  region  = "us-west-2"
}
