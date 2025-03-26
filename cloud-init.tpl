#cloud-config
locale: pt_BR.UTF-8
keyboard:
  layout: br
timezone: ${timezone}

users:
  - name: ${initial_username}
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: sudo
    lock_passwd: false
    passwd: ${initial_password}

chpasswd:
  expire: false

package_update: true
package_upgrade: true