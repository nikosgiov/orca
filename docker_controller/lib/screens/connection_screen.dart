import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_delays.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_gradients.dart';
import '../constants/app_paddings.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import '../models/connection_config.dart';
import '../providers/app_provider.dart';
import '../widgets/app_input_field.dart';
import '../widgets/app_input_tile.dart';
import '../widgets/app_modal_sheet.dart';
import '../widgets/animated_orca.dart';
import '../utils/validators.dart';
import 'connection/auth_drawer.dart';
import 'connection/advanced_drawer.dart';

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
        vsync: this, duration: const Duration(milliseconds: 600));
    _formController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _buttonController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadSavedConfig();
        _startAnimations();
      }
    });
  }

  void _startAnimations() async {
    if (!mounted) return;
    try {
      await Future.delayed(AppDelays.connectionAnimStep1);
      if (!mounted) return;

      _taglineController.forward();
      await Future.delayed(AppDelays.connectionAnimStep1);
      if (!mounted) return;

      _formController.forward();
      await Future.delayed(AppDelays.connectionAnimStep2);
      if (!mounted) return;

      _buttonController.forward();
    } catch (_) {
      // Ignore animation errors during hot restart
    }
  }

  void _loadSavedConfig() {
    final savedConfig = context.read<AppProvider>().connectionConfig;
    if (savedConfig != null) {
      _uriController.text = savedConfig.uri;
      _selectedAuthType = savedConfig.authType;
      _useTls = savedConfig.useTls;
    } else if (_uriController.text.isEmpty) {
      _uriController.text = '';
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
    if (!(_formKey.currentState?.validate() ?? false)) return;

    String? authError;
    if (_selectedAuthType == AuthType.basic) {
      authError = Validators.validateUsername(_usernameController.text) ??
          Validators.validatePassword(_passwordController.text);
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

    final appProvider = context.read<AppProvider>();
    if (_selectedAuthType == AuthType.basic) {
      if (_stayLoggedIn) {
        await appProvider.connectAndPersist(config,
            username: _usernameController.text,
            password: _passwordController.text);
      } else {
        await appProvider.connectWithoutPersistence(config,
            username: _usernameController.text,
            password: _passwordController.text);
      }
    } else {
      if (_stayLoggedIn) {
        await appProvider.connectAndPersist(config);
      } else {
        await appProvider.connectWithoutPersistence(config);
      }
    }
  }


  // ── Auth drawer ─────────────────────────────────────────────────────────────
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
    final appProvider = context.read<AppProvider>();
    final history = appProvider.connectionHistory;

    AppModalSheet.show(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.recentConnections,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold, color: AppColors.inputIcon),
          ),
          const SizedBox(height: 20),
          if (history.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.history,
                        size: 48, color: AppColors.inputIcon.withValues(alpha: 0.2)),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.noHistory,
                      style: AppTextStyles.body.copyWith(
                          color: AppColors.inputIcon.withValues(alpha: 0.5)),
                    ),
                  ],
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final uri = history[index];
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.dns_outlined,
                          color: AppColors.primary, size: 20),
                    ),
                    title: Text(
                      uri,
                      style: AppTextStyles.body.copyWith(
                          color: AppColors.inputIcon, fontWeight: FontWeight.w500),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline,
                          color: AppColors.inputIcon.withValues(alpha: 0.4),
                          size: 20),
                      onPressed: () => appProvider.removeHistoryEntry(uri),
                    ),
                    onTap: () {
                      _uriController.text = uri;
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    final Size screenSize = MediaQuery.of(context).size;
    final double baseImageSize = screenSize.width * 2.0;

    final Offset position = const Offset(-40, 300); 
    final double scale = 1.5;
    // ----------------------------------------

    double currentSize = baseImageSize * scale;
    double screenCenterX = screenSize.width / 2;
    double screenCenterY = screenSize.height / 2;

    return Positioned(
      left: screenCenterX + position.dx - (currentSize / 2),
      top: screenCenterY + position.dy - (currentSize / 2),
      width: currentSize,
      height: currentSize,
      child: Image.asset(
        'assets/images/background.png',
        fit: BoxFit.contain,
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final advancedSummary =
        '${_stayLoggedIn ? AppStrings.rememberConnection : AppStrings.dontRemember}'
        ' • '
        '${_useTls ? AppStrings.tlsEnabled : AppStrings.tlsDisabled}';

    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: Stack(
        children: [
          _buildAnimatedBackground(),
          Scaffold(
            backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Logo
                const SizedBox(
                  width: AppDimensions.logoSize,
                  height: AppDimensions.logoSize,
                  child: AnimatedOrca(page: 0.0),
                ),
                const SizedBox(height: 16),
                // Tagline
                FadeTransition(
                  opacity: _taglineController,
                  child: Padding(
                    padding: AppPaddings.pageHorizontalNarrow,
                    child: Text(
                      AppStrings.appTagline,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Error message
                if (appProvider.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 8.0),
                    child: Text(
                      appProvider.error!.message,
                      style: AppTextStyles.errorMessage,
                      textAlign: TextAlign.center,
                    ),
                  ),
                // Form
                Expanded(
                  child: FadeTransition(
                    opacity: _formController,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            AppInputField(
                              controller: _uriController,
                              labelText: AppStrings.dockerHostUri,
                              validator: Validators.validateUri,
                              prefixIcon: Icons.dns_outlined,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.history, color: AppColors.white),
                                onPressed: _showHistoryDrawer,
                                tooltip: AppStrings.recentConnections,
                              ),
                            ),
                            const SizedBox(height: 32),
                            AppInputTile(
                              icon: Icons.security,
                              label: AppStrings.authentication,
                              value: _selectedAuthType.displayName,
                              onTap: _showAuthDrawer,
                              borderColor: Colors.white,
                              labelColor: Colors.white,
                            ),
                            const SizedBox(height: 32),
                            AppInputTile(
                              icon: Icons.settings,
                              label: AppStrings.advancedOptions,
                              value: advancedSummary,
                              onTap: _showAdvancedDrawer,
                              borderColor: Colors.white,
                              labelColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Connect button (pinned to bottom)
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
                child: Consumer<AppProvider>(
                  builder: (context, provider, _) => SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.backgroundDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        elevation: 4,
                      ),
                      onPressed: provider.isConnecting ? null : () => _connect(),
                      child: Text(
                        provider.isConnecting
                            ? AppStrings.connecting
                            : AppStrings.connect,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
          if (appProvider.isConnecting) ...[
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
