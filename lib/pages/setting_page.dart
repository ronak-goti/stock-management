import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:practice/setting pages/personal_info.dart';
import '../model/signup_screen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = true;
  bool _notificationsEnabled = true;

  String userName = "User";
  String userEmail = "user@example.com";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("name") ?? "User";
      userEmail = prefs.getString("email") ?? "user@example.com";
    });
  }

  Future<void> _refreshProfile() async {
    await _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 1,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- Profile Header ---
            ListTile(
              leading: const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, color: Colors.white, size: 30),
              ),
              title: Text(
                userName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(userEmail),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PersonalInfo()),
                  );
                  _refreshProfile();
                },
              ),
            ),

            const Divider(height: 40),

            const Padding(
              padding: EdgeInsets.only(left: 8, bottom: 8),
              child: Text(
                'Settings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),

            // --- Main Settings Card ---
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Column(
                children: [
                  // Personal Info
                  _buildSimpleSettingItem(
                    title: 'Personal Info',
                    icon: Icons.person,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PersonalInfo()),
                      );
                      _refreshProfile();
                    },
                  ),
                  const Divider(height: 1, indent: 16),

                  // Notifications Toggle
                  SwitchListTile(
                    title: const Text('Notifications'),
                    secondary: const Icon(Icons.notifications, color: Colors.blue),
                    value: _notificationsEnabled,
                    onChanged: (val) {
                      setState(() {
                        _notificationsEnabled = val;
                      });
                    },
                  ),
                  const Divider(height: 1, indent: 16),

                  // Dark Mode Toggle
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    secondary: const Icon(Icons.dark_mode, color: Colors.blue),
                    value: _isDarkMode,
                    onChanged: (val) {
                      setState(() {
                        _isDarkMode = val;
                      });
                    },
                  ),
                  const Divider(height: 1, indent: 16),

                  // Help
                  _buildSimpleSettingItem(
                    title: 'Help & Support',
                    icon: Icons.help_outline,
                    onTap: () {
                      _showHelpDialog(context);
                    },
                  ),
                  const Divider(height: 1, indent: 16),

                  // Privacy
                  _buildSimpleSettingItem(
                    title: 'Privacy Center',
                    icon: Icons.privacy_tip,
                    onTap: () {
                      _showPrivacyDialog(context);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- Logout Button ---
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _showLogoutDialog(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListTile _buildSimpleSettingItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text(
            'For any assistance, contact us at:\n\n📧 support@ronak23.com\n📞 +91 93289 83161'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text(
            'We value your privacy. Your data is securely stored and never shared without consent.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SignUpScreen()),
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
