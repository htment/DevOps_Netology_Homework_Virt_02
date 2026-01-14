# Задача 2
Установите на личный Linux-компьютер или учебную локальную ВМ с Linux следующие сервисы(желательно ОС ubuntu 20.04):

VirtualBox,
Vagrant, рекомендуем версию 2.3.4
Packer версии 1.9.х + плагин от Яндекс Облако по инструкции
уandex cloud cli Так же инициализируйте профиль с помощью yc init .
Примечание: Облачная ВМ с Linux в данной задаче не подойдёт из-за ограничений облачного провайдера. У вас просто не установится virtualbox.

## Решение
 1. Обновление системы и установка VirtualBox:

 ```
sudo apt update && sudo apt upgrade -y
sudo apt install -y virtualbox virtualbox-ext-pack
```
Если не ставит
```
# Добавление ключа репозитория
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -

# Добавление репозитория в sources.list
echo "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list

# Обновление списка пакетов
sudo apt update

# Установка VirtualBox
sudo apt install -y virtualbox-7.0  # или другая версия
```
### вариант 2
```
# Скачивание и добавление ключей
curl -L http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc -o oracle_vbox_2016.asc && sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/oracle_vbox_2016.gpg oracle_vbox_2016.asc
curl -L http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -o oracle_vbox.asc && sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/oracle_vbox.gpg oracle_vbox.asc

# Добавление репозитория
echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/oracle_vbox_2016.gpg] https://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list

# Обновление пакетов и установка VirtualBox
sudo apt update && sudo apt install -y virtualbox-7.0
```





### Виртуалка не запустилась 
выдала ошибку 
```
Virtualized AMD-V/RVI is not supported on this platform.
Continue without virtualized AMD-V/RVI?
```



### ✅ Альтернатива 1: libvirt + QEMU/KVM (рекомендуется для Linux)
Это нативный гипервизор Linux, более производительный и современный, чем VirtualBox.

```
# 1. Установите необходимые пакеты
sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager

# 2. Добавьте пользователя в нужные группы
sudo adduser $USER libvirt
sudo adduser $USER kvm

# 3. Перезайдите в систему или выполните:
newgrp libvirt

# 4. Установите плагин Vagrant для libvirt
vagrant plugin install vagrant-libvirt

# 5. Проверьте установку
virsh list --all  # Должен показать пустой список ВМ
```
![alt text](image.png)
--------------------------------------------------------------------------------

## Ставим Vagrand

```
sudo apt update
sudo apt install vagrant
vagrant --version

```


![alt text](image-1.png)
```
export VAGRANT_DEFAULT_PROVIDER=virtualbox

```
### Создаем Vagrand файл
```
export VAGRANT_SERVER_URL='https://vagrant.elab.pro'
```
скачиваем образ 
```
vagrant box add bento/ubuntu-24.04 --provider=virtualbox --force
```
![alt text](image-3.png)

```
vagrant box list
```

![alt text](image-4.png)

Создаем файл Vagrand

```
ISO = "bento/ubuntu-24.04"
NET = "192.168.192."
DOMAIN = ".netology"
HOST_PREFIX = "server"
INVENTORY_PATH = "../ansible/inventory"

servers = [
  {
    :hostname => HOST_PREFIX + "1" + DOMAIN,
    :ip => NET + "11",
    :ssh_host => 20011,
    :ssh_vm => 22,
    :ram => 1024,
    :core => 1
  }
]

Vagrant.configure("2") do |config|
  config.vm.synced_folder ".", "/vagrant", disabled: false

  servers.each do |machine|
    config.vm.define machine[:hostname] do |node|
      node.vm.box = ISO
      node.vm.hostname = machine[:hostname]
      node.vm.network "private_network", ip: machine[:ip]
      node.vm.network :forwarded_port,
                      guest: machine[:ssh_vm],
                      host: machine[:ssh_host]

      node.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", machine[:ram]]
        vb.customize ["modifyvm", :id, "--cpus", machine[:core]]
        vb.name = machine[:hostname]
      end
    end
  end
end


#ENV['VAGRANT_SERVER_URL'] = 'http://vagrant.elab.pro'
#Vagrant.configure("2") do |config|
#  config.vm.box = "bento/ubuntu-24.04"
#  config.vm.provider "libvirt" do |lv|
#    lv.memory = 1024
#    lv.cpus = 1
#    lv.driver = "qemu"
#    lv.cpu_model = "qemu64"
#    lv.machine_type = "pc"
#  end
#end

```
Проверяем, если все ок запускаем
```
vagrant validate
vagrant up
```
Получили ошибку 
![alt text](image-5.png)
```
vagrant destroy
```
Поменяем NET = "192.168.192." --> NET = "192.168.56." в файле 

![alt text](image-6.png)
```
vagrant up
```
![alt text](image-7.png)

```vagrant status```
![alt text](image-14.png)
```
vagrant ssh
```
![alt text](image-10.png)
```cat /etc/*release```
![alt text](image-9.png)
![alt text](image-11.png)
![alt text](image-12.png)
![alt text](image-13.png)
### Выключение ВМ. В директории, где находится Vagrantfile
```vagrant halt```
### Проверяем состояние ВМ. В директории, где находится Vagrantfile
``vagrant status``

![alt text](image-15.png)
### Удаляем ВМ. В директории, где находится Vagrantfile
``vagrant destroy``
### Снова проверяем состояние ВМ. В директории, где находится Vagrantfile
``vagrant status``

![alt text](image-16.png)

# Задача 3

## Установка YC CLI
```
curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash

sudo cp  yandex-cloud/bin/yc /usr/bin/

# Инициализация YC CLI
yc init
```
![alt text](image-17.png)
```
# Проверка подключения
yc config list
```
![alt text](image-19.png)


или
```
yc config set service-account-key yandex-cloud/authorized_key.json
yc config list
```
![alt text](image-18.png)



Список рабочих образов
```
yc compute image list
```
![alt text](image-20.png)

создадим сеть 

```
yc vpc network create --name net --labels my-label=netology --description "My network"
```
![alt text](image-22.png)
![alt text](image-21.png)


Создадим подсеть внутири сети

```
yc vpc subnet create --name my-subnet-a --zone ru-centrall-a --range 10.1.2.0/24 --network-name net --description "My subnet"
```
![alt text](image-24.png)

## Сборка образа с Packer

### Установка Packer (если не установлен)
```
mkdir packer
wget https://hashicorp-releases.yandexcloud.net/packer/1.11.2/packer_1.11.2_linux_amd64.zip -P ~/packer
unzip ~/packer/packer_1.11.2_linux_amd64.zip -d ~/packer


# Добавьте в файл .profile строку:
export PATH="$PATH:/home/art/packer"
# Перезапустите оболочку:
exec -l $SHELL

cp  ~/packer/packer /usr/bin/


packer --version

```
### Настройте плагин Yandex Compute Builder
```
cat>config.pkr.hcl<<EOF
packer {
  required_plugins {
    yandex = {
      version = ">= 1.1.2"
      source  = "github.com/hashicorp/yandex"
    }
  }
}

EOF

```

![alt text](image-25.png)
```
packer validate mydebian.json
```
![alt text](image-26.png)
```
packer build mydebian.json
```

yc compute image list

![alt text](image-27.png)

```
packer validate mydebian_docker.json
packer build mydebian_docker.json
yc compute image list

```

## Создайте ВМ
## Найдите ID вашего образа
```

# Удаляем старую ВМ
yc compute instance delete debian-docker-vm

# Создаем новую с правильным cloud-config
YC_KEY_FILE="$HOME/.ssh/id_ed25519.pub"

yc compute instance create \
  --name debian-docker-vm \
  --hostname debian-docker-vm \
  --memory 1GB \
  --cores 2 \
  --core-fraction 5 \
  --create-boot-disk image-id=fd8pq6ar0fluv6akl4ff \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --zone ru-central1-a \
  --metadata-from-file user-data=<(cat << EOF
#cloud-config
users:
  - name: art
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    groups: sudo,docker
    lock_passwd: false
    passwd: "$6$rounds=4096$WvKJh8KjNt$U.pY8jH.N8mZ7KQ1Hp8ZJv8tRwLpX1dM.7gSfV8eWkC1nTqG5sY6hP9bV2cE3rF4xY5zA6B7vD8"
    ssh_authorized_keys:
      - $(cat "$YC_KEY_FILE")
EOF
) \
  --metadata serial-port-enable=1

  ```
![alt text](image-30.png)

# Удаление ресурсов
```
# Удаление ВМ
yc compute instance list
yc compute instance delete debian-docker-vm

# Удаление образа
yc compute image list
yc compute image delete ваш_image_id

# Проверьте, что всё удалено
yc compute image list
yc compute instance list
```
![alt text](image-31.png)
````
###########3
````