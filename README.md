# Rules
 A collection of diverse Ansible rules and scripts that helped me in my journey
 
## Requirements

- Ansible 2.9 or higher
- Debian / Ubuntu based system

## Prerequisites

Before running the playbook, you need to install Ansible. Here is a step-by-step guide on how to install it in a Python virtual environment:

```bash
sudo apt update
sudo apt install python3-venv python3-pip
python3 -m venv env
source env/bin/activate
pip install ansible
```
## Configuration

1. **Hosts Setup**: Modify the Ansible hosts file (`hosts.ini`) and add the IP addresses or hostnames of your target instances under the appropriate group. For example:
```yml
[hosts]
X.X.X.X

[hosts:vars]
ansible_user=<user>
```

## Usage

Run the playbook using the following command:

```bash
ansible-playbook -i hosts.ini main.yml
```

To update the solution, you can use the following command:

```bash
ansible-playbook -i hosts.ini update.yml
```
