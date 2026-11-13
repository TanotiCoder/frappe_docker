# Thread ERP & Oxygan — Deployment & Command Handbook

**Owner:** Sai Dubey  
**Domain:** `oxygan.in`  
**Stack:** Frappe v16 + `sme_crm` (Thread ERP) + Docker  
**Status:** Local Testbed (`oxygan-bench:16`) Live & Running 🎉  

---

## 1. High-Level Architecture (Kitchen vs Factory vs Delivery)

```
┌────────────────────────────────────────────────────────┐
│ 1. Native Bench (~/Documents/frappe/ThreadERP/...)     │
│    -> KITCHEN (Development)                            │
│    -> Jahan aap code likhte ho, naye DocTypes banate ho│
└──────────────────────────┬─────────────────────────────┘
                           │ git push / git pull
                           ▼
┌────────────────────────────────────────────────────────┐
│ 2. Frappe Docker (~/Documents/frappe/frappe_docker)    │
│    -> FACTORY (Packaging)                              │
│    -> Aapke code ko `oxygan-bench:16` image me pack     │
│       karta hai                                        │
└──────────────────────────┬─────────────────────────────┘
                           │ docker compose
                           ▼
┌────────────────────────────────────────────────────────┐
│ 3. Containers & Hostinger VPS (Production Server)      │
│    -> DELIVERY (Customers / Shops)                     │
│    -> MariaDB + Redis + Nginx + Multi-tenancy          │
│    -> oxygan.in (shop1.oxygan.in, shop2.oxygan.in)     │
└────────────────────────────────────────────────────────┘
```

---

## 2. Multi-Tenancy Secret: Bina Naya Server Lagaye 10+ Dukaane Kaise Chalti Hain?

Ye Frappe ka sabse smart feature hai. Samajhte hain under the hood kya hota hai:

### Ek Hi Stack (Same Server, Same Containers):
- **1 Python Backend** (Gunicorn)
- **1 MariaDB Database** (MariaDB 11.8)
- **1 Redis**
- **1 Nginx Web Server** (Port 8080)

### Dukaano Ka Data Alag Kaise Rehta Hai?
Jab aap naye customer ki dukaan banate ho (`shop1.oxygan.in`):
1. **Isolated Database:** MariaDB ke andar ek naya alag database banta hai (jaise `_shop1_db`) jiska alag password hota hai.
2. **Isolated Files:** `sites/shop1.oxygan.in/` folder banta hai jisme us dukaan ke files, logos, aur receipts rehte hain.
3. **Shop 1 aur Shop 2 ka data kabhi mix nahi ho sakta.**

### Request Routing (Nginx ka Jadoo):
Jab koi mobile browser me kholta hai:
- `http://shop1.oxygan.in:8080` ➔ Nginx dekhta hai domain `shop1.oxygan.in` hai. Woh request ko `sites/shop1.oxygan.in` ke database se jod deta hai.
- `http://shop2.oxygan.in:8080` ➔ Nginx dekhta hai domain `shop2.oxygan.in` hai. Woh request ko `sites/shop2.oxygan.in` ke database se jod deta hai.

> **Extra Cost:** ₹0! Ek nayi dukaan banane me koi naya container ya RAM nahi lagta, bas database me kuch megabytes space lagta hai. Isliye 4GB ya 8GB VPS pe aaram se 15–20 dukaane chal sakti hain!

---

## 3. `newshop.sh` Script (1 Command me Nayi Dukaan)

Script path: `~/Documents/frappe/frappe_docker/newshop.sh`

### Usage:
```bash
cd ~/Documents/frappe/frappe_docker
./newshop.sh shop1.oxygan.in
```

### Is script me kya hota hai?:
1. Backend container ke andar `bench new-site shop1.oxygan.in` chalata hai.
2. MariaDB me automatically naya database create karta hai.
3. Us naye site par `sme_crm` (Thread ERP) app install karta hai.
4. Administrator password set karta hai aur live URL print karta hai.

---

## 4. Local Pe Multi-Tenancy Test Kaise Karein:

Kyunki abhi hum local laptop pe hain aur `oxygan.in` internet pe point nahi hai, to apne laptop ko sikhana padega ki `shop1.oxygan.in` mere hi laptop (`127.0.0.1`) par hai.

### Step 1: Laptop ke `/etc/hosts` me entry karo:
```bash
sudo sh -c 'echo "127.0.0.1 shop1.oxygan.in shop2.oxygan.in" >> /etc/hosts'
```

### Step 2: Nayi dukaan create karo:
```bash
cd ~/Documents/frappe/frappe_docker
./newshop.sh shop1.oxygan.in
```

### Step 3: Browser me open karo:
👉 **`http://shop1.oxygan.in:8080`**  
(Username: `Administrator`, Password: jo script ne print kiya).

---

## 5. Master Command Cheat-Sheet

| Command | Kahan Chalana Hai | Kaam |
|---|---|---|
| `git pull upstream sme-crm` | `ThreadERP/frappe-bench/apps/sme_crm` | GitHub se latest code pull karta hai |
| `./build.sh` | `frappe_docker/` | Nayi Docker Image (`oxygan-bench:16`) pack karta hai |
| `./newshop.sh <domain>` | `frappe_docker/` | 1 command me nayi dukaan create karta hai |
| `docker compose -f pwd.yml up -d` | `frappe_docker/` | Stack start karta hai |
| `docker compose -f pwd.yml down -v` | `frappe_docker/` | Sab clean wipe karke fresh start |
| `docker compose -f pwd.yml ps` | `frappe_docker/` | Containers ka live status check |
| `docker compose -f pwd.yml exec backend bench --site frontend migrate` | `frappe_docker/` | Live data bina delete kiye code upgrade |
