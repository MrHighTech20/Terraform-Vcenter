# Terraform-Vcenter
Create virtual machines using terraform

Hey everyone. I created a Terraform file to use with a vSphere (vCenter server). I want to show you my project. 

# Terraform
This guide explains how to set up a virtual machine (VM) using Terraform with the VMware vSphere provider.

## Prerequisites

Before you begin, ensure you have the following:

- [Terraform](https://developer.hashicorp.com/terraform/install) installed
- Access to a VMware vCenter Server

Access to a VMware vCenter Server
A Vagrant box for your desired OS

## Steps

1. **Create a Terraform Project Directory**

   Create a new directory for your Terraform project. Open your terminal and initialize the repository with the command:


2. **Edit Vagrantfile**

```bash
  
```
Replace all placeholders with your actual values.

3. **Troubleshooting**

If you encounter issues with the vSphere provider settings, double-check your vSphere server credentials, permissions, and network configurations.

For more details on Vagrant and the vSphere provider, refer to the official documentation.
At the moment, the VM is created using a template that was created before. After creating the virtual machine, Vagrant tried to create a connection using SSH, but the following message returns:

```bash
default: SSH auth method: private key 
default: Warning: Authentication failure. Retrying...
```
The virtual machine is running but with unfinished config, because the SSH is not working.