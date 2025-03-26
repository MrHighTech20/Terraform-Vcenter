# Terraform-Vcenter
Create virtual machines using terraform

Hey everyone. I created a Terraform file to use with a vSphere (vCenter server) without template. but after you need config VM, for example I used Ubuntu Server 24. 

# Terraform
This guide explains how to set up a virtual machine (VM) using Terraform with the VMware vSphere provider.

## Prerequisites

Before you begin, ensure you have the following:

- [Terraform](https://developer.hashicorp.com/terraform/install) installed
- Access to a VMware vCenter Server
- Knowledge in linux

## Steps

1. **Opitional - install WSL 2**

I used Linux with WSL because I find it easier, but you can use any OS.

2. **Install Terraform**

You need access officialy page of Terraform and following the steps to install in your computer.

3. **Set your environment variables with your VCenter credentials**

Terraform needs to authenticate on your VCenter, but it's need to you credencials for authenticate it, to do this run in the machine's terminal:
 
 bash
 ´´´
   echo 'export TF_VAR_vsphere_user="your_user@vsphere.local"' >> ~/.bashrc
   echo 'export TF_VAR_vsphere_password="your_password"' >> ~/.bashrc
   echo 'export TF_VAR_vsphere_server="192.168.*.*"' >> ~/.bashrc
   source ~/.bashrc
 ´´´
If you have DNS on your VCenter, put its name instead of the IP.

Now your VCenter credencials it's save and don't need to set in your code.

