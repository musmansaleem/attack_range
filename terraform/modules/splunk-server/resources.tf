

data "aws_ami" "latest-ubuntu" {
  count = var.use_packer_amis ? 0 : 1
  most_recent = true
  owners = ["099720109477"] # Canonical

  filter {
      name   = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }
}

resource "aws_instance" "splunk-server" {
  count = var.use_packer_amis ? 0 : 1
  ami           = data.aws_ami.latest-ubuntu[count.index].id
  instance_type = "t2.2xlarge"
  key_name = var.key_name
  subnet_id = var.vpc_subnet_id
  vpc_security_group_ids = [var.vpc_security_group_ids]
  private_ip = var.splunk_server_private_ip
  depends_on = [var.phantom_server_instance]
  root_block_device {
    volume_type = "gp2"
    volume_size = "30"
    delete_on_termination = "true"
  }
  tags = {
    Name = "attack-range-splunk-server"
  }

  provisioner "remote-exec" {
    inline = ["echo booted"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.splunk-server[count.index].public_ip
      private_key = file(var.private_key_path)
    }
  }

  provisioner "local-exec" {
    working_dir = "../ansible"
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu --private-key ${var.private_key_path} -i '${aws_instance.splunk-server[count.index].public_ip},' playbooks/splunk_server.yml -e 'ansible_python_interpreter=/usr/bin/python3 splunk_admin_password=${var.splunk_admin_password} splunk_url=${var.splunk_url} splunk_binary=${var.splunk_binary} s3_bucket_url=${var.s3_bucket_url} splunk_escu_app=${var.splunk_escu_app} splunk_asx_app=${var.splunk_asx_app} splunk_windows_ta=${var.splunk_windows_ta} splunk_cim_app=${var.splunk_cim_app} splunk_sysmon_ta=${var.splunk_sysmon_ta} splunk_python_app=${var.splunk_python_app} splunk_mltk_app=${var.splunk_mltk_app} splunk_bots_dataset=${var.splunk_bots_dataset} caldera_password=${var.caldera_password} install_es=${var.install_es} splunk_es_app=${var.splunk_es_app} phantom_app=${var.phantom_app} phantom_server=${var.phantom_server} phantom_server_private_ip=${var.phantom_server_private_ip} phantom_admin_password=${var.phantom_admin_password} splunk_security_essentials_app=${var.splunk_security_essentials_app} punchard_custom_visualization=${var.punchard_custom_visualization} status_indicator_custom_visualization=${var.status_indicator_custom_visualization} splunk_attack_range_dashboard=${var.splunk_attack_range_dashboard} timeline_custom_visualization=${var.timeline_custom_visualization} install_mission_control=${var.install_mission_control} mission_control_app=${var.mission_control_app} install_dsp=${var.install_dsp} dsp_client_cert_path=${var.dsp_client_cert_path} dsp_node=${var.dsp_node} splunk_stream_app=${var.splunk_stream_app} splunk_server_private_ip=${var.splunk_server_private_ip} install_mltk=${var.install_mltk}'"
  }
}

resource "aws_eip" "splunk_ip" {
  count = var.use_packer_amis ? 0 : 1
  instance = aws_instance.splunk-server[count.index].id
}


#### packer ####

data "aws_ami" "splunk-ami-packer" {
  count = var.use_packer_amis ? 1 : 0
  owners       = ["self"]

  filter {
    name   = "name"
    values = [var.splunk_packer_ami]
  }

  most_recent = true
}


resource "aws_instance" "splunk-server-packer" {
  count = var.use_packer_amis ? 1 : 0
  ami           = data.aws_ami.splunk-ami-packer[count.index].id
  instance_type = "t2.2xlarge"
  key_name = var.key_name
  subnet_id = var.vpc_subnet_id
  vpc_security_group_ids = [var.vpc_security_group_ids]
  private_ip = var.splunk_server_private_ip
  depends_on = [var.phantom_server_instance_packer]
  root_block_device {
    volume_type = "gp2"
    volume_size = "30"
    delete_on_termination = "true"
  }
  tags = {
    Name = "attack-range-splunk-server"
  }

  provisioner "remote-exec" {
    inline = ["echo booted"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.splunk-server-packer[count.index].public_ip
      private_key = file(var.private_key_path)
    }
  }

  provisioner "local-exec" {
    working_dir = "../ansible"
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu --private-key ${var.private_key_path} -i '${aws_instance.splunk-server-packer[count.index].public_ip},' playbooks/splunk_server_packer_terraform.yml -e 'ansible_python_interpreter=/usr/bin/python3 splunk_admin_password=${var.splunk_admin_password} phantom_server_private_ip=${var.phantom_server_private_ip} phantom_admin_password=${var.phantom_admin_password} phantom_server=${var.phantom_server}'"
  }
}

resource "aws_eip" "splunk_ip_packer" {
  count = var.use_packer_amis ? 1 : 0
  instance = aws_instance.splunk-server-packer[count.index].id
}
