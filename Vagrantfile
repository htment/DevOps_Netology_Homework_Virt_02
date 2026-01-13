ENV['VAGRANT_SERVER_URL'] = 'http://vagrant.elab.pro'
Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-24.04"
  config.vm.provider "libvirt" do |lv|
    lv.memory = 1024
    lv.cpus = 1
    lv.driver = "qemu"
    lv.cpu_model = "qemu64"
    lv.machine_type = "pc"
  end
end
