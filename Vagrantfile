Vagrant.configure("2") do |config|
  config.disksize.size = '20GB'
  config.vm.box = "ubuntu/bionic64"
  config.vm.network "private_network", ip: "192.168.7.7"
  config.vm.network "forwarded_port", guest: 32400, host: 32400
  config.vm.network "forwarded_port", guest: 6789, host: 6789
  config.vm.network "forwarded_port", guest: 7878, host: 7878
  config.vm.network "forwarded_port", guest: 8989, host: 8989
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "playbooks/dev.yml"
  end
end
