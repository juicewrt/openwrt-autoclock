#!/bin/bash
# autoclock.sh — sinkron waktu dari XL via HTTP (tanpa restart service)
# by ChatGPT v4.5 — auto cron + auto startup (rc.local)

HOST=${1:-"xl.co.id"}
TMP="/tmp/dateheader.txt"
LOG="/tmp/autoclock.log"
RC="/etc/rc.local"

# 🔄 Kosongkan log setiap kali script dijalankan (mencegah log menumpuk)
truncate -s 0 "$LOG" 2>/dev/null || :

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"; }

log "== AutoClock start, host: $HOST =="

# 🕒 Tambahkan cron otomatis setiap 30 menit jika belum ada
if ! crontab -l 2>/dev/null | grep -q "autoclock.sh"; then
  (crontab -l 2>/dev/null; echo "*/30 * * * * /usr/bin/autoclock.sh > /dev/null 2>&1") | crontab -
  log "✅ Cron job auto ditambahkan (setiap 30 menit)"
else
  log "🕒 Cron job sudah ada, dilewati"
fi

# 🧩 Tambahkan ke /etc/rc.local jika belum ada
if ! grep -q "autoclock.sh" "$RC" 2>/dev/null; then
  sed -i '/exit 0/d' "$RC" 2>/dev/null
  {
    echo ""
    echo "# AutoClock startup"
    echo "sleep 20"
    echo "/usr/bin/autoclock.sh &"
    echo "exit 0"
  } >> "$RC"
  chmod +x "$RC"
  log "✅ Ditambahkan ke /etc/rc.local (auto start saat boot)"
else
  log "🧭 Sudah ada di /etc/rc.local, dilewati"
fi

# 🧭 Deteksi timezone lokal
if [ -f /etc/config/system ]; then
  TZ_CODE=$(grep 'option timezone' /etc/config/system | awk '{print $3}' | tr -d "'")
  case "$TZ_CODE" in
    Asia/Jakarta) ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime; ZONE="WIB";;
    Asia/Makassar) ln -sf /usr/share/zoneinfo/Asia/Makassar /etc/localtime; ZONE="WITA";;
    Asia/Jayapura) ln -sf /usr/share/zoneinfo/Asia/Jayapura /etc/localtime; ZONE="WIT";;
    *) ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime; ZONE="WIB";;
  esac
else
  ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
  ZONE="WIB"
fi
log "Detected timezone: $ZONE"

# 🏓 Ping ke XL
if ! ping -c1 -W1 "$HOST" >/dev/null 2>&1; then
  log "❌ Tidak bisa ping $HOST"
  exit 1
fi
log "✅ Ping ke $HOST sukses"

# 🌐 Ambil header Date (termasuk jika ada spasi di depan)
wget --max-redirect=5 --server-response -qO- "http://$HOST" 2>&1 | grep -i "Date:" | head -n1 > "$TMP"

if [ ! -s "$TMP" ]; then
  log "❌ Gagal ambil header Date dari $HOST"
  exit 1
fi

DATE_LINE=$(cat "$TMP")
log "✅ Header Date: $DATE_LINE"

# 🔍 Parsing tanggal dari header
hari=$(echo "$DATE_LINE" | cut -b 12-13)
bulan=$(echo "$DATE_LINE" | cut -b 15-17)
tahun=$(echo "$DATE_LINE" | cut -b 19-22)
jam=$(echo "$DATE_LINE" | cut -b 24-25)
menit=$(echo "$DATE_LINE" | cut -b 26-31)

case $bulan in
  Jan) bulan="01";; Feb) bulan="02";; Mar) bulan="03";;
  Apr) bulan="04";; May) bulan="05";; Jun) bulan="06";;
  Jul) bulan="07";; Aug) bulan="08";; Sep) bulan="09";;
  Oct) bulan="10";; Nov) bulan="11";; Dec) bulan="12";;
esac

# 🕒 Set waktu sistem
date -s "$tahun-$bulan-$hari $jam$menit" >/dev/null 2>&1
log "🕒 Waktu diatur ke: $(date)"

rm -f "$TMP"
log "== AutoClock selesai =="
