import 'package:alertaescolar/managers/user_provider.dart';
import 'package:alertaescolar/services/scanner_service.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:provider/provider.dart';
import '../../../app/app_theme.dart';
import 'processing_view.dart';

class CameraScannerView extends StatefulWidget {
  final Function(String) onCodeScanned;
  final ScannerAccessType? accessType;
  final bool? isDefaultEntryConfig;

  const CameraScannerView({
    super.key,
    required this.onCodeScanned,
    this.accessType,
    this.isDefaultEntryConfig,
  });

  @override
  State<CameraScannerView> createState() => _CameraScannerViewState();
}

class _CameraScannerViewState extends State<CameraScannerView>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  QRViewController? _controller;
  bool _hasScanned = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // Access type indicator animation
  late AnimationController _accessTypeAnimationController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAnimations();
    _showAccessTypeIndicator();
  }

  void _initAnimations() {
    _accessTypeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
  }

  void _showAccessTypeIndicator() {
    _accessTypeAnimationController.forward();

    // Auto-hide after 4 seconds
    // Future.delayed(const Duration(seconds: 4), () {
    //   if (mounted && !_hasScanned) {
    //     _accessTypeAnimationController.reverse();
    //   }
    // });
  }

  String _getAccessTypeText() {
    final accessType = widget.accessType ?? ScannerAccessType.automatic;
    final isDefaultEntry = widget.isDefaultEntryConfig ?? true;

    switch (accessType) {
      case ScannerAccessType.automatic:
        return isDefaultEntry ? 'Entrada Automática' : 'Salida Automática';
      case ScannerAccessType.entry:
        return 'Entrada';
      case ScannerAccessType.exit:
        return 'Salida';
    }
  }

  Color _getAccessTypeColor() {
    final accessType = widget.accessType ?? ScannerAccessType.automatic;
    final isDefaultEntry = widget.isDefaultEntryConfig ?? true;

    switch (accessType) {
      case ScannerAccessType.automatic:
        return isDefaultEntry ? Colors.green : Colors.orange;
      case ScannerAccessType.entry:
        return Colors.blue;
      case ScannerAccessType.exit:
        return Colors.red;
    }
  }

  /// Navigate to ProcessingView when QR code is detected
  Future<void> _processScannedCode(String code) async {
    if (_hasScanned) return;

    setState(() {
      _hasScanned = true;
    });

    // Get current user (admin) ID
    final userProvider = context.read<UserProvider>();
    final adminId = userProvider.currentUser?.id;

    if (adminId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Usuario no autenticado'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      _resetForNextScan();
      return;
    }

    // Navigate to ProcessingView
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ProcessingView(
          scannedCode: code,
          adminId: adminId,
          accessType: widget.accessType ?? ScannerAccessType.automatic,
          isDefaultEntryConfig: widget.isDefaultEntryConfig ?? true,
        ),
      ),
    );

    // Reset scanner for next scan when returning
    _resetForNextScan();

    // Call the callback if processing was successful
    if (result == true) {
      widget.onCodeScanned(code);
    }
  }

  void _resetForNextScan() {
    setState(() {
      _hasScanned = false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // Safely dispose camera controller
    if (_controller != null) {
      try {
        _controller!.pauseCamera();
        _controller!.dispose();
      } catch (e) {
        debugPrint('Camera dispose error: $e');
      }
    }

    _accessTypeAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isBackgroundOrInactive = state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached;

    final isResumed = state == AppLifecycleState.resumed;

    if (_controller != null) {
      try {
        if (isBackgroundOrInactive) {
          _controller!.pauseCamera();
        } else if (isResumed) {
          // Add delay before resuming to ensure stability
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted && _controller != null) {
              _controller!.resumeCamera();
            }
          });
        }
      } catch (e) {
        debugPrint('Camera lifecycle error: $e');
      }
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    // Reassemble is called during hot reload - restart camera safely
    if (_controller != null) {
      try {
        _controller!.pauseCamera();
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && _controller != null) {
            _controller!.resumeCamera();
          }
        });
      } catch (e) {
        debugPrint('Camera reassemble error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // QR Camera View
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: _hasScanned ? Colors.green : AppTheme.accentBlue,
              borderRadius: 24,
              borderLength: 80,
              borderWidth: 4,
              cutOutSize: screenSize.width * 0.7,
            ),
            cameraFacing: CameraFacing.back,
            onPermissionSet: (ctrl, hasPermission) {
              debugPrint('Camera permission: $hasPermission');
              if (!hasPermission) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Permisos de cámara requeridos para escanear códigos QR'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 4),
                        action: SnackBarAction(
                          label: 'Cerrar',
                          textColor: Colors.white,
                          onPressed: () {},
                        ),
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                });
              }
            },
          ),

          // Scanner overlay controls
          _buildScannerOverlay(screenSize),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      _controller = controller;
    });

    // Setup scan listener first
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null && !_hasScanned) {
        _processScannedCode(scanData.code!);
      }
    });

    // Initialize camera safely with delay
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted && _controller != null) {
        try {
          // Small delay to ensure camera is ready
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted && _controller != null) {
            await _controller!.resumeCamera();
          }
        } catch (e) {
          debugPrint('Camera initialization error: $e');
          // Try to reinitialize after a longer delay
          if (mounted) {
            await Future.delayed(const Duration(milliseconds: 1000));
            try {
              if (mounted && _controller != null) {
                await _controller!.resumeCamera();
              }
            } catch (e2) {
              debugPrint('Camera retry failed: $e2');
            }
          }
        }
      }
    });
  }

  Widget _buildScannerOverlay(Size screenSize) {
    return SafeArea(
      child: Column(
        children: [
          // Top controls
          Padding(
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                _buildControlButton(
                  icon: Icons.arrow_back,
                  onPressed: () => Navigator.of(context).pop(),
                  screenSize: screenSize,
                ),

                // Access type indicator
                AnimatedBuilder(
                  animation: _accessTypeAnimationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        -20 * (1 - _accessTypeAnimationController.value),
                      ),
                      child: Opacity(
                        opacity: _accessTypeAnimationController.value,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.getMediumPadding(screenSize),
                            vertical: AppTheme.getSmallPadding(screenSize),
                          ),
                          decoration: BoxDecoration(
                            color: _getAccessTypeColor().withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _getAccessTypeText(),
                            style: AppTheme.getCaption(screenSize).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Spacer to maintain layout balance
                const SizedBox(width: 48),
              ],
            ),
          ),

          const Spacer(),

          // Bottom instructions
          Container(
            margin: EdgeInsets.all(AppTheme.getLargePadding(screenSize)),
            padding: EdgeInsets.all(AppTheme.getMediumPadding(screenSize)),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  color: AppTheme.accentBlue,
                  size: 32,
                ),
                SizedBox(height: AppTheme.getSmallPadding(screenSize)),
                Text(
                  'Apunta la cámara al código QR',
                  style: AppTheme.getBodyMedium(screenSize).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppTheme.getSmallPadding(screenSize) / 2),
                Text(
                  'El escaneo será automático',
                  style: AppTheme.getCaption(screenSize).copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Size screenSize,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
