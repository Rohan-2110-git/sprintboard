locals {
  name = "${var.project}-${var.environment}"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_security_group" "k3s" {
  name        = "${local.name}-k3s-sg"
  description = "k3s node SG"

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP/HTTPS (for LoadBalancers/Ingress if used)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubernetes NodePort range (Argo CD is on 30080)
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "k3s" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.k3s.id]
  tags = { Name = "${local.name}-k3s" }

  user_data = <<CLOUDINIT
#cloud-config
package_update: true
packages:
  - curl
  - unzip
runcmd:
  - curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode=644" sh -
  - curl -L https://get.helm.sh/helm-v3.14.4-linux-amd64.tar.gz -o /tmp/helm.tgz
  - tar -xzf /tmp/helm.tgz -C /tmp && mv /tmp/linux-amd64/helm /usr/local/bin/helm
  - curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  - install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  - export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
  - kubectl wait --for=condition=Ready node --all --timeout=120s || true
  - helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
  - helm repo update
  - helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace
  - echo "KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> /etc/environment
CLOUDINIT
}

output "k3s_public_ip" { value = aws_instance.k3s.public_ip }
output "ssh_command"   { value = "ssh -i ~/.ssh/your-key.pem ubuntu@${aws_instance.k3s.public_ip}" }
