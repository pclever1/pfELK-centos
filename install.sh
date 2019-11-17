#check if root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
yum -y update
yum -y install java
yum -y install net-tools

#configure GeoIP
cd /etc/
sed -i "s/EditionIDs GeoLite2-Country GeoLite2-City/EditionIDs GeoLite2-City GeoLite2-Country GeoLite2-ASN/g" /etc/GeoIP.conf
geoipupdate
cd /etc/cron.weekly/
sudo wget https://raw.githubusercontent.com/pclever1/pfELK-centos/master/geoipupdate


#install ELK
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
cd /etc/yum.repos.d/
sudo wget https://raw.githubusercontent.com/pclever1/pfELK-centos/master/elasticsearch.repo
yum -y install elasticsearch
yum -y install kibana
yum -y install logstash
cd /etc/logstash/conf.d
sudo wget https://raw.githubusercontent.com/a3ilson/pfelk/master/conf.d/01-inputs.conf
sudo wget https://raw.githubusercontent.com/a3ilson/pfelk/master/conf.d/05-syslog.conf
sudo wget https://raw.githubusercontent.com/a3ilson/pfelk/master/conf.d/10-pf.conf
sudo wget https://raw.githubusercontent.com/a3ilson/pfelk/master/conf.d/11-firewall.conf
sudo wget https://raw.githubusercontent.com/a3ilson/pfelk/master/conf.d/50-outputs.conf
sudo wget https://raw.githubusercontent.com/a3ilson/pfelk/master/conf.d/12-suricata.conf
sudo wget https://raw.githubusercontent.com/a3ilson/pfelk/master/conf.d/13-snort.conf
sudo wget https://raw.githubusercontent.com/a3ilson/pfelk/master/conf.d/15-others.conf
mkdir /etc/logstash/conf.d/patterns
cd /etc/logstash/conf.d/patterns/
sudo wget https://raw.githubusercontent.com/a3ilson/pfelk/master/conf.d/patterns/pf-09.2019.grok


#check local IP
ip=$(eval "ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'")


#configure kibana
sed -i "s/#server.port: 5601/server.port: 5601/g" /etc/kibana/kibana.yml
sed -i "s/#server.host/server.host/g" /etc/kibana/kibana.yml
sed -i "s/localhost/$ip/g" /etc/kibana/kibana.yml

#configure logstash
clear
echo '-------------------------'
echo '-------------------------'
echo '-------------------------'
read -p 'Enter your pfSense IP address: ' pfip
pfip=$(eval echo $pfip | sed 's/\./\\\\\\./g')
sed -i "s/172\\\.22\\\.33\\\.1/$pfip/g" /etc/logstash/conf.d/05-syslog.conf


#start services on boot
/bin/systemctl daemon-reload
/bin/systemctl enable elasticsearch.service
/bin/systemctl enable kibana.service
/bin/systemctl enable logstash.service

#configure firewall
systemctl stop firewalld
systemctl disable firewalld

#start services
systemctl start elasticsearch 
systemctl start kibana 
systemctl start logstash 

clear
echo
echo '-------------------------'
echo "Install has completed."
echo "You must configure pfSense to forward logs to $ip:5140"
echo "ELK is now running, you can access it at $ip:5601"
echo '-------------------------'
