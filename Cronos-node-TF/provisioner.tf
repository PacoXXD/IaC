locals {
  ssh_user = var.ssh_user
  env      = var.env
}
resource "random_id" "always" {
  keepers = {
    tm = timestamp()
  }

  byte_length = 8
}

resource "null_resource" "scp_cronos_dir" {
  triggers = {
    scp_cronos_dir = random_id.always.hex
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file("~/.ssh/${local.key_name}.pem") //put the private key in your local path ~/.ssh/
      host        = aws_instance.mainnet.public_ip

      timeout = "10m"
    }

    # Copies the "cronos" folder to "~/cronos"
    source      = "${path.root}/cronos"
    destination = "/home/ubuntu"
  }

  depends_on = [
    aws_instance.mainnet
  ]

}
resource "null_resource" "scp_preparation_dir" {
  triggers = {
    scp_preparation_dir = random_id.always.hex
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file("~/.ssh/${local.key_name}.pem")
      host        = aws_instance.mainnet.public_ip

      timeout = "10m"
    }

    # Copies the "Preparation" folder to "~/Preparation"
    source      = "${path.root}/Preparation"
    destination = "/home/ubuntu"
  }

  depends_on = [
    aws_instance.mainnet
  ]

}

resource "null_resource" "run_sh_to_install" {
  triggers = {
    run_sh_to_install = random_id.always.hex
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file("~/.ssh/${local.key_name}.pem")
      host        = aws_instance.mainnet.public_ip
    }

    inline = [
      "cd ~/Preparation",
      "sudo apt update",
      "chmod +x install-docker-compose.sh",
      "sudo apt install jq curl lz4 wget  -y",
      "./install-docker-compose.sh",
    ]
  }

  depends_on = [
  null_resource.scp_cronos_dir, null_resource.scp_preparation_dir]
}



resource "null_resource" "run_docker" {
  triggers = {
    run_docker = random_id.always.hex
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file("~/.ssh/${local.key_name}.pem")
      host        = aws_instance.mainnet.public_ip
    }

    inline = [
      "sudo mkdir -p /root/chain-data",
      "sudo wget https://snapshots.publicnode.com/${var.prunedfile_name}",
      "sudo lz4 -d ${var.prunedfile_name} | sudo tar -xvC /root/chain-data",
      # Copy docker configuration
      "sudo cp -r /home/ubuntu/cronos/docker /root/",

      # Stop existing containers if any
      "sudo docker-compose -f /root/docker/docker-compose.yml down || true",

      # Build and start containers
      "sudo docker-compose -f /root/docker/docker-compose.yml build --no-cache",
      "sudo docker-compose -f /root/docker/docker-compose.yml up -d",

      # Copy configuration files
      "sudo cp -f /home/ubuntu/cronos/config/* /root/chain-data/config/",

      # Restart to apply new configuration
      "sudo docker-compose -f /root/docker/docker-compose.yml restart",

      # Check container status
      "sudo docker-compose -f /root/docker/docker-compose.yml ps",

      # Show recent logs
      "sudo docker-compose -f /root/docker/docker-compose.yml logs --tail=50"
    ]
  }

  depends_on = [
  null_resource.run_sh_to_install]
}
