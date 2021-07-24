#Installing script

# Most of configuration is done by importing configuration file
# Comment about functionnality should be included in them

LOGIN=iguidado
PASS=User42Added
ROOT_PASS=Lalilulelo12!

#-------------------------------------------------------
#System

# Import sudo restricted configuration
cp sudo-42 /etc/sudoers.d/sudo-42

## Password and login policy

# Import Password quality restriction configuration
cp pwquality.conf /etc/security

# Import login time restriction configuration
cp login.defs /etc/login.defs

# Apply login time restriction to currents user (root)
chage -m 2 -M 30 root

## Account creation/modification
# Add user42 group
groupadd user42
groupadd sudo

# Adding USER
useradd $LOGIN -G user42,sudo

# Defining it's password
echo "$PASS" | passwd --stdin $LOGIN

# Defining new password for root

echo "$ROOT_PASS" | passwd --stdin root

#-------------------------------------------------------
#-------------------------------------------------------
#Network

## Import SSH configuration
cp sshd_config /etc/ssh/sshd_config


# Install Firewall
dnf install epel-release -y
dnf install ufw -y

#--------------------------------------------------
## Firewall configuration
ufw enable
### To start ufw at start
systemctl enable ufw

### Deleting default rules of ufw
RULE_NB=4
while [ $RULE_NB -gt 0 ]
do
	yes | ufw delete 1
	((RULE_NB--))
done

### Finaly alowing good port for ssh but it not finished
ufw allow 4242


# SElinux configuration for using port 4242
semanage port -a -t ssh_port_t -p tcp 4242

#--------------------------------------------------
# Cleaning base configuration
#  This  -> `semanage port -d ssh_port_t -p tcp 22;` 
#	don't work because of default policy

systemctl disable rpcbind.socket
systemctl stop rpcbind.socket

#--------------------------------------------------
# Restart service
systemctl restart sshd

#--------------------------------------------------
#--------------------------------------------------
#Monitoring

cp monitoring.sh /root/monitoring.sh
chmod +x /root/monitoring.sh
echo "*/10 * * * * root /root/monitoring.sh" > /etc/cron.d/monitoring

#--------------------------------------------------
#--------------------------------------------------
#Bonus
##Web server

# Installing needed component
dnf install lighttpd mariadb mariadb-server -y
ufw allow 80

# Installing wordpress
cd /tmp
wget https://wordpress.org/latest.tar.gz
