# k8s-azure-tf

Terraform pra subir 3 VMs na Azure (1 control-plane + 2 workers) para estudo de Kubernetes (kubeadm).

## Recursos criados
- Resource Group
- VNet + Subnet (10.10.1.0/24)
- NSG: SSH (22), API do k8s (6443) e NodePort (30000-32767) liberados só pro seu IP; tráfego interno liberado entre as VMs
- 3x VM Ubuntu 22.04 (`Standard_B2s` por padrão)
- cloud-init: desativa swap e ajusta sysctl/kernel modules (pré-requisito do kubeadm)
- Auto-shutdown diário às 23h (horário de Brasília) em cada VM, pra não gastar crédito à toa

## Uso

```bash
cp terraform.tfvars.example terraform.tfvars
# edite terraform.tfvars com seu IP público (curl ifconfig.me) e caminho da chave SSH

az login
terraform init
terraform plan
terraform apply
```

Ao final, os outputs trazem IP público e comando `ssh` pronto de cada VM.

## Auto-shutdown
As VMs desligam sozinhas todo dia às 23h (horário de Brasília). Isso só *para* a VM (deallocate) — pra ligar de novo, use o Portal/CLI (`az vm start`) ou rode `terraform apply` de novo (não recria nada, só garante o estado).

## Se o init reclamar do lock

Erro `Inconsistent dependency lock file ... no version is selected` quer dizer que o
`.terraform.lock.hcl` local ficou defasado em relacao ao `required_providers`. Resolve com:

```bash
terraform init -upgrade
```

Se persistir, apaga o lock e o cache e inicializa de novo:

```bash
rm -rf .terraform .terraform.lock.hcl
terraform init
```

## Destruir tudo

```bash
terraform destroy
```

## Próximos passos (fora do terraform)
Instalar containerd, kubeadm, kubelet e kubectl em cada VM e seguir o `kubeadm init` no master + `kubeadm join` nos workers, conforme o curso.
