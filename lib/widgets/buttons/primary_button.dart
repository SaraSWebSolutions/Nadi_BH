import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;
  final double height;
  final double borderRadius;
  final double width;
  final Widget? icon;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.color,
    this.textColor = Colors.black,
    this.height = 60,
    required this.width,
    this.borderRadius = 14,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        // onPressed: () {
        //   if (!isLoading) {
        //     onPressed?.call();
        //   }
        // }, //  ignore taps while loading
        style: ElevatedButton.styleFrom(
          backgroundColor: color, // keep full color
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ), // Restoring proper horizontal layout bounds
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white, // spinner color
                ),
              )
            : icon == null
            ? Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  height: 1.2, // Perfects Poppins clipping boundary
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon!,
                  const SizedBox(width: 10),
                  Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      height: 1.2, // Perfects Poppins clipping boundary
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
