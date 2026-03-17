# Simple Interest Calculator API

Calculate simple interest.

## Endpoint

### GET `/calculate`

**Parameters:**
- `principal` (required): Principal amount
- `rate` (required): Interest rate (%)
- `time` (required): Time period (years)

**Example Request:**
```
http://localhost:3019/calculate?principal=1000&rate=5&time=2
```

**Example Response:**
```json
{
  "principal": 1000,
  "rate": 5,
  "time": 2,
  "simpleInterest": 100,
  "total": 1100
}
```


🚀 DEVOPS68 - Simple Interest Calculator Deployment Guide
Student: Panuwat (Panuwat-JR)

Infrastructure: Microsoft Azure (Virtual Machine)

Project Type: Node.js API (Express)
Phase 1: Infrastructure Provisioning (Terraform)
ในส่วนนี้เป็นการใช้ Infrastructure as Code (IaC) เพื่อสร้างทรัพยากรบน Azure โดยอัตโนมัติ
1. Preparation: * ทำการ Fork โปรเจกต์จากอาจารย์มาที่ GitHub Account ของตนเอง

ติดตั้ง Terraform และ Azure CLI ในเครื่อง Local แล้วเอาไฟร์ terrafrom.exe มาใส่ในไฟร์เดอร์

2. Authentication: * รันคำสั่ง az login เพื่อเชื่อมต่อกับ Account ของมหาวิทยาลัย

3. Deployment:

รัน terraform init เพื่อเตรียม Provider

รัน terraform apply -auto-approve เพื่อสร้างทรัพยากรดังนี้:

Resource Group: RG-PANUW-DEVOPS68

VM Size: Standard_D2s_v3 (D-Series)

Networking: เปิด Port 22 (SSH) และ 80 (HTTP)
Phase 2: Server Configuration & Deployment
หลังจากได้เครื่อง VM มาแล้ว (IP: 20.9.69.174) ได้ทำการติดตั้ง Software Stack ดังนี้:

1. Environment Setup:

ติดตั้ง Node.js (v20) และ Nginx เพื่อทำหน้าที่เป็น Web Server

ติดตั้ง PM2 สำหรับจัดการ Process ของ Node.js ให้ทำงานตลอดเวลา

2. Application Deployment:

Clone โค้ดจาก GitHub Repository: https://github.com/Panuwat-JR/devops68-simple-interest.git

รัน npm install เพื่อติดตั้ง dependencies (Express)

สั่งรันแอปด้วย PM2: pm2 start index.js --name "devops-app"

3. Nginx Reverse Proxy Configuration:

ตั้งค่า Nginx ให้รับ Traffic จาก Port 80 และส่งต่อไปยัง Node.js ที่รันอยู่ที่ Port 3019

คอนฟิกไฟล์ /etc/nginx/sites-available/devops-app:

Nginx
location / {
    proxy_pass http://127.0.0.1:3019;
    proxy_set_header Host $host;
}

Phase 3: Verification & API Testing
โปรเจกต์นี้ทำงานเป็น REST API สำหรับคำนวณดอกเบี้ย (Simple Interest) โดยสามารถทดสอบได้ผ่าน URL ดังนี้:  Example URL: http://20.9.69.174/calculate?principal=1000&rate=5&time=2


<!-- code นี้เพื่อ Run Command Script -->

#!/bin/bash
# 1. อัปเดตระบบและติดตั้งเครื่องมือที่จำเป็น (Node.js v20, Nginx, Git)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get update
sudo apt-get install -y nodejs nginx git

# 2. จัดการโฟลเดอร์โปรเจกต์ (ลบของเก่าแล้วโหลดใหม่เพื่อให้ไฟล์สะอาดที่สุด)
cd /home/adminuser
sudo rm -rf devops68-simple-interest
git clone https://github.com/Panuwat-JR/devops68-simple-interest.git
cd devops68-simple-interest

# 3. สร้างไฟล์ index.js ทับอีกครั้งเพื่อให้มั่นใจว่าใช้พอร์ต 3019 ตามที่คุณต้องการ
cat <<EOF > index.js
const express = require('express');
const app = express();

app.get('/calculate', (req, res) => {
  const { principal, rate, time } = req.query;
  if (!principal || !rate || !time) return res.status(400).json({ error: 'Missing parameters' });
  
  const p = parseFloat(principal);
  const r = parseFloat(rate);
  const t = parseFloat(time);
  
  if (isNaN(p) || isNaN(r) || isNaN(t)) return res.status(400).json({ error: 'All parameters must be numbers' });
  
  const interest = (p * r * t) / 100;
  const total = p + interest;
  
  res.json({ 
    principal: p, 
    rate: r, 
    time: t, 
    simpleInterest: Math.round(interest * 100) / 100, 
    total: Math.round(total * 100) / 100 
  });
});

app.listen(3019, () => console.log('Simple Interest API on port 3019'));
EOF

# 4. ติดตั้ง Express (Library หลักที่ต้องใช้)
npm install express

# 5. ตั้งค่า Nginx ให้รับ Traffic จาก Port 80 ส่งเข้าหา Node.js ที่ Port 3019
sudo rm /etc/nginx/sites-enabled/default || true
cat <<EOF | sudo tee /etc/nginx/sites-available/devops-app
server {
    listen 80;
    location / {
        proxy_pass http://127.0.0.1:3019;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# 6. เปิดใช้งาน Config และ Restart Nginx
sudo ln -s /etc/nginx/sites-available/devops-app /etc/nginx/sites-enabled/ || true
sudo systemctl restart nginx

# 7. ใช้ PM2 รันแอปทิ้งไว้เพื่อให้ทำงานตลอดเวลา
sudo npm install -g pm2
pm2 delete devops-app || true
pm2 start index.js --name "devops-app"