# Digital Forensics Research Repository

Kho lưu trữ nghiên cứu Digital Forensics, bao gồm đề tài chính về khôi phục dữ liệu Android và tuyển tập thực hành pháp y kỹ thuật số đa nền tảng.

---

## 📱 Đề tài nghiên cứu chính: Điều tra số trên Android: Khôi phục và tái dựng hành vi từ dữ liệu đã xóa

### Tổng quan
Đề tài tập trung vào việc chứng minh khả năng khôi phục dữ liệu đã xóa ở tầng logic trên Android Emulator, khai thác cơ chế SQLite (WAL/SHM) và tương quan đa nguồn artefact (OS logs, application data, filesystem).

### Thành phần chính
- **Báo cáo đề tài**: `Android_Forensics_Research_Report.pdf`
- **Bằng chứng số (Digital Evidence)**: `Forensic_Evidence/`
  - Android OS artefacts (nhiều mốc thời gian: Pre-Delete, Immediate, +5min, Post-Reboot)
  - Telegram application artefacts (database, logs, filesystem snapshots)
  - Kết quả phân tích (`03_analysis/`), báo cáo Chain of Custody & hash baseline (`99_reports/`)
- **Scripts tự động hóa**: `script/` (PowerShell cho thu thập, phân tích, so sánh pre/post)
- **Minh chứng trực quan**: `Screen Recordings/` (video demo quy trình)

### Phương pháp luận
- **Thu thập chứng cứ**: Thu thập đa mốc thời gian, mount read-only, hash SHA256, ghi nhận Chain of Custody chi tiết
- **Phân tích kỹ thuật**: Trích xuất SQLite (main + WAL/SHM), parsing logcat, đối chiếu pre/post deletion
- **Tái hiện sự kiện**: Xây dựng timeline, tương quan OS/application logs, định danh IOC (Indicators of Compromise)

### Đóng góp & kết quả
- Quy trình forensics chuẩn hóa cho Android Emulator có thể tái lập
- Chứng minh khôi phục thành công dữ liệu đã xóa từ WAL/SHM
- Bộ công cụ tự động hóa và dataset minh chứng đầy đủ

---

## 🔬 Tuyển tập thực hành Digital Forensics

### Tổng quan
Bộ tài liệu độc lập (`Digital_Forensics_Labs.pdf`) tổng hợp các bài lab thực hành DFIR trên đa nền tảng (Windows, Linux, Cloud), bao quát quy trình từ xử lý chứng cứ cơ bản đến điều tra phức tạp trên môi trường đám mây.

### Nội dung chi tiết

#### 🗂️ Week 1–2: Xử lý chứng cứ & Chuỗi bảo quản
Xử lý disk images (ewfacquire/ewfverify), hash verification, manifest tạo lập, phân tích event logs, disk geometry (mmls/fsstat/fls), chuyển đổi E01→RAW.

#### 💾 Week 3–4: Memory Forensics
RAM acquisition (Windows: Winpmem; Linux: LiME), phân tích với Volatility 3 & MemProcFS, điều tra hibernate/pagefile, trích xuất processes/network/registry artifacts.

#### 🌐 Week 5: Network & Application Forensics
Windows network forensics (DNS/DHCP/Firewall logs, beaconing detection), application forensics trên Apache/HTTPS (phát hiện SQLi/XSS/webshell upload), tái tạo timeline tấn công.

#### ☁️ Week 6: AWS Cloud Forensics
AWS CLI với SSO, EC2 instance forensics, snapshot → AMI → RAW export, phân tích filesystem read-only từ cloud images.

#### 🖥️ Week 7: Môi trường phân tích
Cấu hình và duy trì môi trường điều tra (Ubuntu/SSH), cài đặt forensic toolchain.

#### 🔐 Week 8: OpenStack Forensics
Điều tra đa tầng trên OpenStack: build-time artifacts (Dockerfile, Trivy), runtime artifacts (container inspect/logs/export), hosting artifacts (tcpdump/iptables/conntrack), cloud artifacts (network/security groups), storage artifacts (Cinder volumes), control plane inventory, niêm phong chứng cứ.

---

## 📂 Cấu trúc repository

```
.
├── Android_Forensics_Research_Report.pdf    # Báo cáo đề tài Android Emulator
├── Digital_Forensics_Labs.pdf               # Tuyển tập lab Digital Forensics
├── Forensic_Evidence/               # Artefacts từ đề tài chính
│   └── Case_2025-DFIR-ANDROID-001/
│       ├── OS_Evidence/
│       ├── Telegram_Evidence/
│       ├── 03_analysis/
│       └── 99_reports/
├── script/                          # Scripts tự động hóa (PowerShell)
└── Screen Recordings/               # Video minh họa đề tài
```

---

## 🛠️ Yêu cầu môi trường

### Đề tài Android Emulator
- Windows + PowerShell
- ewf-tools, The Sleuth Kit (mmls/fsstat/fls)
- SQLite CLI tools
- ADB/logcat (optional)

### Tuyển tập lab
- Volatility 3, MemProcFS
- Docker, Trivy, Cosign
- AWS CLI, OpenStack/MicroStack CLI
- Apache, tcpdump, iptables/nftables

---

## 🔄 Quy trình tái lập (Đề tài chính)

1. **Thu thập & bảo quản**: Chạy scripts trong `script/`, ghi hash/CoC vào `99_reports/`
2. **Phân tích**: Trích xuất DB (main+WAL/SHM), parsing logs, xuất CSV vào `03_analysis/`
3. **Tương quan**: Dựng timeline từ logcat/DB/filesystem artefacts
4. **Báo cáo**: Tổng hợp kết quả, niêm phong với hash verification

---

## ⚖️ Lưu ý pháp lý & đạo đức

Toàn bộ dữ liệu phục vụ mục đích học thuật và nghiên cứu. Nghiêm cấm sử dụng trái pháp luật. Tuân thủ Chain of Custody và xác minh tính toàn vẹn (hash) trong mọi giai đoạn.

---

## 📚 Trích dẫn

Nếu sử dụng tài liệu này trong nghiên cứu, vui lòng trích dẫn:

```
"Điều tra số trên Android: Khôi phục và tái dựng hành vi từ dữ liệu đã xóa"
Báo cáo: Android_Forensics_Research_Report.pdf
Repository: https://github.com/syxdepzai/Digital-Forensic
```

