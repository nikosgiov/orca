import 'package:docker_controller/constants/app_colors.dart';
import 'package:docker_controller/constants/app_delays.dart';
import 'package:docker_controller/constants/app_dimensions.dart';
import 'package:docker_controller/constants/app_gradients.dart';
import 'package:docker_controller/constants/app_text_styles.dart';
import 'package:docker_controller/models/connection_config.dart';
import 'package:docker_controller/providers/auth_provider.dart';
import 'package:docker_controller/utils/validators.dart';
import 'package:docker_controller/widgets/animated_orca.dart';
import 'package:docker_controller/widgets/app_input_field.dart';
import 'package:docker_controller/widgets/app_input_tile.dart';
import 'package:docker_controller/widgets/app_modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import 'connection/advanced_drawer.dart';
import 'connection/auth_drawer.dart';
import 'connection/connection_history_drawer.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _uriController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  AuthType _selectedAuthType = AuthType.none;
  bool _stayLoggedIn = false;
  bool _useTls = false;

  late AnimationController _taglineController;
  late AnimationController _formController;
  late AnimationController _buttonController;

  String? _authError;

  @override
  void initState() {
    super.initState();
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadSavedConfig();
        _startAnimations();
      }
    });
  }

  void _startAnimations() async {
    if (!mounted) {
      return;
    }
    try {
      await Future.delayed(AppDelays.connectionAnimStep1);
      if (!mounted) {
        return;
      }

      await _taglineController.forward();
      await Future.delayed(AppDelays.connectionAnimStep1);
      if (!mounted) {
        return;
      }

      await _formController.forward();
      await Future.delayed(AppDelays.connectionAnimStep2);
      if (!mounted) {
        return;
      }

      await _buttonController.forward();
    } catch (_) {}
  }

  void _loadSavedConfig() {
    final savedConfig = context.read<AuthProvider>().connectionConfig;
    if (savedConfig != null) {
      _uriController.text = savedConfig.uri;
      _selectedAuthType = savedConfig.authType;
      _useTls = savedConfig.useTls;
    }
  }

  @override
  void dispose() {
    _taglineController.dispose();
    _formController.dispose();
    _buttonController.dispose();
    _uriController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    String? authError;
    if (_selectedAuthType == AuthType.basic) {
      authError = Validators.validateUsername(
            _usernameController.text,
            requiredError: AppLocalizations.of(context)!.usernameRequired,
          ) ??
          Validators.validatePassword(
            _passwordController.text,
            requiredError: AppLocalizations.of(context)!.passwordRequired,
          );
    }
    if (authError != null) {
      setState(() => _authError = authError);
      _showAuthDrawer();
      return;
    }
    setState(() => _authError = null);

    final config = ConnectionConfig(
      uri: _uriController.text.trim(),
      authType: _selectedAuthType,
      useTls: _useTls,
    );

    final authProvider = context.read<AuthProvider>();
    await authProvider.connect(
      config,
      username: _usernameController.text,
      password: _passwordController.text,
      persist: _stayLoggedIn,
    );
  }

  void _showAuthDrawer() {
    AppModalSheet.show(
      context: context,
      child: AuthDrawer(
        selectedAuthType: _selectedAuthType,
        usernameController: _usernameController,
        passwordController: _passwordController,
        authError: _authError,
        onAuthTypeChanged: (type) {
          setState(() => _selectedAuthType = type);
        },
      ),
    );
  }

  void _showAdvancedDrawer() {
    AppModalSheet.show(
      context: context,
      child: AdvancedDrawer(
        stayLoggedIn: _stayLoggedIn,
        useTls: _useTls,
        onStayLoggedInChanged: (value) {
          setState(() => _stayLoggedIn = value);
        },
        onUseTlsChanged: (value) {
          setState(() => _useTls = value);
        },
      ),
    );
  }

  void _showHistoryDrawer() {
    final authProvider = context.read<AuthProvider>();
    final history = authProvider.connectionHistory;

    AppModalSheet.show(
      context: context,
      child: ConnectionHistoryDrawer(
        history: history,
        onSelect: (uri) {
          _uriController.text = uri;
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final advancedSummary =
        '${_stayLoggedIn ? AppLocalizations.of(context)!.rememberConnection : AppLocalizations.of(context)!.dontRemember}'
        ' • '
        '${_useTls ? AppLocalizations.of(context)!.tlsEnabled : AppLocalizations.of(context)!.tlsDisabled}';

    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: Stack(
        children: [
          Positioned(
            left: -100,
            top: 200,
            child: Image.asset(
              'assets/images/background.png',
              width: 800,
              fit: BoxFit.contain,
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: FadeTransition(
                opacity: _formController,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const SizedBox(
                        width: AppDimensions.logoSize,
                        height: AppDimensions.logoSize,
                        child: AnimatedOrca(page: 0.0),
                      ),
                      const SizedBox(height: 16),
                      FadeTransition(
                        opacity: _taglineController,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            AppLocalizations.of(context)!.appTagline,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (authProvider.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              authProvider.error!.localizedMessage(AppLocalizations.of(context)!),
                              style: AppTextStyles.errorMessage.copyWith(
                                color: Colors.redAccent,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            AppInputField(
                              controller: _uriController,
                              labelText: AppLocalizations.of(context)!.dockerHostUri,
                              validator: (v) => Validators.validateUri(
                                v,
                                requiredError: AppLocalizations.of(context)!.uriRequired,
                                invalidError: AppLocalizations.of(context)!.invalidIpPort,
                              ),
                              prefixIcon: Icons.dns_outlined,
                              suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.history,
                                  color: AppColors.white,
                                ),
                                onPressed: _showHistoryDrawer,
                                tooltip: AppLocalizations.of(context)!.recentConnections,
                              ),
                            ),
                            const SizedBox(height: 32),
                            AppInputTile(
                              icon: Icons.security,
                              label: AppLocalizations.of(context)!.authentication,
                              value: _selectedAuthType.getDisplayName(AppLocalizations.of(context)!),
                              onTap: _showAuthDrawer,
                              borderColor: Colors.white,
                              labelColor: Colors.white,
                            ),
                            const SizedBox(height: 32),
                            AppInputTile(
                              icon: Icons.settings,
                              label: AppLocalizations.of(context)!.advancedOptions,
                              value: advancedSummary,
                              onTap: _showAdvancedDrawer,
                              borderColor: Colors.white,
                              labelColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: SafeArea(
              bottom: true,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 8 : 16,
                ),
                child: FadeTransition(
                  opacity: _buttonController,
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.backgroundDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 4,
                      ),
                      onPressed: authProvider.isConnecting
                          ? null
                          : () => _connect(),
                      child: Text(
                        authProvider.isConnecting
                            ? AppLocalizations.of(context)!.connecting
                            : AppLocalizations.of(context)!.connect,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (authProvider.isConnecting) ...[
            ModalBarrier(
              dismissible: false,
              color: AppColors.black.withValues(alpha: 0.2),
            ),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }
}
