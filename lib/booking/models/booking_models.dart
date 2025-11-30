// lib/booking/models/booking_models.dart

class Lapangan {
  final int id;
  final String namaLapangan;
  final String jenisOlahraga;
  final String lokasi;
  final double hargaPerJam;
  final String fasilitas;
  final double rating;
  final int jumlahUlasan;
  final String? fotoUtama;
  final String? foto2;
  final String? foto3;
  final String deskripsi;
  final Pengelola? pengelola;

  Lapangan({
    required this.id,
    required this.namaLapangan,
    required this.jenisOlahraga,
    required this.lokasi,
    required this.hargaPerJam,
    required this.fasilitas,
    required this.rating,
    required this.jumlahUlasan,
    this.fotoUtama,
    this.foto2,
    this.foto3,
    required this.deskripsi,
    this.pengelola,
  });

  factory Lapangan.fromJson(Map<String, dynamic> json) {
    return Lapangan(
      id: json['id'],
      namaLapangan: json['nama_lapangan'],
      jenisOlahraga: json['jenis_olahraga'],
      lokasi: json['lokasi'],
      hargaPerJam: (json['harga_per_jam'] as num).toDouble(),
      fasilitas: json['fasilitas'] ?? '-',
      rating: (json['rating'] as num).toDouble(),
      jumlahUlasan: json['jumlah_ulasan'],
      fotoUtama: json['foto_utama'],
      foto2: json['foto_2'],
      foto3: json['foto_3'],
      deskripsi: json['deskripsi'] ?? '',
      pengelola: json['pengelola'] != null 
          ? Pengelola.fromJson(json['pengelola']) 
          : null,
    );
  }
}

class Pengelola {
  final String? username;
  final String? nomorWhatsapp;

  Pengelola({this.username, this.nomorWhatsapp});

  factory Pengelola.fromJson(Map<String, dynamic> json) {
    return Pengelola(
      username: json['username'],
      nomorWhatsapp: json['nomor_whatsapp'],
    );
  }
}

class BookingSlot {
  final int id;
  final String jamMulai;
  final String jamAkhir;
  final String status; // AVAILABLE, PENDING, BOOKED
  final double harga;

  BookingSlot({
    required this.id,
    required this.jamMulai,
    required this.jamAkhir,
    required this.status,
    required this.harga,
  });

  factory BookingSlot.fromJson(Map<String, dynamic> json) {
    return BookingSlot(
      id: json['id'],
      jamMulai: json['jam_mulai'],
      jamAkhir: json['jam_akhir'],
      status: json['status'],
      harga: (json['harga'] as num).toDouble(),
    );
  }

  bool get isAvailable => status == 'AVAILABLE';
  bool get isPending => status == 'PENDING';
  bool get isBooked => status == 'BOOKED';
}

class BookingSlotsResponse {
  final int lapanganId;
  final String lapanganNama;
  final double hargaPerJam;
  final Map<String, List<BookingSlot>> slotsByDate;

  BookingSlotsResponse({
    required this.lapanganId,
    required this.lapanganNama,
    required this.hargaPerJam,
    required this.slotsByDate,
  });

  factory BookingSlotsResponse.fromJson(Map<String, dynamic> json) {
    Map<String, List<BookingSlot>> slotsMap = {};
    
    if (json['slots_by_date'] != null) {
      Map<String, dynamic> slotsData = json['slots_by_date'];
      slotsData.forEach((date, slots) {
        slotsMap[date] = (slots as List)
            .map((slot) => BookingSlot.fromJson(slot))
            .toList();
      });
    }

    return BookingSlotsResponse(
      lapanganId: json['lapangan_id'],
      lapanganNama: json['lapangan_nama'],
      hargaPerJam: (json['harga_per_jam'] as num).toDouble(),
      slotsByDate: slotsMap,
    );
  }
}

class Booking {
  final int id;
  final LapanganInfo lapangan;
  final SlotInfo slot;
  final String tanggalBooking;
  final double totalBayar;
  final String statusPembayaran;
  final String statusPembayaranDisplay;
  final int? timeRemainingSeconds;
  final PemilikInfo? pemilik;

  Booking({
    required this.id,
    required this.lapangan,
    required this.slot,
    required this.tanggalBooking,
    required this.totalBayar,
    required this.statusPembayaran,
    required this.statusPembayaranDisplay,
    this.timeRemainingSeconds,
    this.pemilik,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      lapangan: LapanganInfo.fromJson(json['lapangan']),
      slot: SlotInfo.fromJson(json['slot']),
      tanggalBooking: json['tanggal_booking'],
      totalBayar: (json['total_bayar'] as num).toDouble(),
      statusPembayaran: json['status_pembayaran'],
      statusPembayaranDisplay: json['status_pembayaran_display'],
      timeRemainingSeconds: json['time_remaining_seconds'],
      pemilik: json['pemilik'] != null 
          ? PemilikInfo.fromJson(json['pemilik']) 
          : null,
    );
  }

  bool get isPending => statusPembayaran == 'PENDING';
  bool get isPaid => statusPembayaran == 'PAID';
  bool get isCancelled => statusPembayaran == 'CANCELLED';
}

class LapanganInfo {
  final int id;
  final String nama;
  final String lokasi;
  final String? fotoUtama;

  LapanganInfo({
    required this.id,
    required this.nama,
    required this.lokasi,
    this.fotoUtama,
  });

  factory LapanganInfo.fromJson(Map<String, dynamic> json) {
    return LapanganInfo(
      id: json['id'],
      nama: json['nama'],
      lokasi: json['lokasi'],
      fotoUtama: json['foto_utama'],
    );
  }
}

class SlotInfo {
  final String tanggal;
  final String jamMulai;
  final String jamAkhir;

  SlotInfo({
    required this.tanggal,
    required this.jamMulai,
    required this.jamAkhir,
  });

  factory SlotInfo.fromJson(Map<String, dynamic> json) {
    return SlotInfo(
      tanggal: json['tanggal'],
      jamMulai: json['jam_mulai'],
      jamAkhir: json['jam_akhir'],
    );
  }
}

class PemilikInfo {
  final String? nomorRekening;
  final String? nomorWhatsapp;

  PemilikInfo({this.nomorRekening, this.nomorWhatsapp});

  factory PemilikInfo.fromJson(Map<String, dynamic> json) {
    return PemilikInfo(
      nomorRekening: json['nomor_rekening'],
      nomorWhatsapp: json['nomor_whatsapp'],
    );
  }
}