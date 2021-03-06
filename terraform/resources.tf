provider "aws" {
  region     =  var.region
}

module "networkModule" {
  source			  = "./modules/network"
	ip_whitelist  = var.ip_whitelist
  availability_zone = var.availability_zone
  subnet_cidr   = var.subnet_cidr
}

module "splunk-server" {
  source			           = "./modules/splunk-server"
 	private_key_path       = var.private_key_path
	key_name		           = var.key_name
	vpc_security_group_ids = module.networkModule.vpc_security_group_ids
	vpc_subnet_id         = module.networkModule.vpc_subnet_id
  splunk_admin_password  = var.splunk_admin_password
  splunk_url             = var.splunk_url
  splunk_binary          = var.splunk_binary
  s3_bucket_url          = var.s3_bucket_url
  splunk_escu_app        = var.splunk_escu_app
  splunk_asx_app         = var.splunk_asx_app
  splunk_windows_ta      = var.splunk_windows_ta
  splunk_cim_app         = var.splunk_cim_app
  splunk_sysmon_ta       = var.splunk_sysmon_ta
  splunk_python_app       = var.splunk_python_app
  splunk_mltk_app         = var.splunk_mltk_app
  splunk_bots_dataset	 = var.splunk_bots_dataset
  splunk_stream_app       = var.splunk_stream_app
  splunk_server_private_ip = var.splunk_server_private_ip
  use_packer_amis        = var.use_packer_amis
  splunk_packer_ami      = var.splunk_packer_ami
  caldera_password       = var.caldera_password
  install_es             = var.install_es
  install_mltk           = var.install_mltk
  splunk_es_app          = var.splunk_es_app
  phantom_app            = var.phantom_app
  phantom_server         = var.phantom_server
  phantom_server_private_ip = var.phantom_server_private_ip
  phantom_admin_password = var.phantom_admin_password
  phantom_server_instance = module.phantom-server.phantom_server_instance
  phantom_server_instance_packer = module.phantom-server.phantom_server_instance_packer
  splunk_security_essentials_app = var.splunk_security_essentials_app
  punchard_custom_visualization = var.punchard_custom_visualization
  status_indicator_custom_visualization = var.status_indicator_custom_visualization
  splunk_attack_range_dashboard = var.splunk_attack_range_dashboard
  timeline_custom_visualization = var.timeline_custom_visualization
  install_mission_control = var.install_mission_control
  mission_control_app    = var.mission_control_app
  install_dsp = var.install_dsp
  dsp_client_cert_path    = var.dsp_client_cert_path
  dsp_node = var.dsp_node
}

module "phantom-server" {
  source                     = "./modules/phantom-server"
  phantom_server             = var.phantom_server
  private_key_path           = var.private_key_path
  key_name                   = var.key_name
  vpc_security_group_ids     = module.networkModule.vpc_security_group_ids
  vpc_subnet_id              = module.networkModule.vpc_subnet_id
  phantom_server_private_ip  = var.phantom_server_private_ip
  phantom_admin_password     = var.splunk_admin_password
  phantom_community_username = var.phantom_community_username
  phantom_community_password = var.phantom_community_password
  use_packer_amis            = var.use_packer_amis
  phantom_packer_ami         = var.phantom_packer_ami
}

module "windows-domain-controller" {
  source			           = "./modules/windows-domain-controller"
 	private_key_path       = var.private_key_path
	key_name		           = var.key_name
  win_username		       = var.win_username
  win_password		       = var.win_password
  windows_domain_controller		      = var.windows_domain_controller
	vpc_security_group_ids = module.networkModule.vpc_security_group_ids
	vpc_subnet_id          = module.networkModule.vpc_subnet_id
  splunk_uf_win_url      = var.splunk_uf_win_url
  win_sysmon_url         = var.win_sysmon_url
  win_sysmon_template    = var.win_sysmon_template
  splunk_admin_password  = var.splunk_admin_password
  availability_zone      = var.availability_zone
  splunk_server_private_ip = var.splunk_server_private_ip
  windows_domain_controller_private_ip = var.windows_domain_controller_private_ip
  windows_domain_controller_os = var.windows_domain_controller_os
  use_packer_amis        = var.use_packer_amis
  windows_domain_controller_packer_ami = var.windows_domain_controller_packer_ami
  splunk_stream_app       = var.splunk_stream_app
  s3_bucket_url          = var.s3_bucket_url
}


module "windows-server" {
  source			           = "./modules/windows-server"
 	private_key_path       = var.private_key_path
	key_name		           = var.key_name
  win_username		       = var.win_username
  win_password		       = var.win_password
  windows_server = var.windows_server
	vpc_security_group_ids = module.networkModule.vpc_security_group_ids
	vpc_subnet_id          = module.networkModule.vpc_subnet_id
  windows_domain_controller_instance = module.windows-domain-controller.windows_domain_controller_instance
  windows_domain_controller_instance_packer = module.windows-domain-controller.windows_domain_controller_instance_packer
  splunk_uf_win_url      = var.splunk_uf_win_url
  win_sysmon_url         = var.win_sysmon_url
  win_sysmon_template    = var.win_sysmon_template
  splunk_admin_password  = var.splunk_admin_password
  availability_zone      = var.availability_zone
  splunk_server_private_ip = var.splunk_server_private_ip
  windows_server_private_ip = var.windows_server_private_ip
  windows_domain_controller_private_ip = var.windows_domain_controller_private_ip
  windows_server_os      = var.windows_server_os
  windows_server_join_domain = var.windows_server_join_domain
  use_packer_amis        = var.use_packer_amis
  windows_server_packer_ami = var.windows_server_packer_ami
  splunk_stream_app       = var.splunk_stream_app
  s3_bucket_url          = var.s3_bucket_url
  run_demo               = var.run_demo
  demo_scenario          = var.demo_scenario
}

module "windows-client" {
  source			           = "./modules/windows-client"
 	private_key_path       = var.private_key_path
	key_name		           = var.key_name
  win_username		       = var.win_username
  win_password		       = var.win_password
  windows_client         = var.windows_client
	vpc_security_group_ids = module.networkModule.vpc_security_group_ids
	vpc_subnet_id          = module.networkModule.vpc_subnet_id
  windows_domain_controller_instance = module.windows-domain-controller.windows_domain_controller_instance
  windows_domain_controller_instance_packer = module.windows-domain-controller.windows_domain_controller_instance_packer
  splunk_uf_win_url      = var.splunk_uf_win_url
  win_sysmon_url         = var.win_sysmon_url
  win_sysmon_template    = var.win_sysmon_template
  splunk_admin_password  = var.splunk_admin_password
  availability_zone      = var.availability_zone
  splunk_server_private_ip = var.splunk_server_private_ip
  windows_client_private_ip = var.windows_client_private_ip
  windows_domain_controller_private_ip = var.windows_domain_controller_private_ip
  windows_client_join_domain = var.windows_client_join_domain
  windows_client_os = var.windows_client_os
  use_packer_amis        = var.use_packer_amis
  windows_client_packer_ami = var.windows_client_packer_ami
  splunk_stream_app       = var.splunk_stream_app
  s3_bucket_url          = var.s3_bucket_url
  run_demo               = var.run_demo
  demo_scenario          = var.demo_scenario
}

module "kali_machine" {
  source			           = "./modules/kali_machine"
 	private_key_path       = var.private_key_path
	key_name		           = var.key_name
  kali_machine           = var.kali_machine
	vpc_security_group_ids = module.networkModule.vpc_security_group_ids
	vpc_subnet_id          = module.networkModule.vpc_subnet_id
  kali_machine_private_ip = var.kali_machine_private_ip
  run_demo               = var.run_demo
  demo_scenario          = var.demo_scenario
  kali_machine_packer_ami = var.kali_machine_packer_ami
  use_packer_amis        = var.use_packer_amis
}
