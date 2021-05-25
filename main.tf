locals {
  key_name = "test"
  key_path = "test.pem"
}

resource "aws_instance" "user" {
  # aws_spot_instabce_request for spot instance
  ami = data.aws_ami.ami.id
  instance_type = "${var.INSTANCE_TYPE}"
  #key_name = local.key_name
  # spot_type = "one-time"  aws_spot_instance_request
  tags = {
    "Name" = "${var.COMPONENT}-Server"
  }

connection {
  host = aws_instance.user.public_ip
  type = "ssh"
  #private_key = file("${local.key_path}") read private_key (PEM) from file
  user = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)["SSH_USER"]
  password = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)["SSH_PASS"]
}

provisioner "remote-exec" {
  inline = [ "set-hostname ${var.COMPONENT}" ]
}

provisioner "local-exec" {
  command = "echo ${aws_instance.user.public_ip} > user_inv"
  #command = "ansible-playbook -i ${aws_instance.user.public_ip}, --private-key ${local.key_path} ${var.COMPONENT}.yml"
  #echo $IP component=${component} ansible_user=root ansible_password=DevOps321 >>inv
}
}

resource "aws_route53_record" "jithendar" {
  name          = "${var.COMPONENT}.${data.aws_route53_zone.jithendar.name}"
  type          = "A"
  ttl           = "300"
  zone_id       = data.aws_route53_zone.jithendar.zone_id
  records       = [aws_instance.user.public_ip]
}