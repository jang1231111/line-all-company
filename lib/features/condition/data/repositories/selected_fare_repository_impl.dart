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

import 'package:line_all/features/condition/domain/repositories/selected_fare_repository.dart';
import 'package:line_all/features/condition/presentation/models/selected_fare.dart';
import 'package:line_all/features/condition/presentation/data/condition_options.dart';

class SelectedFareRepositoryImpl implements SelectedFareRepository {
  SelectedFareRepositoryImpl();

  // 메인 API: PDF 생성 + 메일 전송
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
    final htmlBody = _buildHtmlBody(bodyPlain, prefs);

    // --- 배너 이미지 준비 (임시파일로 저장, CID로 인라인 첨부) ---
    final tempDir = await getTemporaryDirectory();
    final bannerBytes = (await rootBundle.load('lib/assets/icon/app_icon.png')).buffer.asUint8List();
    final bannerFile = File('${tempDir.path}${Platform.pathSeparator}app_icon.png');
    await bannerFile.writeAsBytes(bannerBytes);
    final bannerCid = 'mail_banner@lineall';

    // 표시 크기(px) 고정: 필요에 따라 240/300 등 값 조정
    final bannerHtml = '<a href="https://play.google.com/store/apps/details?id=com.optilo.line_all.comapny" target="_blank" rel="noopener">'
        '<img src="cid:$bannerCid" alt="앱 다운로드" style="display:block;margin:12px auto;width:300px;max-width:100%;height:auto;border:0;" />'
        '</a><br/>';

    // '[견적 정보]' 텍스트 바로 뒤에 배너를 삽입. 없으면 본문 앞에 추가.
    final htmlWithBanner = htmlBody.contains('[견적 정보]')
        ? htmlBody.replaceFirst('[견적 정보]', '[견적 정보]' + bannerHtml)
        : bannerHtml + htmlBody;

    // 이미지 첨부(인라인)
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
        ..html = htmlWithBanner // CID 이미지가 포함된 HTML
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
  // PDF 생성 (분리된 함수)
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
    final subStyle = pw.TextStyle(
      font: ttf,
      fontSize: 10,
      color: PdfColors.grey700,
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

    pw.TableRow buildRow(List<String> cols, {bool header = false}) {
      return pw.TableRow(
        children: cols.map((c) => cell(c, isHeader: header)).toList(),
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(18),
        build: (pw.Context ctx) {
          // 표 데이터 준비
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

          // 가변 너비 계산 (기존 로직 유지)
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
            pw.SizedBox(height: 8),
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
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
              ),
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 3,
                vertical: 3,
              ),
              child: pw.Text(
                note,
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
    final tempDir = await getTemporaryDirectory();
    final safeConsignor = consignor
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');
    final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final pdfFileName = 'FareQuote_${safeConsignor}_$timestamp.pdf';
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
    final buf = StringBuffer()
      ..writeln('')
      ..writeln('안녕하세요. 안전 운임 App 메일 서비스입니다.')
      ..writeln('')
      ..writeln('[견적 정보]')
      ..writeln(
        '- 기준 일시: ${DateFormat('yyyy.MM.dd HH:mm').format(DateTime.now())}',
      )
      ..writeln('- 화주: $consignor')
      ..writeln('- 수신인: $recipient')
      ..writeln('- 이메일: $recipientEmail')
      ..writeln('- 상호: $recipientCompany')
      ..writeln('- 연락처: $recipientPhone')
      ..writeln('- 건 수: $count 건')
      ..writeln('')
      ..writeln('첨부된 PDF 파일에 선택하신 운임 견적 내역이 정리되어 있습니다.')
      ..writeln('내용 확인 후 문의나 수정 요청이 있으시면 아래 발신자 정보의 메일로 회신 부탁드립니다.')
      ..writeln('')
      ..writeln(
        '앱 다운로드: https://play.google.com/store/apps/details?id=com.optilo.line_all.comapny',
      )
      ..writeln('')
      ..writeln('감사합니다.')
      ..writeln('');
    return buf.toString();
  }

  String _buildHtmlBody(String plainBody, SharedPreferences prefs) {
    final htmlMain = plainBody.replaceAll('\n', '<br>');
    final senderCompany = prefs.getString('user_company') ?? '';
    final senderName = prefs.getString('user_name') ?? '';
    final senderPhone = prefs.getString('user_phone') ?? '';
    final senderEmail = prefs.getString('user_email') ?? '';

    final senderHtml =
        '''
<div style="font-family: Arial, sans-serif; font-size:12px; color:#666; margin-top:12px;">
  <strong>${senderCompany.isNotEmpty ? senderCompany : ''}</strong><br>
  ${senderName.isNotEmpty ? senderName + '<br>' : ''}
  ${senderPhone.isNotEmpty ? 'Tel: $senderPhone<br>' : ''}
  ${senderEmail.isNotEmpty ? 'Email: $senderEmail' : ''}
</div>
''';
    return '<div style="font-family: Arial, sans-serif; font-size:14px; line-height:1.4;">$htmlMain</div>$senderHtml';
  }

  String _buildSubject(SharedPreferences prefs, String consignor) {
    final storedCompany = prefs.getString('user_company') ?? '';
    final safeSender = storedCompany.isNotEmpty
        ? _safeForHeader(storedCompany)
        : '발신자';
    final safeConsignor = _safeForHeader(consignor);
    final date = DateFormat('yyyy.MM.dd').format(DateTime.now());
    return '운임 견적서 $date — ($storedCompany → $safeConsignor)';
  }

  // ------------------------
  // 유틸들
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

  String _formatDate(DateTime d) {
    return '${d.year}년 ${d.month}월 ${d.day}일';
  }

  String getSectionLabelSafe(dynamic section) {
    try {
      return getSectionLabel(section);
    } catch (_) {
      return section?.toString() ?? '섹션 정보 없음';
    }
  }
}
