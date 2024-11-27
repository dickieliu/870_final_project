
# **870 Final Project**

This project integrates **Cowrie**, **Fail2ban**, **ELK Stack**, and other tools to monitor and analyze SSH login attempts.

---

## **Prerequisites and Installation**

Before setting up, ensure the following tools and dependencies are installed:

### **System Requirements**
- **Ubuntu** (or a compatible Linux distribution)
- **Python 3** (for Cowrie and scripts)

### **Tools to Install**
1. **Cowrie**  
   Follow the installation guide:  
   [Cowrie Installation Guide](https://cowrie.readthedocs.io/en/latest/INSTALL.html#step-1-install-system-dependencies)  
   - Ensure `bin/cowrie` is configured with `AUTHBIND_ENABLED` set to true.  
   - Update `cowrie.cfg` to listen on port `22`:
     ```ini
     [ssh]
     listen_endpoints = tcp:22:interface=0.0.0.0
     ```

2. **ELK Stack (Elasticsearch, Logstash, Kibana, and Filebeat)**  
   Follow the configuration guide:  
   [ELK Configuration for Cowrie](https://cowrie.readthedocs.io/en/latest/elk/README.html#kibana-configuration)  
   - Place configuration files in their respective locations as detailed below.

3. **Fail2ban**  
   Install using:  
   ```bash
   sudo apt install fail2ban
   ```

4. **Nginx**  
   Install and configure for reverse proxy and secure connections:
   ```bash
   sudo apt install nginx
   ```
   Follow [Certbot Instructions](https://certbot.eff.org/instructions?ws=nginx&os=snap) for SSL certificates.

5. **NatApp** (optional)  
   Download from [NatApp Website](https://natapp.cn/member/dashborad).

---

## **Project Structure**

The following tree outlines the directory structure of this project:

```plaintext
.
├── config
│   ├── cowrie
│   │   └── cowrie.cfg
│   ├── elasticsearch
│   │   └── elasticsearch.yml
│   ├── fail2ban
│   │   └── jail.local
│   ├── filebeat
│   │   └── filebeat.yml
│   ├── kibana
│   │   └── kibana.yml
│   ├── logstash
│   │   └── logstash-cowrie.conf
│   ├── Nginx
│   │   └── nginx.conf
│   └── twilio
│       ├── twilio_alert.py
│       └── twilio-sms.conf
├── docker_ELK
└── helper_script
    ├── check_services.sh
    └── manage_services.sh
```

---

## **Configurations**

### **About the Configurations**
The files in the `config` directory are **copies** of the actual configuration files used for each tool. These are provided for reference and comparison (对比). Modify your real configuration files as needed based on the examples provided here.

### **File Mapping**
Below is the mapping of files in the `config` directory to their real destinations:

| **Tool**         | **Config File (in `config/`)**               | **Real Location**                                  |
|-------------------|---------------------------------------------|---------------------------------------------------|
| **Cowrie**        | `config/cowrie/cowrie.cfg`                  | `/home/seed/cowrie/etc/cowrie.cfg`               |
| **Elasticsearch** | `config/elasticsearch/elasticsearch.yml`    | `/etc/elasticsearch/elasticsearch.yml`           |
| **Fail2ban**      | `config/fail2ban/jail.local`                | `/etc/fail2ban/jail.local`                       |
| **Filebeat**      | `config/filebeat/filebeat.yml`              | `/etc/filebeat/filebeat.yml`                     |
| **Kibana**        | `config/kibana/kibana.yml`                  | `/etc/kibana/kibana.yml`                         |
| **Logstash**      | `config/logstash/logstash-cowrie.conf`      | `/etc/logstash/conf.d/logstash-cowrie.conf`      |
| **Nginx**         | `config/Nginx/nginx.conf`                   | `/etc/nginx/sites-available/reverse-proxy.conf`  |
| **Twilio**        | `config/twilio/twilio_alert.py`             | `/home/seed/cowrie/twilio_alert.py`              |
|                   | `config/twilio/twilio-sms.conf`             | `/etc/fail2ban/action.d/twilio-sms.conf`         |

---

## **Cowrie Configuration**

### **Key Commands**
- Start Cowrie:  
  ```bash
  /home/seed/cowrie/bin/cowrie start
  ```
- Stop Cowrie:  
  ```bash
  /home/seed/cowrie/bin/cowrie stop
  ```
- Check status:  
  ```bash
  /home/seed/cowrie/bin/cowrie status
  ```

### **Configuration Notes**
- Cowrie is set to listen on port `22`, while the real SSH service is moved to `8181`.

---

## **ELK: Checking Indices, Logs, and Login Attempts**

### **Elasticsearch**
1. **Check Indices**:  
   Use the following command to see all indices:  
   ```bash
   curl -X GET "localhost:9200/_cat/indices?v"
   ```
   Example Output:  
   ```plaintext
   health status index                    uuid                   pri rep docs.count docs.deleted store.size pri.store.size
   green  open   cowrie-logstash-2024.11.23 K12b...               1   0        100            0      1.1mb          1.1mb
   ```

2. **Search Logs**:  
   ```bash
   curl -X GET "localhost:9200/cowrie-logstash-*/_search?q=ssh"
   ```

3. **Reindex Logs**:  
   ```json
   POST /_reindex
   {
     "source": {
       "index": "cowrie-logstash-2024.11.04-000001"
     },
     "dest": {
       "index": "new-cowrie-logstash"
     }
   }
   ```

---

### **Kibana**
1. **Accessing Kibana**:  
   Visit your Kibana instance using the browser:  
   ```
   https://<your-domain-or-ip>:5601
   ```
   Use the default account credentials (update as necessary):  
   - Username: `admin_kibana`
   - Password: `<your-password>`

2. **Visualizing Login Attempts**:  
   - Go to **Dashboard** and set the filter to show events containing `"ssh"` in the `event.action` field.  
   - Create graphs to display login attempts, sources, and timestamps.

---

### **Logstash**
1. **Config Validation**:  
   Ensure the pipeline configuration is correct:
   ```bash
   sudo systemctl status logstash
   sudo journalctl -xe | grep logstash
   ```

---

### **Filebeat**
1. **Check Logs**:  
   ```bash
   sudo systemctl status filebeat
   sudo journalctl -xe | grep filebeat
   ```

2. **Resend Logs to Logstash**:  
   ```bash
   sudo filebeat -e -d "publish"
   ```

---

## **Fail2ban and Twilio**
Fail2ban protects SSH by banning IPs after repeated failed attempts. Twilio sends alerts for banned IPs.

### **Configuration**
Refer to the **real locations** above for Fail2ban and Twilio configurations.  

---

## **Nginx**
Used as a reverse proxy for external access and SSL termination.

### **Configuration Notes**
The provided `nginx.conf` file in the `config/Nginx/` folder is an example. Update `/etc/nginx/sites-available/reverse-proxy.conf` accordingly.

### **Future consideration**
Use docker to containerize everything (cowrie (maybe?), ELK, filebeat, nginx) to ease up the implmentation and migration.

