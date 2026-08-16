import 'package:flutter/material.dart';

/// Tekstong kailangan ng mga may-ari ng instrumento. Iisang pinagmumulan para
/// magkatugma ang app at ang PDF.
class ScreeningAttribution {
  static const String mchat = 'M-CHAT-R\u2122 \u00a9 2009 Robins, Fein, & Barton.';
  static const String vanderbilt =
      'NICHQ Vanderbilt Assessment Scale \u00a9 NICHQ & AAP.';
  static const String both = '$mchat $vanderbilt';

  static const String disclaimer =
      'Ang tool na ito ay isang paunang screening lamang at HINDI kapantay ng '
      'opisyal na medikal na diagnosis. Mangyaring kumonsulta sa lisensyadong '
      'Developmental Pediatrician.';
}

class ScreeningCopyright extends StatelessWidget {
  final String text;

  const ScreeningCopyright({super.key, this.text = ScreeningAttribution.both});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 10,
        color: Colors.grey.shade600,
        height: 1.35,
        fontFamily: 'Nunito',
      ),
    );
  }
}
