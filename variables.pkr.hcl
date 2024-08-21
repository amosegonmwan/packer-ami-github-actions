variable "region" {
  type    = string
  default = "us-west-2"
}

variable "ami_prefix" {
  type    = string
  default = "my-ubuntu-gitactions"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ami_regions" {
  type    = list(string)
  default = ["us-west-2", "us-east-1", "us-west-1"]
}

variable "tags" {
  type = map(string)
  default = {
    "Name"        = "Ubuntu-AMI"
    "Environment" = "Development"
    "OS_Version"  = "Ubuntu 22.04"
    "Release"     = "Latest"
    "Created-by"  = "Packer"
  }
}