// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $LibGen {
  const $LibGen();

  /// Directory path: lib/assets
  $LibAssetsGen get assets => const $LibAssetsGen();
}

class $LibAssetsGen {
  const $LibAssetsGen();

  /// File path: lib/assets/destination_hierarchy.json
  String get destinationHierarchy => 'lib/assets/destination_hierarchy.json';

  /// Directory path: lib/assets/fonts
  $LibAssetsFontsGen get fonts => const $LibAssetsFontsGen();

  /// File path: lib/assets/lax_logo.png
  AssetGenImage get laxLogo => const AssetGenImage('lib/assets/lax_logo.png');

  /// File path: lib/assets/laxgp_logo.png
  AssetGenImage get laxgpLogo =>
      const AssetGenImage('lib/assets/laxgp_logo.png');

  /// File path: lib/assets/laxgp_logo2.png
  AssetGenImage get laxgpLogo2 =>
      const AssetGenImage('lib/assets/laxgp_logo2.png');

  /// File path: lib/assets/laxgp_splash.png
  AssetGenImage get laxgpSplash =>
      const AssetGenImage('lib/assets/laxgp_splash.png');

  /// File path: lib/assets/lineall_logo.png
  AssetGenImage get lineallLogo =>
      const AssetGenImage('lib/assets/lineall_logo.png');

  /// File path: lib/assets/lineall_logo2.png
  AssetGenImage get lineallLogo2 =>
      const AssetGenImage('lib/assets/lineall_logo2.png');

  /// File path: lib/assets/lineall_splash.png
  AssetGenImage get lineallSplash =>
      const AssetGenImage('lib/assets/lineall_splash.png');

  /// File path: lib/assets/loading.json
  String get loading => 'lib/assets/loading.json';

  /// File path: lib/assets/optilo_logo.png
  AssetGenImage get optiloLogo =>
      const AssetGenImage('lib/assets/optilo_logo.png');

  /// File path: lib/assets/truck_image.png
  AssetGenImage get truckImage =>
      const AssetGenImage('lib/assets/truck_image.png');

  /// List of all assets
  List<dynamic> get values => [
    destinationHierarchy,
    laxLogo,
    laxgpLogo,
    laxgpLogo2,
    laxgpSplash,
    lineallLogo,
    lineallLogo2,
    lineallSplash,
    loading,
    optiloLogo,
    truckImage,
  ];
}

class $LibAssetsFontsGen {
  const $LibAssetsFontsGen();

  /// File path: lib/assets/fonts/NotoSansKR-Regular.ttf
  String get notoSansKRRegular => 'lib/assets/fonts/NotoSansKR-Regular.ttf';

  /// List of all assets
  List<String> get values => [notoSansKRRegular];
}

class Assets {
  const Assets._();

  static const String aEnv = '.env';
  static const $LibGen lib = $LibGen();

  /// List of all assets
  static List<String> get values => [aEnv];
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
