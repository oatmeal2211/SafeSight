import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourcesPage extends StatelessWidget {
  const ResourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'RESOURCES',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFF000000),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('RESOURCES'),
            const SizedBox(height: 16),
            _buildResourceItem(
              context,
              'Campus Security',
              Icons.phone,
              () => _makePhoneCall('tel:+0000000000'),
            ),
            _buildDivider(),
            _buildResourceItem(
              context,
              'AED / First Aid Info',
              Icons.favorite,
              () => _showPlaceholderDialog(context, 'AED / First Aid Information'),
            ),
            _buildDivider(),
            _buildResourceItem(
              context,
              'Blue-Light Phones',
              Icons.phone_in_talk,
              () => _showPlaceholderDialog(context, 'Blue-Light Phones Locations'),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('PROFILE / SETTINGS'),
            const SizedBox(height: 16),
            _buildResourceItem(
              context,
              'Safe Word',
              Icons.key,
              () => _showPlaceholderDialog(context, 'Set Safe Word'),
            ),
            _buildDivider(),
            _buildToggleItem(context, 'Privacy', Icons.privacy_tip),
            _buildDivider(),
            _buildToggleItem(context, 'Notifications', Icons.notifications),
            _buildDivider(),
            _buildResourceItem(
              context,
              'Campus Verification',
              Icons.verified_user,
              () => _showPlaceholderDialog(context, 'Campus Verification'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF39FF14),
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildResourceItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF39FF14).withOpacity(0.2),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF39FF14).withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            icon,
            color: const Color(0xFF39FF14),
            size: 28,
          ),
        ),
        title: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF39FF14),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFF39FF14),
          size: 16,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  Widget _buildToggleItem(BuildContext context, String title, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF39FF14).withOpacity(0.2),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF39FF14).withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            icon,
            color: const Color(0xFF39FF14),
            size: 28,
          ),
        ),
        title: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF39FF14),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        trailing: Switch(
          value: true,
          onChanged: (value) {},
          activeColor: const Color(0xFF39FF14),
          activeTrackColor: const Color(0xFF39FF14).withOpacity(0.3),
          inactiveThumbColor: const Color(0xFF6E6E6E),
          inactiveTrackColor: const Color(0xFF6E6E6E).withOpacity(0.3),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: const Color(0xFF39FF14).withOpacity(0.2),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri.parse(phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _showPlaceholderDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF000000),
          title: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF39FF14),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          content: const Text(
            'This feature is coming soon!',
            style: TextStyle(
              color: Color(0xFF39FF14),
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Color(0xFF39FF14),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
