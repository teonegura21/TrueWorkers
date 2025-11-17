import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // Notification preferences
  bool _newJobAlerts = true;
  bool _offerAccepted = true;
  bool _contractSigned = true;
  bool _paymentReceived = true;
  bool _newMessages = true;
  bool _projectUpdates = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSettingsSection(
            'Job Alerts',
            [
              _buildSwitchListTile(
                'New Job Alerts',
                'Receive notifications about new job opportunities',
                _newJobAlerts,
                (value) => setState(() => _newJobAlerts = value),
              ),
            ],
          ),
          _buildSettingsSection(
            'Project & Contract',
            [
              _buildSwitchListTile(
                'Contract Signed',
                'When a contract is signed',
                _contractSigned,
                (value) => setState(() => _contractSigned = value),
              ),
              _buildSwitchListTile(
                'Project Updates',
                'Progress updates on your projects',
                _projectUpdates,
                (value) => setState(() => _projectUpdates = value),
              ),
            ],
          ),
          _buildSettingsSection(
            'Messages & Communications',
            [
              _buildSwitchListTile(
                'New Messages',
                'When you receive new messages',
                _newMessages,
                (value) => setState(() => _newMessages = value),
              ),
            ],
          ),
          _buildSettingsSection(
            'Payments',
            [
              _buildSwitchListTile(
                'Payment Received',
                'When payment is received',
                _paymentReceived,
                (value) => setState(() => _paymentReceived = value),
              ),
            ],
          ),
          _buildSettingsSection(
            'Offers',
            [
              _buildSwitchListTile(
                'Offer Accepted',
                'When your offer is accepted',
                _offerAccepted,
                (value) => setState(() => _offerAccepted = value),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchListTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: (bool newValue) {
        // Here you would typically update the user's notification preferences
        // via an API call to save the preference
        print('Notification preference changed: $title = $newValue');
        onChanged(newValue);
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}