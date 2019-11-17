# pfELK-centos

### Environment Setup
- Download CentOS Minimal (I used centos7-x86_64-minimal-1810.iso)
- Create VM with minimum 2gb Ram 1 CPU (recommended 3gb ram, 2 CPU)
- Give the VM enough storage to handle the data you want to send + 3.5gbs for instillation. (I experience about 150mb of data per day)
- I strongly recommend setting up a private IP in either DCHP or on the CentOS VM itself

### 1. Install ELK:
 - Durring install you will be prompted for your pfSense IP address. If you have multiple VLANs make sure you know the IP it will be forwarding logs from.
 - This install script will automattically configure your ELK files to match your current local IP address. Make sure it is static before you install.
```
yum install wget
sudo wget -O - https://raw.githubusercontent.com/pclever1/pfELK-centos/master/install.sh | bash <(cat) </dev/tty
```

### 2. Login to pfSense and Forward syslogs
- In pfSense navigate to Status->System Logs, then click on Settings.
- At the bottom check "Enable Remote Logging"
- (Optional) Select a specific interface to use for forwarding
- Enter the ELK local IP into the field "Remote log servers" with port 5140
- Under "Remote Syslog Contents" check "Everything"
- Click Save

### 3. Set-up Kibana
- In your web browser go to the ELK local IP using port 5601
- Click the gear icon in the bottom left
- Click Kibana -> Index Patters
- Click Create New Index Pattern
- Type "pf*" into the input box, then click Next Step
- In the Time Filter drop down select "@timestamp"
- Click Create then verify you have data showing up under the Discover tab


### 4. Optional: Set up IDS/IPS
- Choose between Snort and Suricata (Snort Recommended)

### 4a. Snort
- In pfSense navigate to System->Package Manager
- Click Available Packages, search for and install Snort
- Navigate to Services->Snort 
- Click "Global Settings" then enable your perfered rule lists
- Click "Snort Interfaces" and add your interfaces
- When adding interfaces check the box "Send Alerts to System Log"
- For each interface do the following:
- Under the categories tab, check "Use IPS Policy" then select the drop down value "Security"
- Under the Preprocs tab, check "Auto Rule Disable" and Enable "Application ID Detection"
- After adding all interfaces click on "Logs Mgmt"
- Enable Directory Size Limit

### 4b. Suricata
- In pfSense navigate to System->Package Manager
- Click Available Packages, search for and install Suricata
- Navigate to Services->Suricata and add your interfaces
- When adding interfaces check the box "EVE JSON Log"
- Also set "EVE Output Type" to "SYSLOG"
- After adding all interfaces click on "Logs Mgmt"
- Enable Directory Size Limit
- Click "Global Settings" then enable your perfered rule lists


### Troubleshooting
- Restart services:
```
systemctl stop elasticsearch 
systemctl stop kibana 
systemctl stop logstash 
systemctl start elasticsearch 
systemctl start kibana 
systemctl start logstash 
```

- Check logs for errors:
```
sudo vi /var/log/logstash/logstash-plain.log
sudo vi /var/log/elasticsearch/elasticsearch.log
(Press Shift + G to scroll to bottom, Escape then type ":q!" to exit)
```
