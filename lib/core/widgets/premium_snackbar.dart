import 'dart:collection';
import 'package:flutter/material.dart';

enum ToastPosition { top, center, bottom }

enum ToastType { success, error, warning, info }

class PremiumToastHelper {
  static final _overlayKey = GlobalKey<_ToastOverlayState>();
  static final _queue = Queue<_ToastRequest>();
  static bool _isShowing = false;
  static late OverlayEntry _overlayEntry;

  static void init(BuildContext context) {
    _overlayEntry = OverlayEntry(
      builder: (_) => _ToastOverlay(key: _overlayKey),
    );
    Overlay.of(context).insert(_overlayEntry);
  }

  static void show({
    String? message,
    ToastType? type,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    double borderRadius = 8,
    Duration duration = const Duration(seconds: 2),
    Duration fadeDuration = const Duration(milliseconds: 300),
    Duration slideDuration = const Duration(milliseconds: 300),
    ToastPosition position = ToastPosition.bottom,
  }) {
    Color finalBackgroundColor = backgroundColor ?? Colors.black87;
    Color finalTextColor = textColor ?? Colors.white;
    IconData? finalIcon = icon;

    if (type != null) {
      switch (type) {
        case ToastType.success:
          finalBackgroundColor = Colors.green;
          finalIcon = Icons.check_circle_outline;
          break;
        case ToastType.error:
          finalBackgroundColor = Colors.red;
          finalIcon = Icons.error_outline;
          break;
        case ToastType.warning:
          finalBackgroundColor = Colors.orange;
          finalIcon = Icons.warning_amber_rounded;
          break;
        case ToastType.info:
          finalBackgroundColor = Colors.blue;
          finalIcon = Icons.info_outline;
          break;
      }
    }

    _queue.add(
      _ToastRequest(
        message: message ?? '',
        icon: finalIcon,
        backgroundColor: finalBackgroundColor,
        textColor: finalTextColor,
        borderRadius: borderRadius,
        duration: duration,
        fadeDuration: fadeDuration,
        slideDuration: slideDuration,
        position: position,
        type: type,
      ),
    );

    _showNext();
  }

  static void _showNext() {
    if (_isShowing || _queue.isEmpty) return;
    _isShowing = true;

    final request = _queue.removeFirst();
    // _playSound(type: request.type);

    _overlayKey.currentState?.show(
      request,
      onDismissed: () {
        _isShowing = false;
        _showNext();
      },
    );
  }

  // static void _playSound({ToastType? type}) async {
  //   final player = AudioPlayer();
  //   String audioPath = 'assets/sounds/error1.mp3'; // default

  //   switch (type) {
  //     case ToastType.success:
  //       audioPath = 'assets/sounds/success.mp3';
  //       break;
  //     case ToastType.error:
  //       audioPath = 'assets/sounds/error.mp3';
  //       break;
  //     case ToastType.info:
  //       audioPath = 'assets/sounds/info.mp3';
  //       break;
  //     case ToastType.warning:
  //       audioPath = 'assets/sounds/warning.mp3';
  //       break;
  //     default:
  //       break;
  //   }

  //   // await player.play(AssetSource(audioPath.replaceFirst('assets/', '')));
  // }
}

class _ToastRequest {
  final String message;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final Duration duration;
  final Duration fadeDuration;
  final Duration slideDuration;
  final ToastPosition position;
  final ToastType? type;

  _ToastRequest({
    required this.message,
    this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.borderRadius,
    required this.duration,
    required this.fadeDuration,
    required this.slideDuration,
    required this.position,
    required this.type,
  });
}

class _ToastOverlay extends StatefulWidget {
  const _ToastOverlay({super.key});

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay> {
  _ToastRequest? _currentRequest;
  VoidCallback? _onDismissed;

  void show(_ToastRequest request, {VoidCallback? onDismissed}) {
    setState(() {
      _currentRequest = request;
      _onDismissed = onDismissed;
    });
  }

  void dismiss() {
    setState(() {
      _currentRequest = null;
      _onDismissed?.call();
      _onDismissed = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentRequest == null) return const SizedBox.shrink();
    return _ToastWidget(request: _currentRequest!, onDismiss: dismiss);
  }
}

class _ToastWidget extends StatefulWidget {
  final _ToastRequest request;
  final VoidCallback onDismiss;

  const _ToastWidget({required this.request, required this.onDismiss});

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.request.slideDuration,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();
    Future.delayed(widget.request.duration, () => _dismiss());
  }

  void _dismiss() {
    _controller.reverse().then((_) => widget.onDismiss());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double? top, bottom;
    if (widget.request.position == ToastPosition.top) {
      top = 50;
    } else if (widget.request.position == ToastPosition.center) {
      top = MediaQuery.of(context).size.height / 2 - 40;
    } else {
      bottom = 50;
    }

    return Positioned(
      top: top,
      bottom: bottom,
      left: MediaQuery.of(context).size.width * 0.1,
      right: MediaQuery.of(context).size.width * 0.1,
      child: GestureDetector(
        onTap: _dismiss,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: widget.request.backgroundColor,
                    borderRadius: BorderRadius.circular(
                      widget.request.borderRadius,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.request.icon != null) ...[
                        Icon(
                          widget.request.icon,
                          color: widget.request.textColor,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          widget.request.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: widget.request.textColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
