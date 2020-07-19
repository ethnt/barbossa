copy:
	ansible-playbook playbooks/copy.yml -i inventory.yml

update:
	ansible-playbook playbooks/update.yml -i inventory.yml
