#!/bin/bash

# Прерывать выполнение при ошибках
set -e

echo "Начало установки VirtualBox..."

# Добавление ключа репозитория
echo "Скачивание и добавление ключей..."
wget -v https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
wget -v https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -

# Добавление репозитория в sources.list
echo "Добавление репозитория..."
echo "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list

# Обновление списка пакетов
echo "Обновление списка пакетов..."
sudo apt update

# Проверка доступных версий VirtualBox
echo "Доступные версии VirtualBox:"
apt-cache search virtualbox- | grep ^virtualbox

# Установка VirtualBox
echo "Установка VirtualBox 7.0..."
sudo apt install -y virtualbox-7.0

echo "Установка завершена успешно!"
echo "Версия VirtualBox: $(virtualbox --version 2>/dev/null || echo 'Запустите VirtualBox для проверки')"
