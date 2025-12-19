import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:pdfrx/pdfrx.dart' as pdfrx;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;


/// PDF 바이트를 받아 각 페이지를 JPEG 바이트 리스트로 반환합니다.
class PdfToImageService {
  const PdfToImageService();

  static bool _pdfrxCacheInit = false;

  Future<List<Uint8List>> convertPdfToJpegPages(
    Uint8List pdfBytes, {
    int renderScale = 2,
    int jpegQuality = 90,
  }) async {
    final List<Uint8List> pages = [];

    // pdfrx 캐시 디렉터리 설정 (한 번만)
    if (!_pdfrxCacheInit) {
      try {
        final dir = await getTemporaryDirectory();
        // pdfrx provides Pdfrx.getCacheDirectory setter. 설정하여 pdfrx가 캐시를 사용할 디렉터리를 얻도록 함
        pdfrx.Pdfrx.getCacheDirectory = () async => dir.path;
        // Flutter에서 assets 로드를 위해 loadAsset도 지정해 둡니다 (선택적).
        if (pdfrx.Pdfrx.loadAsset == null) {
          pdfrx.Pdfrx.loadAsset = (String name) async {
            final bd = await rootBundle.load(name);
            return bd.buffer.asUint8List();
          };
        }
        _pdfrxCacheInit = true;
      } catch (e) {
        // 설정 실패해도 계속 진행 (하지만 변환에 실패할 수 있음)
      }
    }

    pdfrx.PdfDocument? doc;
    try {
      doc = await pdfrx.PdfDocument.openData(pdfBytes);
    } catch (e) {
      return pages;
    }

    final List<pdfrx.PdfPage> pdfPages = doc.pages;

    for (final pdfrx.PdfPage page in pdfPages) {
      // 페이지 크기(포인트 단위)를 가져와 픽셀 크기 계산
      final double pageWidthPt = page.width;
      final double pageHeightPt = page.height;
      final int width = ((pageWidthPt <= 0 ? 612.0 : pageWidthPt) * renderScale).toInt();
      final int height = ((pageHeightPt <= 0 ? 792.0 : pageHeightPt) * renderScale).toInt();

      pdfrx.PdfImage? rendered;
      try {
        rendered = await page.render(
          fullWidth: width.toDouble(),
          fullHeight: height.toDouble(),
          backgroundColor: 0xFFFFFFFF, // 흰 배경으로 알파 이슈 방지
        );
      } catch (_) {
        rendered = null;
      }

      if (rendered == null) {
        // 다음 페이지로
        continue;
      }

      try {
        // pdfrx PdfImage.pixels 는 BGRA8888 raw bytes
        final Uint8List bgra = rendered.pixels;
        if (bgra.isEmpty) {
          continue;
        }

        // BGRA -> RGBA 변환
        final Uint8List rgba = Uint8List(bgra.length);
        for (int i = 0; i < bgra.length; i += 4) {
          final int b = bgra[i];
          final int g = bgra[i + 1];
          final int r = bgra[i + 2];
          final int a = bgra[i + 3];
          rgba[i] = r;
          rgba[i + 1] = g;
          rgba[i + 2] = b;
          rgba[i + 3] = a;
        }

        // image 패키지로 이미지 생성 및 JPEG 인코딩
        final img.Image image = img.Image.fromBytes(
          width: width,
          height: height,
          bytes: rgba.buffer,
          numChannels: 4,
          order: img.ChannelOrder.rgba,
        );
        final List<int> jpg = img.encodeJpg(image, quality: jpegQuality);
        pages.add(Uint8List.fromList(jpg));
      } catch (_) {
        // 변환 실패면 건너뜀
      } finally {
        try {
          rendered.dispose();
        } catch (_) {}
      }
    }

    try {
      await doc.dispose();
    } catch (_) {}

    return pages;
  }
}
