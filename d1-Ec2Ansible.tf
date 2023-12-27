

                                                        ## Burasi Ansible Ec2 user datayi degistirmek icin
                                                            # private_ip_value = aws_instance.example.private_ip
                                                            # private_key_content = local.my_private_key_content

data "template_file" "user_data_template" {
  template = file("./s3_Website/ansible_userdata.sh")
  vars = {
    pem_key = var.user_name
  }
}

resource "aws_instance" "ornek" {
  ami           = "ami-0fa1ca9559f1892ec"  # Örnek bir Amazon Linux AMI ID'si
  instance_type = "t2.micro"
  key_name      = var.user_name  # Kullanmak istediğiniz key pair'ın adı
  user_data = data.template_file.user_data_template.rendered
  associate_public_ip_address = true
  subnet_id     = aws_subnet.proje2_private_subnet[0].id
  vpc_security_group_ids = [aws_security_group.proje2_EC2_Sec_Group.id]

  tags = {
    Name = "Ansible-instance"
  }
}
