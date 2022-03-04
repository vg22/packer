#This file was genereated using ```hcl2_upgrade``` using the command "packer hcl2_upgrade packer.json" 
# AWS Keys are expected to be exported in the user profile and areNOT supposed to be added in the repository
variable "aws_subnet_id" {
  type    = string
  default = "subnet-0c729cd36e675fd81" #needs to be updated as per your subnet
}

data "amazon-ami" "httpd-webserver" {
  filters = {
    name                = "amzn2-ami-hvm-2.0.*-gp2"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["amazon"]
  region      = "us-east-1"
}

source "amazon-ebs" "httpd-webserver" {
  ami_description       = "Landing page for website"
  ami_name              = "demo-httpd-site"
  force_delete_snapshot = true
  force_deregister      = true
  instance_type         = "t3.micro"
  region                = "us-east-1"
  security_group_filter {
    filters = {
      "tag:Class" = "packer"
    }
  }
  source_ami   = "${data.amazon-ami.httpd-webserver.id}"
  ssh_username = "ec2-user"
  subnet_id    = "${var.aws_subnet_id}"
  tags = {
    Builder = "Packer"
    Role    = "Web"
    Team    = "Frontend"
  }
}

build {
  sources = ["source.amazon-ebs.httpd-webserver"]

  provisioner "shell" {
    inline = ["sudo mkdir -p /var/www/html", "sudo chown ec2-user:ec2-user /var/www/html"]
  }

  provisioner "file" {
    destination = "/var/www/html/"
    source      = "website/"
  }

  provisioner "shell" {
    script = "deploy.sh"
  }

}