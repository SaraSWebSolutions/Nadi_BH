// import 'package:flutter/material.dart';

// class RequestCart extends StatelessWidget {
//   final String title;
//    final String subtitle;
//   final Color color;
//   final double height;
//   final double width;
//   final double radius;
//   final VoidCallback? onTap;
//   final Image image;

//   const RequestCart({
//     super.key,
//     required this.title,
//     this.color = Colors.blue,
//     this.height = 120,
//     this.width = 120,
//     this.radius = 14,
//     this.onTap,
//      this.subtitle = "", required this.image,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(radius),
//       child: Container(
//         height: height,
//         width: width,
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(radius),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Stack(
//             children: [
                 
//              Container(
//               width:100 ,
//                child: Text(
//                     title,
//                    style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16,
//                   ),
//                 ),
//              ),  
            
          
             
//               Positioned(
//                 bottom: 6,
//                 right: 6,
//                 child: Container(
//                   height: 45,
//                   width: 45,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.25),
//                     shape: BoxShape.circle,
//                   ),
//                   child: image
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class RequestCart extends StatefulWidget {
  final String title;
  final String subtitle;
  final Color color;
  final double height;
  final double width;
  final double radius;
  final VoidCallback? onTap;
  final Widget image;
  final Widget? centerIcon;

  const RequestCart({
    super.key,
    required this.title,
    this.subtitle = "",
    this.color = Colors.blue,
    this.height = 120,
    this.width = 120,
    this.radius = 14,
    this.onTap,
    required this.image,
    this.centerIcon,
  });

  @override
  State<RequestCart> createState() => _RequestCartState();
}

class _RequestCartState extends State<RequestCart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _scale;
  late Animation<double> _rotation;
  late Animation<double> _iconMove;
  late Animation<double> _iconFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scale = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.95),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.95, end: 1.05),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.05, end: 1.0),
        weight: 30,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _rotation = Tween(begin: 0.0, end: -0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    /// ✉️ Envelope open effect (icon goes up)
    _iconMove = Tween(begin: 0.0, end: -20.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _iconFade = Tween(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  Future<void> _onTap() async {
    await _controller.forward();
    await _controller.reverse();

    widget.onTap?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotation.value,
          child: Transform.scale(
            scale: _scale.value,
            child: InkWell(
              onTap: _onTap,
              borderRadius: BorderRadius.circular(widget.radius),
              child: Container(
                height: widget.height,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(widget.radius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Stack(
                    children: [
                      /// TITLE
                      if (widget.title.isNotEmpty)
                        SizedBox(
                          width: 100,
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),

                      /// CENTER ICON (when no title)
                      if (widget.centerIcon != null)
                        Center(
                          child: widget.centerIcon,
                        ),

                      /// BOTTOM-RIGHT ICON ANIMATION (hidden when centerIcon is used)
                      if (widget.centerIcon == null)
                        Positioned(
                          bottom: 6,
                          right: 6,
                          child: Transform.translate(
                            offset: Offset(0, _iconMove.value),
                            child: Opacity(
                              opacity: _iconFade.value,
                              child: Container(
                                height: 45,
                                width: 45,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  shape: BoxShape.circle,
                                ),
                                child: widget.image,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}