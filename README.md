<h1 align="center">⚙️ juicewrt // autoclock.sh</h1>
<p align="center">
  <b>sinkronisasi waktu otomatis untuk openwrt & stb</b><br>
  <i>tanpa ntp, tanpa restart, ringan & mandiri ⚡</i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-v4.5-green?style=for-the-badge&logo=linux&logoColor=white">
  <img src="https://img.shields.io/badge/openwrt-compatible-blue?style=for-the-badge">
  <img src="https://img.shields.io/badge/autocron-enabled-orange?style=for-the-badge">
  <img src="https://img.shields.io/badge/startup-rc.local-yellow?style=for-the-badge">
</p>

---

## 🧠 Tentang
`autoclock.sh` adalah utilitas ringan buatan **juicewrt** untuk menjaga waktu sistem OpenWrt / STB tetap akurat tanpa perlu NTP.  
Script ini menggunakan **header HTTP dari provider untuk menyinkronkan waktu, sehingga tetap berfungsi meskipun:
- tidak ada koneksi NTP,
- tidak ada kuota data,
- atau injek belum aktif.

---

## 🚀 Fitur Utama
- 🕒 **Sync waktu dari XL (HTTP header Date)**  
- 🗺️ **Deteksi zona waktu otomatis (WIB / WITA / WIT)**  
- 🔁 **Auto-cron setiap 30 menit**  
- 🧩 **Auto startup di `/etc/rc.local`**  
- 🧹 **Auto truncate log setiap jalan**  
- 🛡️ **Tanpa restart service (aman untuk OpenClash, Passwall, Zerotier)**  
- ⚡ **Ringan dan mandiri — hanya butuh `wget` & `ping`**

---

## ⚙️ Instalasi
```bash
wget -O /usr/bin/autoclock.sh https://raw.githubusercontent.com/juicewrt/openwrt-autoclock/main/autoclock.sh
chmod +x /usr/bin/autoclock.sh
/usr/bin/autoclock.sh
