import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Untuk simpan status
import 'package:sikatu/main.dart'; // Untuk akses themeNotifier
import 'package:sikatu/screens/edit_profile_screen.dart';
import 'package:sikatu/screens/privacy_screen.dart';
import 'package:sikatu/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // State untuk Toggle Notifikasi
  bool reminderD3 = true;
  bool reminderD1 = true;
  bool taskCompletion = false;

  // Cek Status Dark Mode
  bool get isLightMode => themeNotifier.value == ThemeMode.light;

  final Color activeColor = const Color(0xFFA0C878); // Warna Hijau

  @override
  void initState() {
    super.initState();
    _loadSettings(); // Load pengaturan saat halaman dibuka
  }

  // --- 1. LOAD & SAVE SETTINGS (Agar tidak reset) ---
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      reminderD3 = prefs.getBool('reminderD3') ?? true;
      reminderD1 = prefs.getBool('reminderD1') ?? true;
      taskCompletion = prefs.getBool('taskCompletion') ?? false;

      // Sinkronisasi tombol dark mode dengan tema aplikasi saat ini
      // (Opsional, karena themeNotifier sudah handle global state)
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // --- WIDGET HELPER ---
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 25.0, bottom: 10.0, left: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, {VoidCallback? onTap, Widget? trailing}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final iconColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;

    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      trailing: trailing ??
          (onTap != null
              ? Icon(Icons.arrow_forward_ios, size: 16, color: iconColor)
              : null),
      onTap: onTap,
    );
  }

  Widget _buildToggleTile(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return _buildListTile(
      icon,
      title,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        // Properti terbaru Flutter (menggantikan activeColor yang deprecated)
        activeThumbColor: activeColor,
        activeTrackColor: activeColor.withAlpha(100),
        inactiveThumbColor: Colors.grey,
        inactiveTrackColor: Colors.grey.shade300,
      ),
    );
  }

  // --- 2. LOGIKA SECURITY: GANTI PASSWORD (FULL) ---
  void _showChangePasswordDialog() {
    final TextEditingController currentPassController = TextEditingController();
    final TextEditingController newPassController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF2C3E50) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text("Change Password", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "For security, please enter your current password first.",
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[300] : Colors.grey[600]),
                  ),
                  const SizedBox(height: 15),

                  // Input Password Lama
                  TextField(
                    controller: currentPassController,
                    obscureText: true,
                    enabled: !isLoading,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: const InputDecoration(
                      labelText: "Current Password",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Input Password Baru
                  TextField(
                    controller: newPassController,
                    obscureText: true,
                    enabled: !isLoading,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: const InputDecoration(
                      labelText: "New Password",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.key),
                    ),
                  ),

                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 15.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
              actions: [
                if (!isLoading)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                  ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: activeColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: isLoading ? null : () async {
                    if (currentPassController.text.isEmpty || newPassController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
                      return;
                    }
                    if (newPassController.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("New password must be at least 6 characters")));
                      return;
                    }

                    setState(() => isLoading = true);

                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null && user.email != null) {
                        // Re-authenticate
                        final cred = EmailAuthProvider.credential(
                          email: user.email!,
                          password: currentPassController.text,
                        );
                        await user.reauthenticateWithCredential(cred);

                        // Update Password
                        await user.updatePassword(newPassController.text);

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Password changed successfully!"), backgroundColor: Colors.green),
                          );
                        }
                      }
                    } on FirebaseAuthException catch (e) {
                      setState(() => isLoading = false);
                      String message = "Error changing password";
                      if (e.code == 'wrong-password') message = "Current password is incorrect.";
                      else if (e.code == 'weak-password') message = "New password is too weak.";

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
                      }
                    }
                  },
                  child: const Text("Save", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- 3. LOGIKA NOTIFICATION SETTINGS (FULL) ---
  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Notification Preferences", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text("To ensure you receive reminders for D-3 and D-1, please allow notifications in your device settings."),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: activeColor),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please open Device Settings to enable notifications.")));
                  },
                  child: const Text("Open Device Settings", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // --- 4. LOGIKA REPORT (FULL) ---
  void _showReportDialog() {
    final TextEditingController reportController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF2C3E50) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text("Report a Problem", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Describe the issue or bug you encountered:",
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[300] : Colors.grey[600]),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: reportController,
                    maxLines: 4,
                    enabled: !isLoading,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: const InputDecoration(
                      hintText: "Type your issue here...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: CircularProgressIndicator(),
                    )
                ],
              ),
              actions: [
                if (!isLoading)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                  ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: activeColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: isLoading ? null : () async {
                    if (reportController.text.isEmpty) return;

                    setState(() => isLoading = true);

                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      await FirebaseFirestore.instance.collection('reports').add({
                        'userId': user?.uid ?? 'anonymous',
                        'email': user?.email ?? 'anonymous',
                        'issue': reportController.text,
                        'timestamp': FieldValue.serverTimestamp(),
                        'device': 'Android/iOS',
                      });

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Report sent. Thank you!"), backgroundColor: Colors.green),
                        );
                      }
                    } catch (e) {
                      setState(() => isLoading = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Failed to send: $e"), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  child: const Text("Send", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? const Color(0xFF1F2937) : const Color(0xFFF5F5F5);
    final Color cardColor = isDark ? const Color(0xFF2C3E50) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
            'Settings',
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1F2937), fontWeight: FontWeight.bold)
        ),
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // SECTION 1: ACCOUNT
          _buildSectionHeader('Account'),
          Container(
            color: cardColor,
            child: Column(
              children: [
                _buildListTile(Icons.person_outline, 'Edit profile',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                  },
                ),
                _buildListTile(Icons.lock_reset, 'Security (Change Password)',
                  onTap: _showChangePasswordDialog, // Sekarang method ini ada
                ),
                _buildListTile(Icons.notifications_none_outlined, 'Notifications Settings',
                  onTap: _showNotificationSettings, // Sekarang method ini ada
                ),
                _buildListTile(Icons.privacy_tip_outlined, 'Privacy Policy',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyScreen()));
                  },
                ),
              ],
            ),
          ),

          // SECTION 2: NOTIFICATION TOGGLES
          _buildSectionHeader('Notification Toggles'),
          Container(
            color: cardColor,
            child: Column(
              children: [
                _buildToggleTile(Icons.calendar_today, 'Reminder: Deadline D-3', reminderD3, (value) {
                  setState(() => reminderD3 = value);
                  _saveSetting('reminderD3', value); // Save
                }),
                _buildToggleTile(Icons.event_busy, 'Reminder: Deadline D-1', reminderD1, (value) {
                  setState(() => reminderD1 = value);
                  _saveSetting('reminderD1', value); // Save
                }),
                _buildToggleTile(Icons.task_alt, 'Task Completion Notification', taskCompletion, (value) {
                  setState(() => taskCompletion = value);
                  _saveSetting('taskCompletion', value); // Save (Ini yang dipanggil di Task Detail)
                }),
              ],
            ),
          ),

          // SECTION 3: THEME
          _buildSectionHeader('Theme'),
          Container(
            color: cardColor,
            child: Column(
              children: [
                _buildToggleTile(
                    Icons.dark_mode_outlined,
                    'Dark Mode',
                    !isLightMode,
                        (value) {
                      themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                      _saveSetting('isDarkMode', value); // Save Theme Preference
                    }
                ),
              ],
            ),
          ),

          // SECTION 4: ACTIONS
          _buildSectionHeader('Actions'),
          Container(
            color: cardColor,
            child: Column(
              children: [
                _buildListTile(Icons.flag_outlined, 'Report a problem',
                  onTap: _showReportDialog, // Method ini sekarang ada
                ),
                _buildListTile(Icons.logout_outlined, 'Log out',
                  onTap: () {
                    AuthService.signOut(context);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}