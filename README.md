# lapangin

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

# Lapangin

## Tahap I (20%)

- Pembuatan GitHub kelompok
- Pembuatan codebase kelompok
- README.md pada GitHub yang berisi:
  i. Daftar nama anggota kelompok  
  ii. Deskripsi aplikasi (nama dan fungsi aplikasi)  
  iii. Daftar modul yang diimplementasikan beserta pembagian kerja per anggota  
  iv. Peran atau aktor pengguna aplikasi  
  v. Alur pengintegrasian dengan web service untuk terhubung dengan aplikasi web yang sudah dibuat saat Proyek Tengah Semester  
  vi. Link Figma

---

## Nama Anggota Kelompok

1. Kenzie Nibras Tradezqi (2406414776)
2. Saikhah Ummu Anja Amalia (2406436045)
3. Syifa Anabella (2406417922)
4. Zibeon Jonriano Wisnumoerti (2406355634)
5. Faishal Khoiriansyah Wicaksono (2406436335)

---

## Deskripsi Aplikasi

**Lapangin** hadir dari frustasi nyata kami sebagai mahasiswa yang aktif dalam melakukan olahraga, khususnya futsal, basket, dan badminton. Kami memahami kesulitan menyeimbangkan jadwal kuliah yang padat dengan kebutuhan berolahraga.

### Masalah yang Ingin Kami Atasi:

1. **Hambatan Jadwal yang Padat**  
   Kesulitan menemukan waktu untuk mengecek ketersediaan atau melakukan booking lapangan secara langsung.

2. **Respons Admin yang Lambat**  
   Admin sering tidak merespons dengan cepat, terutama pada jam sibuk.

3. **Proses Manual yang Tidak Efisien**  
   Proses booking dan konfirmasi yang masih manual rentan terhadap kesalahan seperti double booking.

### Solusi yang Ditawarkan:

- **Booking Cepat, Anti-Buang Waktu**  
  Melihat ketersediaan real-time tanpa harus menelepon atau datang langsung.

- **Konfirmasi Instan**  
  Setelah pembayaran digital berhasil, slot lapangan langsung dikonfirmasi.

- **Transparansi Penuh**  
  Pengguna dapat membandingkan harga, fasilitas, dan ulasan dari semua lapangan di satu tempat.

Tujuan utama kami adalah mengubah pengalaman booking lapangan yang penuh ketidakpastian menjadi semudah memesan makanan online.

---

## Daftar Modul yang Diimplementasikan

| Modul | Penanggung Jawab |
|--------|------------------|
| 1. Autentikasi (Login, Logout, Register, Role) | Zibeon |
| 2. Booking (Reservasi Lapangan) | Zibeon |
| 3. Review (Ulasan & Rating) | Syifa |
| 4. Gallery (Foto Lapangan) | Saikhah |
| 5. Community (Forum Komunitas) | Kenzie |
| 6. Admin-Dashboard (Manajemen Data) | Faishal |

---

## Peran atau Aktor Pengguna Aplikasi

### 1. Penyewa Lapangan
Pengguna yang telah login dan dapat mengakses fitur:
- Login & Logout
- Mengelola profil
- Booking lapangan
- Melihat riwayat booking
- Pembayaran
- Memberikan ulasan & rating
- Membaca ulasan
- Melihat galeri foto
- Melihat dan bergabung dengan komunitas
- Mengajukan permintaan komunitas baru

### 2. Pemilik Lapangan
Pengelola lapangan dengan akses:
- Login & Logout
- Mengelola jadwal booking
- Memoderasi ulasan
- Mengunggah dan menghapus foto galeri
- Menerima dan memproses permintaan komunitas
- Membuat dan mengelola komunitas

---

## Alur Pengintegrasian dengan Web Service

### 1. Pendahuluan
Aplikasi web Django yang telah dibuat pada PTS akan diintegrasikan dengan aplikasi mobile Flutter.

### 2. Persiapan Backend untuk Integrasi
- **2.1. Penyiapan Aplikasi Autentikasi**  
  Modul autentikasi disiapkan dengan endpoint untuk login, register, dan logout.

- **2.2. Penyesuaian Pengaturan Keamanan dan CORS**  
  Konfigurasi CORS disesuaikan agar Flutter dapat mengakses server Django.

- **2.3. Pembuatan Endpoint Autentikasi**  
  Endpoint untuk login, register, dan logout disediakan dengan respons JSON.

- **2.4. Penyediaan Endpoint Data**  
  Endpoint JSON disiapkan untuk menampilkan data lapangan, booking, ulasan, dll.

- **2.5. Pembuatan Endpoint Proxy untuk Gambar**  
  Endpoint proxy gambar dibuat untuk menghindari masalah CORS.

- **2.6. Pembuatan Endpoint Pengiriman Form dari Flutter**  
  Endpoint untuk menerima data dari Flutter dalam format JSON.

### 3. Integrasi pada Sisi Flutter
- **3.1. Penyediaan State Management melalui Provider**  
  Menggunakan Provider untuk mengelola status autentikasi.

- **3.2. Implementasi Halaman Autentikasi**  
  Halaman login dan register diimplementasikan.

- **3.3. Pemetaan Model JSON ke Model Dart**  
  Data JSON dari Django dipetakan ke model Dart.

- **3.4. Pengambilan Data dari Web Service**  
  Menggunakan FutureBuilder untuk mengambil dan menampilkan data.

- **3.5. Penanganan Gambar melalui Proxy**  
  Gambar dimuat melalui endpoint proxy Django.

- **3.6. Pengiriman Data Form ke Django**  
  Data form dikirim sebagai JSON ke endpoint Django.

- **3.7. Implementasi Fitur Logout**  
  Logout menghapus sesi dan mengarahkan pengguna ke halaman login.

### 4. Alur Integrasi Secara Keseluruhan
- Django menyediakan endpoint autentikasi dan data.
- Flutter mengelola sesi dengan Provider dan CookieRequest.
- Pengguna login via Flutter, Django mengembalikan cookie sesi.
- Flutter menggunakan cookie untuk mengakses endpoint lain.
- Gambar dimuat via proxy Django.
- Data baru dikirim via form Flutter ke Django.
- Logout menghapus sesi di Django.

### 5. Kesimpulan
Integrasi berhasil dilakukan dengan menyiapkan backend Django sebagai web service dan menyesuaikan Flutter untuk mengelola autentikasi dan komunikasi data.

---

## Link Figma

[https://www.figma.com/design/tns2TMUBqT8nJTY6pSLh3S/Lapangin?node-id=0-1&t=2Xltc6nUPHshY1KH-1](https://www.figma.com/design/tns2TMUBqT8nJTY6pSLh3S/Lapangin?node-id=0-1&t=2Xltc6nUPHshY1KH-1)


