resource "terraform_data" "k3d_cluster" {
  input = {
    name  = var.k3d_cluster_name
    image = "rancher/k3s:${var.k3s_version}"
  }

  provisioner "local-exec" {
    command = "k3d cluster create ${self.input.name} --image ${self.input.image} --servers 1 --agents 0 -p '8080:80@loadbalancer'"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "k3d cluster delete ${self.input.name}"
  }
}
