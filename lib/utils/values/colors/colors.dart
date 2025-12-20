import 'dart:ui';

class MyColors {
  static const int _alphaCode = 0xff;
  static const int _slideToLeft = 24; // geser ke kiri 24 bit
  static const brown500 = Color(_alphaCode << _slideToLeft | 0x4E342E);
  static const brown400 = Color(_alphaCode << _slideToLeft | 0x8D6E63);
  static const brown300 = Color(_alphaCode << _slideToLeft | 0x8A1887F);
  static const brown200 = Color(_alphaCode << _slideToLeft | 0xBCAAA4);
}
