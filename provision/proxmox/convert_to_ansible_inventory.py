import sys

def create_ansible_inventory(ip_addresses_file):
    print(ip_addresses_file)
    inventory = {
        'all': {
            'hosts': []
        }
    }

    with open(ip_addresses_file, 'r') as file:
        ip_addresses = file.readlines()
        ip_addresses = [ip.strip() for ip in ip_addresses]
    
    for i, ip_address in enumerate(ip_addresses):
        host_name = f'host{i+1}'
        inventory['all']['hosts'].append(host_name)
        inventory[host_name] = {
            'ansible_host': ip_address
        }

    ansible_inventory = ""
    for group, group_vars in inventory.items():
        ansible_inventory += f"[{group}]\n"
        for host, host_vars in group_vars.items():
            if host == 'hosts':
                ansible_inventory += '\n'.join(host_vars)
                ansible_inventory += '\n\n'
            else:
                ansible_inventory += f"{host} ansible_host={host_vars}\n"
        ansible_inventory += '\n'

    return ansible_inventory

if __name__ == '__main__':
    ip_addresses_file = "./ip_addresses.txt" #sys.argv[1]
    ansible_inventory = create_ansible_inventory(ip_addresses_file)
    print(ansible_inventory)