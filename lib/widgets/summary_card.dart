import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color backgroundColor;
  final Color countColor;
  final Color iconColor;

  const SummaryCard({
    super.key, // Gunakan super.key
    required this.title,
    required this.count,
    required this.icon,
    required this.backgroundColor,
    required this.countColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0, // Hilangkan bayangan
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade300, width: 1), // Border tipis
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Padding lebih kecil
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Agar elemen menyebar
          children: [
            // Baris Atas: Judul
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            // Baris Bawah: Angka dan Ikon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Lingkaran Angka
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: countColor.withOpacity(0.8), // Warna hijau dengan opacity
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Ikon
                Icon(
                  icon,
                  size: 30, // Ukuran ikon lebih besar
                  color: iconColor.withOpacity(0.9),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

