terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Set the variable value in *.tfvars file
# or using -var="do_token=..." CLI option
#variable "do_token" {}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = "dop_v1_e3f75c7c99b5ab742d980cede48f25ee2972694e594a2635e6af1c79383bfe30"
  #name:jornada-k8s-devops
  #var.do_token
}

# maquina virtual que tera o jenki
# Create a web server
#resource "digitalocean_droplet" "web" {
# ...
#}
# Create a new Web Droplet in the nyc2 region
resource "digitalocean_droplet" "jenkins" {
  image  = "ubuntu-22-04-x64"
  name   = "jenkins"
  region = var.region #"nyc1"
  size   = "s-2vcpu-2gb"
  # o identificador
  ssh_keys = [data.digitalocean_ssh_key.ssh_key.id]
}

#pegando as chaves
data "digitalocean_ssh_key" "ssh_key" {
  name = var.ssh_key_name #"Jornada"
}

resource "digitalocean_kubernetes_cluster" "k8" {
  name   = "k8"
  region = var.region #var.region 
  #"nyc1"
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.24.4-do.0"

  node_pool {
    name       = "default" #"worker-pool"
    size       = "s-2vcpu-2gb"
    node_count = 1

  } #node_pool
}   #"digitalocean_kubernetes_cluster" "k8"

variable "do_token" {
  default = ""

  #var.do_token
  #"dop_v1_e3f75c7c99b5ab742d980cede48f25ee2972694e594a2635e6af1c79383bfe30"
}

variable "ssh_key_name" {
  default = ""
  #"Jornada"
}

variable "region" {
  default = ""
  #"nyc1"
}

output "jenkins_ip" {
    value = digitalocean_droplet.jenkins.ipv4_address
}

resource "local_file" "foo" {
    content = digitalocean_kubernetes_cluster.k8.kube_config.0.raw_config
    filename = "kube_config.yaml"
}