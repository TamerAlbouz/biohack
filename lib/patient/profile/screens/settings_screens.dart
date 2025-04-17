import 'package:flutter/material.dart';

import '../../../styles/colors.dart';
import '../../../styles/styles/button.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // Initialize with default values
  bool _appointmentReminders = true;
  bool _medicationReminders = true;
  bool _healthTips = false;
  bool _appUpdates = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Preferences"),
        backgroundColor: MyColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  ListTile(
                    title: const Text("Appointment Reminders"),
                    subtitle:
                        const Text("Get notified about upcoming appointments"),
                    trailing: Switch(
                      value: _appointmentReminders,
                      onChanged: (value) {
                        setState(() {
                          _appointmentReminders = value;
                        });
                      },
                      activeColor: MyColors.primary,
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text("Medication Reminders"),
                    subtitle: const Text(
                        "Get notified when it's time to take your medication"),
                    trailing: Switch(
                      value: _medicationReminders,
                      onChanged: (value) {
                        setState(() {
                          _medicationReminders = value;
                        });
                      },
                      activeColor: MyColors.primary,
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text("Health Tips"),
                    subtitle: const Text(
                        "Receive daily health tips and recommendations"),
                    trailing: Switch(
                      value: _healthTips,
                      onChanged: (value) {
                        setState(() {
                          _healthTips = value;
                        });
                      },
                      activeColor: MyColors.primary,
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text("App Updates"),
                    subtitle: const Text(
                        "Get notified about new app features and updates"),
                    trailing: Switch(
                      value: _appUpdates,
                      onChanged: (value) {
                        setState(() {
                          _appUpdates = value;
                        });
                      },
                      activeColor: MyColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Save notification settings
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Notification settings saved"),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: kElevatedButtonCommonStyle,
                  child: const Text("SAVE CHANGES"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. App Preferences Screen
class AppPreferencesScreen extends StatefulWidget {
  const AppPreferencesScreen({super.key});

  @override
  State<AppPreferencesScreen> createState() => _AppPreferencesScreenState();
}

class _AppPreferencesScreenState extends State<AppPreferencesScreen> {
  // Initialize with default values
  bool _darkMode = false;
  bool _enableSounds = true;
  bool _useBiometricAuth = false;
  String _selectedLanguage = "English";
  final List<String> _languages = [
    "English",
    "Spanish",
    "French",
    "German",
    "Chinese"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Preferences"),
        backgroundColor: MyColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  ListTile(
                    title: const Text("Dark Mode"),
                    subtitle: const Text("Enable dark theme for the app"),
                    trailing: Switch(
                      value: _darkMode,
                      onChanged: (value) {
                        setState(() {
                          _darkMode = value;
                        });
                      },
                      activeColor: MyColors.primary,
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text("Enable Sounds"),
                    subtitle: const Text("Play sounds for app interactions"),
                    trailing: Switch(
                      value: _enableSounds,
                      onChanged: (value) {
                        setState(() {
                          _enableSounds = value;
                        });
                      },
                      activeColor: MyColors.primary,
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text("Use Biometric Authentication"),
                    subtitle: const Text("Use fingerprint or face ID to login"),
                    trailing: Switch(
                      value: _useBiometricAuth,
                      onChanged: (value) {
                        setState(() {
                          _useBiometricAuth = value;
                        });
                      },
                      activeColor: MyColors.primary,
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Language"),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedLanguage,
                              items: _languages.map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedLanguage = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Save app preferences
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("App preferences saved"),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: kElevatedButtonCommonStyle,
                  child: const Text("SAVE CHANGES"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 3. Security Settings Screen
class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  // Initialize with default values
  bool _twoFactorAuth = false;
  bool _rememberLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Security Settings"),
        backgroundColor: MyColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  ListTile(
                    title: const Text("Two-Factor Authentication"),
                    subtitle: const Text(
                        "Add an extra layer of security to your account"),
                    trailing: Switch(
                      value: _twoFactorAuth,
                      onChanged: (value) {
                        setState(() {
                          _twoFactorAuth = value;
                        });

                        if (value) {
                          // Show setup dialog or navigate to setup screen for 2FA
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text(
                                  "Enable Two-Factor Authentication"),
                              content: const Text(
                                  "This feature requires additional setup. Would you like to proceed?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      _twoFactorAuth = false;
                                    });
                                  },
                                  child: const Text("CANCEL"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    // Keep the toggle on, would navigate to setup in a real app
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: MyColors.primary,
                                  ),
                                  child: const Text("CONTINUE"),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      activeColor: MyColors.primary,
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text("Remember Login"),
                    subtitle: const Text("Stay logged in on this device"),
                    trailing: Switch(
                      value: _rememberLogin,
                      onChanged: (value) {
                        setState(() {
                          _rememberLogin = value;
                        });
                      },
                      activeColor: MyColors.primary,
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text("Change Password"),
                    subtitle: const Text("Update your account password"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Navigate to change password screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Change Password feature coming soon"),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text("Privacy Settings"),
                    subtitle: const Text("Manage who can see your information"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Navigate to privacy settings
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Privacy Settings feature coming soon"),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Save security settings
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Security settings saved"),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: kElevatedButtonCommonStyle,
                  child: const Text("SAVE CHANGES"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
