import 'package:flutter/material.dart';

class AnimatedEnvelope extends StatefulWidget {
  final int unreadCount;
  final VoidCallback onTap;
  const AnimatedEnvelope({super.key, required this.unreadCount, required this.onTap});
  @override
  State<AnimatedEnvelope> createState() => _AnimatedEnvelopeState();
}

class _AnimatedEnvelopeState extends State<AnimatedEnvelope> with SingleTickerProviderStateMixin {
  late final AnimationController _shakeCtrl;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  }

  @override
  void didUpdateWidget(covariant AnimatedEnvelope old) {
    super.didUpdateWidget(old);
    if (widget.unreadCount > old.unreadCount && widget.unreadCount > 0) {
      _shakeCtrl.forward(from: 0).then((_) { if (mounted) _shakeCtrl.reset(); });
    }
  }

  @override
  void dispose() { _shakeCtrl.dispose(); super.dispose(); }

  bool get _has => widget.unreadCount > 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _shakeCtrl,
        builder: (ctx, child) {
          final angle = _shakeCtrl.isAnimating
              ? 0.05 * (1 - _shakeCtrl.value) * ((_shakeCtrl.value * 8).floor().isEven ? 1 : -1)
              : 0.0;
          return Transform.rotate(angle: angle, child: child);
        },
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: _has
                ? const Color(0xFFFFB908).withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _has
                  ? const Color(0xFFFFB908).withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOutBack,
                transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                child: Icon(
                  Icons.notifications_rounded,
                  key: ValueKey(_has),
                  color: _has ? const Color(0xFFFFB908) : Colors.white,
                  size: 28,
                ),
              ),
              if (_has)
                Positioned(
                  top: -2,
                  right: -2,
                  child: AnimatedScale(
                    scale: 1.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.elasticOut,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF4444), Color(0xFFCC0000)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.unreadCount > 99 ? '99+' : '${widget.unreadCount}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Poppins',
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
