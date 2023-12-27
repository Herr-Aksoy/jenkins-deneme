#!/bin/bash

yum update -y
sudo amazon-linux-extras install ansible2 -y

# bunlari inventory file olusturup icerisine  yazarak yapmak daha mantikli.
sudo bash -c "cat << EOF > /home/ec2-user/ansible.cfg
[defaults]
host_key_checking = False
inventory = inventory
deprecation_warnings=False
interpreter_python=auto_silent
EOF"


sudo bash -c "cat << EOF > /home/ec2-user/inventory
[webservers]
node1 ansible_host="Ec2 privat ip yazilacak" ansible_user=ec2-user
node2 ansible_host="Ec2 privat ip yazilacak" ansible_user=ec2-user

[all:vars]
ansible_ssh_private_key_file=/home/ec2-user/${pem_key}.pem
EOF"

## üstekilerde test edildi onlarida yaziyor.

cd /etc/ansible           ## Burada ansible.cfg  hosts  ve roles file lari var.
sudo echo "[webservers]" >> hosts
sudo echo "node1 ansible_host="Ec2 privat ip yazilacak" ansible_user=ec2-user" >> hosts
sudo echo "node2 ansible_host="Ec2 privat ip yazilacak" ansible_user=ec2-user" >> hosts        ## Ec2 larin privar Ip leri eklenmeli.

echo "[all:vars]" >> hosts
echo "ansible_ssh_private_key_file=/home/ec2-user/${pem_key}.pem" >> hosts      ## Makinalarda ayni pemkey oldugundan bu yeterli.

## Bu ikisini de ekledi.
sed -i '/module_set_locale = False/a interpreter_python=auto_silent' ansible.cfg    ## Bu yeni satir ekliyor. Uyarilari engelemek icin.
sed -i 's/#host_key_checking = False/host_key_checking = False/g' ansible.cfg       ## sürekli yes sorusu gelmeyecek.


yum  install git ## Bunu kontrol etmeyi unuttum

sudo bash -c "cat << EOF > /home/ec2-user/${pem_key}.pem
${private_key_content}
EOF"

                                                        ## Buraya kadar tamamdir. 





chmod 400 ${pem_key}.pem



# sudo bash -c "cat << EOF > /prometheus.yml
# # scrape_configs bölümünü bul ve düzenle
# scrape_configs:
#   - job_name: 'prometheus'
#     static_configs:
#       - targets: ['localhost:9090']

#   # Yeni bir scrape job ekle
#   - job_name: 'remote_collector'
#     scrape_interval: 10s
#     static_configs:
#       - targets: ['private_ip_value:9100']
# EOF"





# sudo bash -c "mkdir ${pem_key}.arkadas"

# sudo touch ${neyaptin}.asd      

# sudo mkdir manyak.txt                   ## Bu sekilde hepsini yapti

# mkdir kanka.nt        

# mkdir ${neyaptin}.nachte