#!/usr/bin/bash

BLACK='\e[0;30m'
GREY='\e[1;30m'
RED='\e[0;31m'
LRED='\e[1;31m'
GREEN='\e[0;32m'
LGREEN='\e[1;32m'
ORANGE='\e[0;33m'
YELLOW='\e[1;33m'
BLUE='\e[0;34m'
LBLUE='\e[1;34m'
PURPLE='\e[0;35m'
LPURPLE='\e[1;35m'
CYAN='\e[0;36m'
LCYAN='\e[1;36m'

NOCOLOR='\e[0m'
BLINK='\e[5m'

export USER="rzamolo-"
export PASSWORD=$(openssl rand -base64 12 | colrm 17)
export SMB_PASSWD="42madrid"

# https://ascii-generator.site/t/
echo -e "${LGREEN}                                                                                 
                                ##              ##                               
                                ##              ##                               
 ##  ##    #####   #####     #####    #####   ######    ####    #####    ##  ##  
 ######       ##   ##  ##   ##  ##       ##     ##     ##  ##   ##  ##   ##  ##  
 ##  ##   ######   ##  ##   ##  ##   ######     ##     ##  ##   ##        #####  
 ##  ##    #####   ##  ##    #####    #####      ###    ####    ##          ##   
                                                                         #####
${NOCOLOR}"
# ---------------------------------------------------------------------------
#### 	Update and Install (ufw vim sudo libpam-pwquality cryptsetup)
# ---------------------------------------------------------------------------
if (sudo apt update > /dev/null ); then
    echo "✅ System updated"
else
    echo "❌ System updated"    
fi

if (sudo apt install -q -y ufw > /dev/null); then
    echo "✅ UFW installed"
else
    echo "❌ UFW installed"
fi

if (sudo apt install -q -y vim > /dev/null); then
    echo "✅ vim installed"
else
    echo "❌ vim installed"
fi

if (sudo apt install -q -y sudo > /dev/null); then 
    echo "✅ sudo installed"
else
    echo "❌ sudo installed"
fi

if (sudo apt install -q -y libpam-pwquality cryptsetup \
    build-essential manpages-dev man-db > /dev/null && \
    sudo apt --fix-broken install -y > /dev/null && \
    sudo apt autoremove -y > /dev/null); 
then
    echo "✅ Required Libraries installed"
else
    echo "❌ Required Libraries installed"
fi

# ---------------------------------------------------------------------------
####							Config Hostname
# ---------------------------------------------------------------------------
if (sudo echo "127.0.0.1    ${USER}42    ${USER}42.localdomain." | sudo tee /etc/hosts && \
    sudo hostnamectl set-hostname ${USER}42); then
    echo "✅ Hostname set (${USER}42)"
else
    echo "❌ Hostname set (${USER}42)"
fi

# ---------------------------------------------------------------------------
####							Config UFW
# ---------------------------------------------------------------------------
if (sudo /usr/sbin/ufw --force enable > /dev/null); then
    echo "✅ UFW enable"
else
    echo "❌ UFW NOT enable (Error!)"
fi

if (sudo /usr/sbin/ufw allow 4242 > /dev/null && \
    sudo /usr/sbin/ufw allow 445 > /dev/null && \
    sudo /usr/sbin/ufw allow 80 > /dev/null); then
    echo "✅ UFW Rules created"
else
    echo "❌ UFW Rules NOT created (Error!)"
fi

# ---------------------------------------------------------------------------
####	    					Config User
# ---------------------------------------------------------------------------
if (sudo useradd --create-home --shell /bin/bash --user-group \
    ${USER} --groups sudo); then
    echo "✅ User (${USER}) created"
else
    echo "❌ Error creating user (${USER})"
fi

if (sudo groupadd user42 > /dev/null); then
    echo "✅ Create group 'user42'"
else
    echo "❌ Error creating group 'user42'"
fi

if (sudo usermod --append --groups user42 ${USER}); then
    echo -e "✅ Add user (${USER}) to 'user42' group"
else
    echo -e "❌ Error adding user (${USER}) to 'user42' group"
fi

if (sudo echo -e -n "${PASSWORD}\n${PASSWORD}" | passwd ${USER}); then
    echo "✅ Setting user(${USER}) password"
else
    echo "❌ Error Setting user password"
fi

if (sudo passwd --expire ${USER}); then
    echo "✅ Set password as expired"
else
    echo "❌ Error setting password as expired"
fi

if (sudo chage --maxdays 30 --mindays 2 ${USER}); then
    echo "✅ Set password to expire in 30 days"
else
    echo "❌ Error setting password to expire in 30 days"
fi

# ---------------------------------------------------------------------------
####							Config SSH
# ---------------------------------------------------------------------------

if (sudo sed -i "s/^#Port 22/Port 4242/g" /etc/ssh/sshd_config); then
    echo "✅ Change ssh service to listen on port 4242"
else
    echo "❌ Error changing ssh service to listen on port 4242"
fi

if (sudo sed -i "s/^#PasswordAuthentication yes/PasswordAuthentication yes/g" /etc/ssh/sshd_config); then
    echo "✅ SSH: Enabling Password Authentication"
else
    echo "❌ SSH: Error enabling Password Authentication"
fi

if (sudo sed -i "/^#/d" /etc/ssh/sshd_config); then
    echo "✅ Removing comments"
else
    echo "❌ Removing comments"
fi

if (sudo sed -i "/^$/d" /etc/ssh/sshd_config); then
    echo "✅ Removing empty lines"
else
    echo "❌ Removing empty lines"
fi

# ---------------------------------------------------------------------------
#### 							Config Password Policy
# ---------------------------------------------------------------------------
if (sudo sed -i "s/^PASS_MAX_DAYS	99999/PASS_MAX_DAYS	30/g" /etc/login.defs); then
    echo "✅ Set PASS_MAX_DAYS to 30"
else
    echo "❌ Set PASS_MAX_DAYS to 30"
fi

if (sudo sed -i "s/^PASS_MIN_DAYS	0/PASS_MIN_DAYS	2/g" /etc/login.defs); then
    echo "✅ Set PASS_MIN_DAYS to 2"
else
    echo "❌ Set PASS_MIN_DAYS to 2"
fi

if (sudo sed -i "s/^PASS_WARN_AGE     7/PASS_WARN_AGE	7/g" /etc/login.defs); then
    echo "✅ Set PASS_WARN_AGE to 7"
else
    echo "❌ Set PASS_WARN_AGE to 7"
fi

if (sudo sed -i "s/password	requisite			pam_pwquality.so retry=3/password        requisite                       pam_pwquality.so retry=3 minlen=10 ucredit=-1 dcredit=-1 maxrepeat=3 reject_username difok=7 enforce_for_root/g" /etc/pam.d/common-password); then
    echo "✅ Password Policy"
else
    echo "❌ Password Policy"
fi  

if (sudo mkdir -p /var/log/sudo/ && \
    sudo touch /var/log/sudo/sudo_login.log); then
    echo "✅ Create log file"
else
    echo "❌ Create log file"
fi

# ---------------------------------------------------------------------------
####							Block Root Login
# ---------------------------------------------------------------------------

cat << EOF > /etc/sudoers
Defaults        env_reset
Defaults        mail_badpass
Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Defaults        passwd_tries=3
Defaults        badpass_message="Wrong password. Try again!"
Defaults        logfile="/var/log/sudo/sudo_login.log"
Defaults        log_input, log_output
Defaults        iolog_dir="/var/log/sudo"
#Defaults        requiretty

root    ALL=(ALL:ALL) ALL
%sudo   ALL=(ALL:ALL) ALL
@includedir /etc/sudoers.d

EOF

if (sudo sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin no/g" /etc/ssh/sshd_config); then
    echo "✅ Permit Root Login"
else
    echo "❌ Permit Root Login"
fi

# ---------------------------------------------------------------------------
####						Copying monitoring script
# ---------------------------------------------------------------------------

sudo cp /vagrant/monitoring.sh /home/${USER}/monitoring.sh
sudo chmod +x /home/${USER}/monitoring.sh
echo "*/10 * * * * /home/${USER}/monitoring.sh" | crontab -

# ---------------------------------------------------------------------------

echo -e "${LGREEN}
 ##                                          
 ##                                          
 ######    #####   ## ###   ##   ##   #####  
 ##   ##  ##   ##  ###  ##  ##   ##  ##      
 ##   ##  ##   ##  ##   ##  ##   ##   ####   
 ##   ##  ##   ##  ##   ##  ##  ###      ##  
 ######    #####   ##   ##   ### ##  #####   
${NOCOLOR}"

# ---------------------------------------------------------------------------
####						Wordpress pre-reqs
# ---------------------------------------------------------------------------
if (
    sudo apt install -y mariadb-server lighttpd php php-fpm php-mysql php-cli php-curl php-xml php-json php-zip php-mbstring php-gd php-intl php-cgi > /dev/null
); then
    echo "✅ Install Wordpress pre-reqs"
else
    echo "❌ Install Wordpress pre-reqs"
fi

# ---------------------------------------------------------------------------
####						Remove apache if installed
# ---------------------------------------------------------------------------
if (sudo apt remove -y apache2 > /dev/null && sudo systemctl stop apache2 > /dev/null); then
    echo "✅ Remove apache if installed"
else
    echo "❌ Remove apache if installed"
fi

# ---------------------------------------------------------------------------
####						Start/Enable lighttpd
# ---------------------------------------------------------------------------
if (sudo systemctl start lighttpd && systemctl enable lighttpd); then
    echo "✅ Start/Enable lighttpd"
else
    echo "❌ Start/Enable lighttpd"
fi

# ---------------------------------------------------------------------------
####						Config PHP
# ---------------------------------------------------------------------------
if (
    sudo sed -i "s/listen = \/run\/php\/php7.4-fpm.sock/listen = 127.0.0.1:9000/g" /etc/php/7.4/fpm/pool.d/www.conf
); then
    echo "✅ Change socket to ip and port (www.conf)"
else
    echo "❌ Change socket to ip and port (www.conf)"
fi

if (
    sudo sed -i "s/\"bin-path\" => \"\/usr\/bin\/php-cgi\"/\"host\" => \"127.0.0.1\"/g" /etc/lighttpd/conf-available/15-fastcgi-php.conf
); then
    echo "✅ Change fastcgi path to ip (15-fastcgi-php.conf)"
else
    echo "❌ Change fastcgi path to ip (15-fastcgi-php.conf)"
fi

if (
sudo sed -i "s/\"socket\" => \"\/run\/lighttpd\/php.socket\"/\"port\" => \"9000\"/g" /etc/lighttpd/conf-available/15-fastcgi-php.conf
); then
    echo "✅ Change fastcgi socket to port (15-fastcgi-php.conf)"
else
    echo "❌ Change fastcgi socket to port (15-fastcgi-php.conf)"
fi

if (sudo lighty-enable-mod fastcgi > /dev/null && \
    sudo lighty-enable-mod fastcgi-php > /dev/null); then
    echo "✅ Enable fastcgi and fastcgi-php"
else
    echo "❌ Enable fastcgi and fastcgi-php"
fi

if (sudo systemctl restart lighttpd && sudo systemctl restart php7.4-fpm); then
    echo "✅ Restart lighttpd and php7.4-fpm"
else
    echo "❌ Restart lighttpd and php7.4-fpm"
fi

# ---------------------------------------------------------------------------
####						Wordpress database
# ---------------------------------------------------------------------------
if (sudo mysql -e "CREATE DATABASE wpdb;"); then
    echo "✅ Create wpdb"
else
    echo "❌ Create wpdb"
fi

if (sudo mysql -e "GRANT ALL PRIVILEGES on wpdb.* TO 'wp-user'@'localhost' IDENTIFIED BY '${PASSWORD}';"); then
    echo "✅ Create wp-user"
else
    echo "❌ Create wp-user"
fi

if (sudo mysql -e "FLUSH PRIVILEGES;"); then
    echo "✅ Flush db privileges"
else
    echo "❌ Flush db privileges"
fi

# ---------------------------------------------------------------------------
####						Download Wordpress
# ---------------------------------------------------------------------------
cd /var/www/html
wget -q https://wordpress.org/latest.tar.gz 
tar xzf latest.tar.gz
cd wordpress
if (mv wp-config-sample.php wp-config.php); then
    echo "✅ Wordpress Installed"
else
    echo "❌ Wordpress Installed"
fi

# ---------------------------------------------------------------------------
####						Config Wordpress
# ---------------------------------------------------------------------------
if (
    sed -i "s/database_name_here/wpdb/g" wp-config.php && \
    sed -i "s/username_here/wp-user/g" wp-config.php && \
    sed -i "s/password_here/${PASSWORD}/g" wp-config.php); then
    echo "✅ Config wp-config.php"
else
    echo "❌ Config wp-config.php"
fi

chown -R www-data:www-data /var/www/html/wordpress
chmod -R 755 /var/www/html/wordpress

# ---------------------------------------------------------------------------
####				    Install samba and share a folder
# ---------------------------------------------------------------------------
if (apt install -y samba > /dev/null); then
    echo "✅ Install samba"
else
    echo "❌ Install samba"
fi

sed -i "s/unix password sync = yes/unix password sync = no/g" /etc/samba/smb.conf

echo -e -n "${SMB_PASSWD}\n${SMB_PASSWD}" | sudo smbpasswd -a ${USER}

mkdir -p /var/www/html/42smb
chown -R ${USER}:${USER} /var/www/html/42smb
chmod -R 755 /var/www/html/42smb

cat <<EOF >> /etc/samba/smb.conf
[42smb]
comment = 42smb
path = /var/www/html/42smb
writeable = yes
browsable = yes
bind interfaces only = no
EOF


# ---------------------------------------------------------------------------
####						Config Lighttpd
# ---------------------------------------------------------------------------
mkdir -p /etc/lighttpd/vhosts.d/

cat <<EOF >> /etc/lighttpd/vhosts.d/wordpress.conf
\$HTTP["host"] =~ "(^|.)wordpress.example.com\$" {
server.document-root = "/var/www/html/wordpress"
server.errorlog = "/var/log/lighttpd/wordpress-error.log"
}
EOF

cat <<EOF >> /etc/lighttpd/vhosts.d/42smb.conf
\$HTTP["host"] =~ "(^|.)42smb.example.com\$" {
server.document-root = "/var/www/html/42smb"
server.errorlog = "/var/log/lighttpd/42smb-error.log"
}
EOF


sudo sed -i "s/include_shell \"\/usr\/share\/lighttpd\/create-mime.conf.pl\"/include_shell \"\/usr\/share\/lighttpd\/create-mime.conf.pl\"\ninclude_shell \"cat \/etc\/lighttpd\/vhosts.d\/\*.conf\"/g" /etc/lighttpd/lighttpd.conf
sudo sed -i "s/\t\"mod_indexfile\",/\t\"mod_compress\",\n\t\"mod_rewrite\",/g" /etc/lighttpd/lighttpd.conf

if (sudo systemctl restart lighttpd); then
    echo "✅ Restart lighttpd"
else
    echo "❌ Restart lighttpd"
fi


# ---------------------------------------------------------------------------
####						Copying monitoring script
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
## Restart sshd service and ufw ("due to ssh port change)
# sudo systemctl --failed
sudo systemctl reset-failed

echo "Restart sshd"
sudo systemctl reload sshd
sudo /usr/sbin/ufw reload
# ---------------------------------------------------------------------------
echo -e "\nUse the password below to set the new password to user:  ${USER}\n"
echo -e "${RED}${PASSWORD}${NOCOLOR}\n"

echo -e "Uncomment ${YELLOW}Defaults	requiretty${NOCOLOR} from ${YELLOW}/etc/sudoers${NOCOLOR}\n"
