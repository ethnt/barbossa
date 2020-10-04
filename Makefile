build:
	nix-build --attr system ./default.nix --builders "ssh://builder@calico.barbossa.dev?ssh-key=/Users/ethan/.ssh/calico_builder x86_64-linux"

copy:
	ansible-playbook playbooks/copy.yml -i inventory.yml

update:
	ansible-playbook playbooks/update.yml -i inventory.yml
