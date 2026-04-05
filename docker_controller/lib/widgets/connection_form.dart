import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../models/connection_config.dart';

class ConnectionForm extends StatelessWidget {
  final TextEditingController uriController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final AuthType selectedAuthType;
  final bool showAdvanced;
  final bool saveCredentials;
  final bool useTls;
  final ValueChanged<AuthType> onAuthTypeChanged;
  final ValueChanged<bool> onShowAdvancedChanged;
  final ValueChanged<bool> onSaveCredentialsChanged;
  final ValueChanged<bool> onUseTlsChanged;
  final bool stayLoggedIn;
  final ValueChanged<bool> onStayLoggedInChanged;

  const ConnectionForm({
    super.key,
    required this.uriController,
    required this.usernameController,
    required this.passwordController,
    required this.selectedAuthType,
    required this.showAdvanced,
    required this.saveCredentials,
    required this.useTls,
    required this.onAuthTypeChanged,
    required this.onShowAdvancedChanged,
    required this.onSaveCredentialsChanged,
    required this.onUseTlsChanged,
    required this.stayLoggedIn,
    required this.onStayLoggedInChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Docker API URI Field
        TextFormField(
          controller: uriController,
          decoration: InputDecoration(
            labelText: AppStrings.dockerApiUri,
            hintText: AppStrings.dockerApiUriHintIpPort,
            prefixIcon: const Icon(Icons.link),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppStrings.uriRequired;
            }
            final regex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}:\d{1,5}$');
            if (!regex.hasMatch(value.trim())) {
              return AppStrings.invalidIpPort;
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Auth Type Dropdown
        DropdownButtonFormField<AuthType>(
          initialValue: selectedAuthType,
          decoration: const InputDecoration(
            labelText: AppStrings.authType,
            prefixIcon: Icon(Icons.security),
          ),
          items: AuthType.values.map((type) {
            String label;
            switch (type) {
              case AuthType.none:
                label = AppStrings.authNone;
                break;
              case AuthType.basic:
                label = AppStrings.authBasic;
                break;
            }
            return DropdownMenuItem(
              value: type,
              child: Text(label),
            );
          }).toList(),
          onChanged: (type) {
            if (type != null) onAuthTypeChanged(type);
          },
        ),
        
        const SizedBox(height: 16),
        
        // Auth Fields based on selected type
        if (selectedAuthType == AuthType.basic) ...[
          TextFormField(
            controller: usernameController,
            decoration: const InputDecoration(
              labelText: AppStrings.username,
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppStrings.usernameRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: passwordController,
            decoration: const InputDecoration(
              labelText: AppStrings.password,
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppStrings.passwordRequired;
              }
              return null;
            },
          ),
        ],
        
        const SizedBox(height: 16),
        
        // Advanced Toggle
        ExpansionTile(
          title: Row(
            children: [
              const Icon(Icons.settings),
              const SizedBox(width: 8),
              Text(AppStrings.advanced),
            ],
          ),
          initiallyExpanded: showAdvanced,
          onExpansionChanged: onShowAdvancedChanged,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Stay Logged In Toggle
                  SwitchListTile(
                    title: const Text(AppStrings.stayLoggedIn),
                    subtitle: const Text(AppStrings.stayLoggedInSubtitle),
                    value: stayLoggedIn,
                    onChanged: onStayLoggedInChanged,
                  ),
                  
                  // TLS Certificates Toggle
                  SwitchListTile(
                    title: const Text(AppStrings.tlsCerts),
                    subtitle: const Text('Use TLS certificates for secure connection'),
                    value: useTls,
                    onChanged: onUseTlsChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
} 