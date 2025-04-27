import 'package:flutter/material.dart';

@immutable
class CustomTheme extends ThemeExtension<CustomTheme> {
  final Color? primaryColor;
  final Color? secondaryColor;
  final Color? primaryButtonColor;
  final Color? secondaryButtonColor;
  final Color? primaryTextColor;
  final Color? secondaryTextColor;
  final Color? primaryContainerColor;
  final Color? secondaryContainerColor;
  final TextStyle? heading1;
  final TextStyle? title1;
  final TextStyle? subtitle1;
  final TextStyle? description1;

  @override
  ThemeExtension<CustomTheme> copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Color? primaryButtonColor,
    Color? secondaryButtonColor,
    Color? primaryTextColor,
    Color? secondaryTextColor,
    Color? primaryContainerColor,
    Color? secondaryContainerColor,
    TextStyle? heading1,
    TextStyle? title1,
    TextStyle? subtitle1,
    TextStyle? description1,
  }) {
    return CustomTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      primaryButtonColor: primaryButtonColor ?? this.primaryButtonColor,
      secondaryButtonColor: secondaryButtonColor ?? this.secondaryButtonColor,
      primaryTextColor: primaryTextColor ?? this.primaryTextColor,
      secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
      primaryContainerColor:
          primaryContainerColor ?? this.primaryContainerColor,
      secondaryContainerColor:
          secondaryContainerColor ?? this.secondaryContainerColor,
      heading1: heading1 ?? this.heading1,
      title1: title1 ?? this.title1,
      subtitle1: title1 ?? this.subtitle1,
      description1: description1 ?? this.description1,
    );
  }

  @override
  ThemeExtension<CustomTheme> lerp(
    covariant ThemeExtension<CustomTheme>? other,
    double t,
  ) {
    if (other is! CustomTheme) {
      return this;
    }
    return CustomTheme(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t),
      secondaryColor: Color.lerp(secondaryColor, other.secondaryColor, t),
      primaryButtonColor: Color.lerp(
        primaryButtonColor,
        other.primaryButtonColor,
        t,
      ),
      secondaryButtonColor: Color.lerp(
        secondaryButtonColor,
        other.secondaryButtonColor,
        t,
      ),
      primaryContainerColor: Color.lerp(
        primaryContainerColor,
        other.primaryContainerColor,
        t,
      ),
      secondaryContainerColor: Color.lerp(
        secondaryContainerColor,
        other.secondaryContainerColor,
        t,
      ),
      primaryTextColor: Color.lerp(primaryTextColor, other.primaryTextColor, t),
      secondaryTextColor: Color.lerp(
        secondaryTextColor,
        other.secondaryTextColor,
        t,
      ),
      heading1: TextStyle.lerp(heading1, other.heading1, t),
      title1: TextStyle.lerp(title1, other.title1, t),
      subtitle1: TextStyle.lerp(subtitle1, other.subtitle1, t),
      description1: TextStyle.lerp(description1, other.description1, t),
    );
  }

  const CustomTheme({
    required this.primaryColor,
    required this.secondaryColor,
    required this.primaryButtonColor,
    required this.secondaryButtonColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.primaryContainerColor,
    required this.secondaryContainerColor,
    required this.heading1,
    required this.title1,
    required this.subtitle1,
    required this.description1,
  });
}

ThemeData appLightTheme() => ThemeData.dark().copyWith(
  // add up theme customizations if required
  //Ex: iconTheme,cardColor,hoverColor,appBarTheme
  dialogTheme: DialogTheme(backgroundColor: Color(0xffF9F8F0)),
  radioTheme: RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color>((
      Set<WidgetState> states,
    ) {
      return Colors.blue;
    }),
  ),
  extensions: <ThemeExtension<dynamic>>[customLightTheme],
);

ThemeData appDarkTheme() => ThemeData.dark().copyWith(
  // add up theme customizations if required
  //Ex: iconTheme,cardColor,hoverColor,appBarTheme
  dialogTheme: DialogTheme(
    backgroundColor: const Color.fromARGB(255, 101, 100, 100),
  ),
  radioTheme: RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color>((
      Set<WidgetState> states,
    ) {
      return Color(0xffFDFFF5);
    }),
  ),
  extensions: <ThemeExtension<dynamic>>[customDarkTheme],
);

CustomTheme customLightTheme = CustomTheme(
  primaryColor: Colors.blue,
  secondaryColor: Colors.indigo,
  primaryButtonColor: Colors.grey,
  primaryTextColor: Colors.black,
  secondaryTextColor: Colors.grey,
  secondaryButtonColor: Colors.greenAccent,
  primaryContainerColor: Color(0xffF9F8F0),
  secondaryContainerColor: Colors.white70,
  heading1: TextStyle(
    color: Colors.black,
    fontSize: 24,
    fontWeight: FontWeight.w700,
  ),
  title1: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  ),
  subtitle1: TextStyle(
    color: Colors.black,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
  ),
  description1: TextStyle(
    color: Colors.black,
    fontSize: 12.0,
    fontWeight: FontWeight.w700,
  ),
);

CustomTheme customDarkTheme = CustomTheme(
  primaryColor: Color(0xFF36454F),
  secondaryColor: Colors.grey,
  primaryButtonColor: Colors.grey,
  secondaryButtonColor: Colors.black,
  primaryTextColor: Color(0xffFDFFF5),
  secondaryTextColor: Colors.white54,
  primaryContainerColor: const Color.fromARGB(255, 101, 100, 100),
  secondaryContainerColor: Colors.grey[50],
  heading1: TextStyle(
    color: Color(0xffFDFFF5),
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
  ),
  title1: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: Color(0xffFDFFF5),
  ),
  subtitle1: TextStyle(
    color: Color(0xffFDFFF5),
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
  ),
  description1: TextStyle(
    color: Color(0xffFDFFF5),
    fontSize: 12.0,
    fontWeight: FontWeight.w700,
  ),
);
