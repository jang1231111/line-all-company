import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;

import 'package:line_all/features/condition/domain/repositories/selected_fare_repository.dart';
import 'package:line_all/features/condition/presentation/models/selected_fare.dart';
import 'package:line_all/features/condition/presentation/data/condition_options.dart';

class SelectedFareRepositoryImpl implements SelectedFareRepository {
  SelectedFareRepositoryImpl();

  @override
  Future<bool> sendSelectedFares({
    required String consignor,
    required String recipient,
    required String recipientEmail,
    required String? recipientCompany,
    required String? recipientPhone,
    required String note,
    required List<SelectedFare> fares,
  }) async {
    final host = dotenv.env['SMTP_SERVER'];
    final port = int.tryParse(dotenv.env['SMTP_PORT'] ?? '587') ?? 587;
    final username = dotenv.env['SMTP_ID'];
    final password = dotenv.env['SMTP_PASSWORD'];

    if (host == null || username == null || password == null) return false;

    final prefs = await SharedPreferences.getInstance();
    final subject = _buildSubject(prefs, consignor);

    final bodyPlain = _buildPlainBody(
      consignor,
      recipient,
      recipientEmail,
      recipientCompany == '' ? '미입력' : recipientCompany,
      recipientPhone == '' ? '미입력' : recipientPhone,
      fares.length,
    );

    final htmlBody = _buildHtmlBody(
      consignor: consignor,
      recipient: recipient,
      recipientEmail: recipientEmail,
      recipientCompany: recipientCompany,
      recipientPhone: recipientPhone,
      count: fares.length,
      prefs: prefs,
    );

    // --- 배너 이미지 준비 (임시파일로 저장, CID로 인라인 첨부) ---
    final tempDir = await getTemporaryDirectory();
    final rawBytes = (await rootBundle.load(
      'lib/assets/icon/app_icon.png',
    )).buffer.asUint8List();

    // 레티나 대응: 표시할 너비를 결정하고 실제 첨부는 2배 크기로 생성
    final decoded = img.decodeImage(rawBytes);
    final int displayWidth = 48; // 메일에서 보이게 할 너비(px)
    final int targetWidth = (displayWidth * 2); // 실제 파일은 2x로 저장해 선명도 확보
    final List<int> outBytes = (decoded != null)
        ? img.encodePng(img.copyResize(decoded, width: targetWidth))
        : rawBytes;
    final bannerFile = File(
      '${tempDir.path}${Platform.pathSeparator}app_icon.png',
    );
    await bannerFile.writeAsBytes(outBytes);
    final bannerCid = 'mail_banner@lineall';

    // 전달 전에 앞뒤 개행 제거
    final htmlWithBanner = _buildHtmlTemplate(
      htmlBody.trim(),
      prefs,
      bannerCid,
    );

    final imageAttachment = FileAttachment(bannerFile, contentType: 'image/png')
      ..fileName = 'mail_banner.png'
      ..cid = bannerCid;

    final smtpServer = SmtpServer(
      host,
      port: port,
      username: username,
      password: password,
    );

    try {
      final pdfFile = await _createPdfFile(
        consignor: consignor,
        recipient: recipient,
        recipientCompany: recipientCompany,
        recipientPhone: recipientPhone,
        recipientEmail: recipientEmail,
        note: note,
        fares: fares,
        prefs: prefs,
      );

      final message = Message()
        ..from = Address(username!, '운임 견적')
        ..recipients.add(recipientEmail)
        ..subject = subject
        ..text = bodyPlain
        ..html = htmlWithBanner
        ..attachments.add(
          FileAttachment(pdfFile, contentType: 'application/pdf')
            ..fileName = pdfFile.path.split(Platform.pathSeparator).last,
        )
        ..attachments.add(imageAttachment);

      await send(message, smtpServer);
      return true;
    } on MailerException catch (e) {
      debugPrint('MailerException: $e');
      return false;
    } catch (e) {
      debugPrint('메일 전송 실패: $e');
      return false;
    }
  }

  // ------------------------
  // PDF 생성
  // ------------------------
  Future<File> _createPdfFile({
    required String consignor,
    required String recipient,
    required String? recipientCompany,
    required String? recipientPhone,
    required String recipientEmail,
    required String note,
    required List<SelectedFare> fares,
    required SharedPreferences prefs,
  }) async {
    final doc = pw.Document();
    final fontData = await rootBundle.load(
      'lib/assets/fonts/NotoSansKR-Regular.ttf',
    );
    final ttf = pw.Font.ttf(fontData);

    final senderCompany = prefs.getString('user_company') ?? '';
    final senderName = prefs.getString('user_name') ?? '';
    final senderPhone = prefs.getString('user_phone') ?? '';
    final senderEmail = prefs.getString('user_email') ?? '';

    final titleStyle = pw.TextStyle(
      font: ttf,
      fontSize: 22,
      fontWeight: pw.FontWeight.bold,
    );
    final total = fares.fold<int>(0, (s, f) => s + f.price);

    pw.Widget cell(String text, {bool isHeader = false, double minHeight = 0}) {
      final bg = isHeader ? PdfColors.grey100 : PdfColors.white;
      final style = isHeader
          ? pw.TextStyle(
              font: ttf,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            )
          : pw.TextStyle(font: ttf, fontSize: 9);
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        constraints: minHeight > 0
            ? pw.BoxConstraints(minHeight: minHeight)
            : null,
        decoration: pw.BoxDecoration(
          color: bg,
          border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
        ),
        child: pw.Center(child: pw.Text(text, style: style)),
      );
    }

    pw.TableRow buildRow(List<String> cols, {bool header = false}) =>
        pw.TableRow(
          children: cols.map((c) => cell(c, isHeader: header)).toList(),
        );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(18),
        build: (pw.Context ctx) {
          final headers = ['No', '항구', '지역', '규격', '할증률', '가격(원)', '비고(할증)'];
          final data = fares.map<List<String>>((f) {
            final region =
                '${f.row.sido}${f.row.sigungu.isNotEmpty ? ' ${f.row.sigungu}' : ''}${f.row.eupmyeondong.isNotEmpty ? ' ${f.row.eupmyeondong}' : ''}';
            final surcharge = f.surchargeLabels.isNotEmpty
                ? f.surchargeLabels.join(', ')
                : '';
            return [
              '${fares.indexOf(f) + 1}',
              getSectionLabelSafe(f.row.section),
              region,
              f.type == FareType.ft20 ? '20FT' : '40FT',
              '${(f.rate * 100).toStringAsFixed(2)}%',
              _formatNumber(f.price),
              surcharge,
            ];
          }).toList();

          final pageW = PdfPageFormat.a4.width;
          const outerMargin = 18.0;
          const outerPadding = 16.0;
          final availableW = pageW - (outerMargin * 2) - (outerPadding * 2);
          final w0 = 28.0,
              w1 = 80.0,
              w2 = 130.0,
              w3 = 40.0,
              w4 = 50.0,
              w5 = 65.0;
          final fixedSum = w0 + w1 + w2 + w3 + w4 + w5;
          final w6 = (availableW - fixedSum).clamp(80.0, 400.0);

          return [
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey700, width: 0.9),
              ),
              padding: const pw.EdgeInsets.all(16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(child: pw.Text('운 임 견 적 서', style: titleStyle)),
                  pw.SizedBox(height: 18),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        flex: 2,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              '일자: ${_formatDate(DateTime.now())}',
                              style: pw.TextStyle(font: ttf, fontSize: 12),
                            ),
                            pw.SizedBox(height: 6),
                            pw.Text(
                              '화주명: $consignor',
                              style: pw.TextStyle(font: ttf, fontSize: 11),
                            ),
                            pw.SizedBox(height: 25),
                            pw.Text(
                              '1. 귀사의 일익 번창하심을 기원합니다.',
                              style: pw.TextStyle(font: ttf, fontSize: 10),
                            ),
                            pw.SizedBox(height: 6),
                            pw.Text(
                              '2. 문의하신 컨테이너 내륙 운송료 견적드립니다.',
                              style: pw.TextStyle(font: ttf, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Container(
                        width: 280,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                            color: PdfColors.grey400,
                            width: 0.8,
                          ),
                        ),
                        child: pw.Table(
                          columnWidths: {
                            0: const pw.FixedColumnWidth(50),
                            1: const pw.FlexColumnWidth(),
                            2: const pw.FlexColumnWidth(),
                          },
                          children: [
                            buildRow(['-', '수신인', '발신인'], header: true),
                            buildRow([
                              '상호',
                              recipientCompany?.isNotEmpty == true
                                  ? recipientCompany!
                                  : '-',
                              senderCompany.isNotEmpty ? senderCompany : '-',
                            ]),
                            buildRow([
                              '성명',
                              recipient.isNotEmpty ? recipient : '-',
                              senderName.isNotEmpty ? senderName : '-',
                            ]),
                            buildRow([
                              '연락처',
                              recipientPhone?.isNotEmpty == true
                                  ? recipientPhone!
                                  : '-',
                              senderPhone.isNotEmpty ? senderPhone : '-',
                            ]),
                            buildRow([
                              'E-mail',
                              recipientEmail.isNotEmpty ? recipientEmail : '-',
                              senderEmail.isNotEmpty ? senderEmail : '-',
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 18),
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
                color: PdfColors.grey200,
              ),
              padding: const pw.EdgeInsets.symmetric(vertical: 3),
              child: pw.Center(
                child: pw.Text(
                  '견적 내역',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 15,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),
            pw.Container(
              child: pw.Table.fromTextArray(
                headers: headers,
                data: data,
                headerStyle: pw.TextStyle(
                  font: ttf,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
                cellStyle: pw.TextStyle(font: ttf, fontSize: 9),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellAlignment: pw.Alignment.center,
                headerAlignments: {
                  0: pw.Alignment.center,
                  1: pw.Alignment.center,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                  4: pw.Alignment.center,
                  5: pw.Alignment.centerRight,
                  6: pw.Alignment.center,
                },
                columnWidths: {
                  0: pw.FixedColumnWidth(w0),
                  1: pw.FixedColumnWidth(w1),
                  2: pw.FixedColumnWidth(w2),
                  3: pw.FixedColumnWidth(w3),
                  4: pw.FixedColumnWidth(w4),
                  5: pw.FixedColumnWidth(w5),
                  6: pw.FixedColumnWidth(w6),
                },
                cellPadding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                border: pw.TableBorder.all(
                  color: PdfColors.grey400,
                  width: 0.8,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
                    color: PdfColors.grey50,
                  ),
                  child: pw.Row(
                    children: [
                      pw.Text(
                        '총 합계: ',
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Text(
                        _formatNumber(total),
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                '*부가가치세(VAT) 별도.',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
                color: PdfColors.grey200,
              ),
              padding: const pw.EdgeInsets.symmetric(vertical: 3),
              child: pw.Center(
                child: pw.Text(
                  '참고 사항',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 15,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),
            // 참고 사항: 내용이 없어도 고정 영역을 확보하도록 최소 높이 적용
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
              ),
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              constraints: const pw.BoxConstraints(minHeight: 60),
              alignment: pw.Alignment.topLeft,
              child: pw.Text(
                note != null && note.trim().isNotEmpty
                    ? note
                    : '\u00A0', // 비어있을 때 공백으로 영역 유지
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ];
        },
      ),
    );

    final bytes = await doc.save();
    final timestamp = DateFormat('yyyy.MM.dd HH:mm').format(DateTime.now());
    final pdfFileName = '운임 견적서_${consignor}_$timestamp.pdf';
    final tempDir = await getTemporaryDirectory(); // <- 추가
    final file = File('${tempDir.path}${Platform.pathSeparator}$pdfFileName');
    await file.writeAsBytes(bytes);
    return file;
  }

  // ------------------------
  // 이메일 본문 / 제목 빌더
  // ------------------------
  String _buildPlainBody(
    String consignor,
    String recipient,
    String recipientEmail,
    String? recipientCompany,
    String? recipientPhone,
    int count,
  ) {
    final now = DateFormat('yyyy.MM.dd HH:mm').format(DateTime.now());
    final company = (recipientCompany == null || recipientCompany.isEmpty)
        ? '미입력'
        : recipientCompany;
    final phone = (recipientPhone == null || recipientPhone.isEmpty)
        ? '미입력'
        : recipientPhone;

    final buf = StringBuffer()
      ..writeln(' 기준 일시 : $now')
      ..writeln(' 화주       : $consignor')
      ..writeln(' 수신인     : $recipient')
      ..writeln(' 이메일     : $recipientEmail')
      ..writeln(' 상호       : $company')
      ..writeln(' 연락처     : $phone')
      ..writeln(' 건 수      : ${count}건')
      ..writeln('')
      ..writeln('첨부된 PDF 파일에 운임 견적 내역이 정리되어 있습니다.')
      ..writeln('내용 확인 후 문의나 수정 요청이 있으시면 아래 메일로 회신 부탁드립니다.')
      ..writeln('')
      ..writeln('감사합니다.');

    return buf.toString();
  }

  String _buildHtmlBody({
    required String consignor,
    required String recipient,
    required String recipientEmail,
    required String? recipientCompany,
    required String? recipientPhone,
    required int count,
    required SharedPreferences prefs,
  }) {
    final now = DateFormat('yyyy.MM.dd HH:mm').format(DateTime.now());
    final company = (recipientCompany == null || recipientCompany.isEmpty)
        ? '미입력'
        : recipientCompany;
    final phone = (recipientPhone == null || recipientPhone.isEmpty)
        ? '미입력'
        : recipientPhone;
    final storeUrl =
        'https://play.google.com/store/apps/details?id=com.optilo.line_all.comapny';

    // 키/값 테이블 형태로 정리 (inline CSS, 메일 친화적)
    return '''
<div style="font-family:Arial, sans-serif; font-size:14px; color:#333; line-height:1.6; margin:0; padding:0;">
  <table style="width:100%;border-collapse:collapse;margin:0;padding:0;">
    <tbody>
      <tr>
        <td style="width:130px;padding:6px 8px;color:#666;vertical-align:top;">기준 일시</td>
        <td style="padding:6px 8px;">$now</td>
      </tr>
      <tr>
        <td style="padding:6px 8px;color:#666;vertical-align:top;">화주</td>
        <td style="padding:6px 8px;">$consignor</td>
      </tr>
      <tr>
        <td style="padding:6px 8px;color:#666;vertical-align:top;">수신인</td>
        <td style="padding:6px 8px;">$recipient</td>
      </tr>
      <tr>
        <td style="padding:6px 8px;color:#666;vertical-align:top;">이메일</td>
        <td style="padding:6px 8px;">$recipientEmail</td>
      </tr>
      <tr>
        <td style="padding:6px 8px;color:#666;vertical-align:top;">상호</td>
        <td style="padding:6px 8px;">$company</td>
      </tr>
      <tr>
        <td style="padding:6px 8px;color:#666;vertical-align:top;">연락처</td>
        <td style="padding:6px 8px;">$phone</td>
      </tr>
      <tr>
        <td style="padding:6px 8px;color:#666;vertical-align:top;">건 수</td>
        <td style="padding:6px 8px;">${count} 건</td>
      </tr>
    </tbody>
  </table>

  <p style="margin:10px 0 0 0;color:#444;">
    첨부된 PDF 파일에 운임 견적 내역이 정리되어 있습니다.<br/>
    내용 확인 후 문의나 수정 요청이 있으시면 아래 메일로 회신 부탁드립니다.
  </p>

</div>
''';
  }

  // 카드형 HTML 템플릿 (inlined CSS, 테이블 레이아웃)
  String _buildHtmlTemplate(
    String plainBody,
    SharedPreferences prefs,
    String bannerCid,
  ) {
    final storeUrl =
        'https://play.google.com/store/apps/details?id=com.optilo.line_all.comapny';
    final senderCompany = prefs.getString('user_company') ?? '';
    final senderName = prefs.getString('user_name') ?? '';
    final senderPhone = prefs.getString('user_phone') ?? '';
    final senderEmail = prefs.getString('user_email') ?? '';
    // plainBody은 이미 HTML이므로 불필요한 <br> 추가 제거, trim으로 공백 제거
    final htmlMain = plainBody.trim();

    (htmlMain);

    return '''
<!doctype html><html><body style="margin:0;padding:0;font-family:Arial,sans-serif;background:#f6f6f6;">
<table width="100%" cellpadding="0" cellspacing="0"><tr><td align="center">
  <!-- 카드 패딩을 줄이고 불필요한 분리 행 제거 -->
  <table width="600" style="max-width:600px;background:#fff;padding:12px;border-radius:8px;border:1px solid #e9e9e9;">
    <tr>
      <td style="width:60px;vertical-align:top;padding:0;">
        <img src="cid:$bannerCid" alt="" style="display:block;border:0;width:48px;height:auto;line-height:0;vertical-align:middle;" />
      </td>
      <td style="vertical-align:top;padding-left:12px;padding-top:4px;">
        <h2 style="margin:0;color:#1c63d6;font-size:18px;line-height:1;">운임 견적서</h2>
        <p style="margin:4px 0 0 0;color:#444;font-size:13px;line-height:1.2;">안녕하세요. 안전 운임 App 메일 서비스입니다.</p>
      </td>
    </tr>
    <!-- 바로 본문 영역 -->
    <tr>
      <td colspan="2" style="padding-top:8px;color:#333;font-size:14px;line-height:1.6;margin:0;">
        $htmlMain
      </td>
    </tr>
    <tr>
      <td colspan="2" style="padding-top:12px;">
        <a href="$storeUrl" style="display:inline-block;background:#1c63d6;color:#fff;padding:10px 14px;border-radius:6px;text-decoration:none;font-size:14px;">앱 살펴보기</a>
      </td>
    </tr>
    <tr>
      <td colspan="2" style="padding-top:12px;border-top:1px solid #f5f5f5;color:#888;font-size:12px;">
        <strong style="color:#333;font-size:13px;display:block;margin:0 0 4px 0;">${senderCompany}</strong>
        ${senderName.isNotEmpty ? '<span style="display:block;margin:0 0 2px 0;">${senderName}</span>' : ''}
        ${senderPhone.isNotEmpty ? '<span style="display:block;margin:0 0 2px 0;">Tel: ${senderPhone}</span>' : ''}
        ${senderEmail.isNotEmpty ? '<span style="display:block;margin:0;">Email: ${senderEmail}</span>' : ''}
      </td>
    </tr>
  </table>
</td></tr></table></body></html>
''';
  }

  String _buildSubject(SharedPreferences prefs, String consignor) {
    final storedCompany = prefs.getString('user_company') ?? '';
    final safeSender = storedCompany.isNotEmpty
        ? _safeForHeader(storedCompany)
        : '발신자';
    final safeConsignor = _safeForHeader(consignor);
    final date = DateFormat('yyyy.MM.dd').format(DateTime.now());
    return '운임 견적서 $date — ($safeSender → $safeConsignor)';
  }

  // ------------------------
  // 유틸
  // ------------------------
  String _safeForHeader(String s, {int maxLen = 40}) {
    var t = s.replaceAll(RegExp(r'[\r\n]+'), ' ').trim();
    t = t.replaceAll(RegExp(r'[^\x20-\x7E\u0080-\uFFFF]'), '');
    if (t.length > maxLen) t = t.substring(0, maxLen) + '…';
    return t;
  }

  String _formatNumber(int v) {
    final s = v.toString();
    final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(reg, (m) => ',');
  }

  String _formatDate(DateTime d) => '${d.year}년 ${d.month}월 ${d.day}일';

  String getSectionLabelSafe(dynamic section) {
    try {
      return getSectionLabel(section);
    } catch (_) {
      return section?.toString() ?? '섹션 정보 없음';
    }
  }
}
