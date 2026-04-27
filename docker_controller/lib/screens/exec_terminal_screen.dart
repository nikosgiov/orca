import 'dart:convert';

import 'package:docker_controller/constants/app_colors.dart';
import 'package:docker_controller/constants/app_text_styles.dart';
import 'package:docker_controller/models/connection_config.dart';
import 'package:docker_controller/services/exec_service.dart';
import 'package:docker_controller/widgets/app_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:xterm/xterm.dart';

import '../l10n/app_localizations.dart';

class ExecTerminalScreen extends StatefulWidget {
  const ExecTerminalScreen({
    super.key,
    required this.config,
    required this.containerId,
    required this.containerName,
  });
  final ConnectionConfig config;
  final String containerId;
  final String containerName;

  @override
  State<ExecTerminalScreen> createState() => _ExecTerminalScreenState();
}

class _ExecTerminalScreenState extends State<ExecTerminalScreen> {
  late final Terminal terminal;
  final TerminalController terminalController = TerminalController();
  WebSocketChannel? _channel;
  bool _isConnected = false;
  String _shell = '/bin/sh';

  @override
  void initState() {
    super.initState();
    terminal = Terminal(maxLines: 10000);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _connect();
      }
    });
  }

  void _connect() {
    setState(() => _isConnected = false);

    // Clear the terminal on reconnect
    terminal.eraseDisplay();
    terminal.write('${AppLocalizations.of(context)!.connectingTo(widget.containerName)}\r\n');

    _channel?.sink.close();

    try {
      _channel = ExecService.connectToExec(
        widget.config,
        widget.containerId,
        shell: _shell,
      );

      _channel!.stream.listen(
        (message) {
          if (message is String) {
            try {
              final data = jsonDecode(message);
              if (data['type'] == 'stdout' || data['type'] == 'stderr') {
                terminal.write(data['data']);
              } else if (data['type'] == 'closed') {
                if (mounted) {
                  terminal.write('\r\n\x1B[1;31m${AppLocalizations.of(context)!.processTerminated}\x1B[0m\r\n');
                  setState(() => _isConnected = false);
                }
              } else if (data['type'] == 'error') {
                if (mounted) {
                  terminal.write(
                    '\r\n\x1B[1;31m${AppLocalizations.of(context)!.streamError(data['data']?.toString() ?? '')}\x1B[0m\r\n',
                  );
                  setState(() => _isConnected = false);
                }
              }
            } catch (e) {
              // Not JSON, just raw data fall-back
              terminal.write(message);
            }
          }
        },
        onDone: () {
          if (mounted) {
            terminal.write('\r\n\x1B[1;33m${AppLocalizations.of(context)!.connectionClosed}\x1B[0m\r\n');
            setState(() => _isConnected = false);
          }
        },
        onError: (e) {
          if (mounted) {
            terminal.write('\r\n\x1B[1;31m${AppLocalizations.of(context)!.webSocketError(e.toString())}\x1B[0m\r\n');
            setState(() => _isConnected = false);
          }
        },
      );

      // Tell xterm to send user input to the WebSocket
      terminal.onOutput = (String output) {
        if (_isConnected && _channel != null) {
          _channel!.sink.add(output);
        }
      };

      setState(() => _isConnected = true);
      terminal.write('\x1B[1;32m${AppLocalizations.of(context)!.connectedVia(_shell)}\x1B[0m\r\n');
    } catch (e) {
      terminal.write('\r\n\x1B[1;31m${AppLocalizations.of(context)!.connectionFailed(e.toString())}\x1B[0m\r\n');
    }
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      position: const Offset(40, -100),
      scale: 1.4,
      child: Scaffold(
        backgroundColor: Colors.transparent, // true black for terminal feel
        appBar: AppBar(
          backgroundColor: AppColors.backgroundDark,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppLocalizations.of(context)!.terminalTitle}: ${widget.containerName}',
                style: AppTextStyles.heading2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isConnected
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _isConnected ? AppLocalizations.of(context)!.connected : AppLocalizations.of(context)!.disconnected,
                      style: AppTextStyles.caption.copyWith(
                        color: _isConnected
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            _buildShellSelector(),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: _connect,
              tooltip: AppLocalizations.of(context)!.reconnect,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: TerminalView(
                  terminal,
                  controller: terminalController,
                  autofocus: true,
                  backgroundOpacity: 0.0,
                  textStyle: const TerminalStyle(
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              // Shortcut bar
              Container(
                color: AppColors.backgroundMid,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _TerminalShortcutButton(
                        label: AppLocalizations.of(context)!.copy,
                        icon: Icons.copy,
                        onTap: () {
                          final selection = terminalController.selection;
                          if (selection != null) {
                            final selectedText = terminal.buffer.getText(
                              selection,
                            );
                            if (selectedText.isNotEmpty) {
                              Clipboard.setData(
                                ClipboardData(text: selectedText),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context)!.copiedToClipboard),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                              terminalController.clearSelection();
                            }
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      _TerminalShortcutButton(
                        label: AppLocalizations.of(context)!.paste,
                        icon: Icons.paste,
                        onTap: () async {
                          if (_isConnected && _channel != null) {
                            final clipboardData = await Clipboard.getData(
                              'text/plain',
                            );
                            final text = clipboardData?.text;
                            if (text != null && text.isNotEmpty) {
                              _channel!.sink.add(text);
                            }
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 1,
                        height: 24,
                        color: AppColors.glassBorder,
                      ),
                      const SizedBox(width: 8),
                      _TerminalShortcutButton(
                        label: 'CTRL+C',
                        onTap: () {
                          if (_isConnected && _channel != null) {
                            _channel!.sink.add('\x03');
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      _TerminalShortcutButton(
                        label: 'CTRL+D',
                        onTap: () {
                          if (_isConnected && _channel != null) {
                            _channel!.sink.add('\x04');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShellSelector() {
    return Center(
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.glassOverlay,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _shell,
            dropdownColor: AppColors.backgroundMid,
            icon: const Icon(
              Icons.arrow_drop_down,
              color: Colors.white70,
              size: 16,
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontFamily: 'monospace',
            ),
            onChanged: (newShell) {
              if (newShell != null && newShell != _shell) {
                setState(() => _shell = newShell);
                _connect(); // reconnect with new shell
              }
            },
            items: const [
              DropdownMenuItem(value: '/bin/sh', child: Text('/bin/sh')),
              DropdownMenuItem(value: '/bin/bash', child: Text('/bin/bash')),
            ],
          ),
        ),
      ),
    );
  }
}

class _TerminalShortcutButton extends StatelessWidget {
  const _TerminalShortcutButton({
    required this.label,
    required this.onTap,
    this.icon,
  });
  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.glassBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: AppColors.glassBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: Colors.white),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
