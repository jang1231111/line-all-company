import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:line_all/features/condition/domain/repositories/selected_fare_repository.dart';
import 'package:line_all/features/condition/presentation/models/selected_fare.dart';
import 'package:line_all/features/condition/presentation/data/condition_options.dart';

class SelectedFareRepositoryImpl implements SelectedFareRepository {
  SelectedFareRepositoryImpl();

  @override
  Future<bool> sendSelectedFares({
    required String consignor,
    required String email,
    required List<SelectedFare> fares,
  }) async {
    final host = dotenv.env['SMTP_SERVER'];
    final port = int.tryParse(dotenv.env['SMTP_PORT'] ?? '587') ?? 587;
    final username = dotenv.env['SMTP_ID'];
    final password = dotenv.env['SMTP_PASSWORD'];

    if (host == null || username == null || password == null) {
      return false;
    }

    // PDF 생성
    Future<File> _createPdfFile() async {
      final doc = pw.Document();

      // 한글 폰트 로드 (assets/fonts/NotoSansKR-Regular.ttf 를 프로젝트에 추가하고 pubspec.yaml에 등록하세요)
      final fontData = await rootBundle.load(
        'lib/assets/fonts/NotoSansKR-Regular.ttf',
      );
      final ttf = pw.Font.ttf(fontData);

      // 로컬 헬퍼: 모든 텍스트에서 ttf 사용하도록 통일
      pw.Widget cell(String text, {bool isHeader = false}) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            text,
            style: isHeader
                ? pw.TextStyle(font: ttf, fontSize: 10, fontWeight: pw.FontWeight.bold)
                : pw.TextStyle(font: ttf, fontSize: 10),
          ),
        );
      }

      // 폰트 적용된 스타일
      final titleStyle = pw.TextStyle(
        font: ttf,
        fontSize: 22,
        fontWeight: pw.FontWeight.bold,
      );
      final headerStyle = pw.TextStyle(
        font: ttf,
        fontSize: 10,
        color: PdfColors.grey700,
      );
      final cellStyle = pw.TextStyle(font: ttf, fontSize: 10);
      final boldCell = pw.TextStyle(
        font: ttf,
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
      );

      final total = fares.fold<int>(0, (s, f) => s + f.price);

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // 제목
                pw.Center(child: pw.Text('운 임 견 적 서', style: titleStyle)),
                pw.SizedBox(height: 14),

                // 상단: 일자 + 수신/발신 표
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
                            style: headerStyle,
                          ),
                          pw.SizedBox(height: 12),
                          pw.Text('1. 귀사의 일익 번창하심을 기원합니다.', style: cellStyle),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            '2. 문의하신 컨테이너 내륙 운송료 견적드립니다.',
                            style: cellStyle,
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                        ),
                        child: pw.Table(
                          border: pw.TableBorder.symmetric(),
                          defaultVerticalAlignment:
                              pw.TableCellVerticalAlignment.middle,
                          children: [
                            pw.TableRow(
                              children: [
                                cell(' ', isHeader: true),
                                cell('수신인', isHeader: true),
                                cell('발신인', isHeader: true),
                              ],
                            ),
                            pw.TableRow(
                              children: [
                                cell('상호'),
                                cell(consignor),
                                cell(username ?? ''),
                              ],
                            ),
                            pw.TableRow(
                              children: [
                                cell('성명'),
                                cell('-'),
                                cell('-'),
                              ],
                            ),
                            pw.TableRow(
                              children: [
                                cell('연락처'),
                                cell('-'),
                                cell('-'),
                              ],
                            ),
                            pw.TableRow(
                              children: [
                                cell('E-mail'),
                                cell(email),
                                cell(username ?? ''),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 18),

                // 견적 내역 박스 제목
                pw.Container(
                  width: double.infinity,
                  color: PdfColors.grey200,
                  padding: const pw.EdgeInsets.symmetric(vertical: 6),
                  child: pw.Center(child: pw.Text('견적 내역', style: boldCell)),
                ),
                pw.SizedBox(height: 8),

                // 테이블 헤더 + 내용
                pw.Table.fromTextArray(
                  headers: ['No', '항구', '지역', '규격', '할증률', '가격(원)', '비고(할증)'],
                  data: List<List<String>>.generate(fares.length, (i) {
                    final f = fares[i];
                    return [
                      '${i + 1}',
                      getSectionLabelSafe(f.row.section),
                      '${f.row.sido}${f.row.sigungu.isNotEmpty ? ' ${f.row.sigungu}' : ''}${f.row.eupmyeondong.isNotEmpty ? ' ${f.row.eupmyeondong}' : ''}',
                      f.type == FareType.ft20 ? '20FT' : '40FT',
                      '${(f.rate * 100).toStringAsFixed(2)}%',
                      '${_formatNumber(f.price)}',
                      f.surchargeLabels.isNotEmpty
                          ? f.surchargeLabels.join(', ')
                          : '',
                    ];
                  }),
                  headerStyle: pw.TextStyle(
                    font: ttf,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  cellStyle: pw.TextStyle(font: ttf, fontSize: 10),
                  cellAlignment: pw.Alignment.centerLeft,
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.grey100,
                  ),
                  columnWidths: {
                    0: const pw.FixedColumnWidth(24),
                    1: const pw.FixedColumnWidth(80),
                    2: const pw.FlexColumnWidth(),
                    3: const pw.FixedColumnWidth(40),
                    4: const pw.FixedColumnWidth(50),
                    5: const pw.FixedColumnWidth(70),
                    6: const pw.FixedColumnWidth(90),
                  },
                ),

                pw.SizedBox(height: 8),

                // 총 합계 우측 정렬
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('총 합계', style: boldCell),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '${_formatNumber(total)}원',
                          style: pw.TextStyle(
                            font: ttf,
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                pw.Spacer(),

                // VAT 주석
                pw.Align(
                  alignment: pw.Alignment.bottomRight,
                  child: pw.Text(
                    '*부가가치세(VAT) 별도.',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 9,
                      color: PdfColors.grey700,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

      final bytes = await doc.save();
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/fare_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(bytes);
      return file;
    }

    // 메일 기본 텍스트 (본문)
    final body = StringBuffer()
      ..writeln('화주: $consignor')
      ..writeln('수신: $email')
      ..writeln('')
      ..writeln('첨부된 견적서를 확인하세요.');

    final smtpServer = SmtpServer(
      host,
      port: port,
      username: username,
      password: password,
    );

    final message = Message()
      ..from = Address(username ?? '', '운임 전송')
      ..recipients.add(email)
      ..subject = '운임 전송 - $consignor'
      ..text = body.toString();

    try {
      // PDF 생성 및 첨부
      final pdfFile = await _createPdfFile();
      message.attachments.add(FileAttachment(pdfFile));
    } catch (e) {
      // PDF 생성 실패 시 로그 남기고 본문만 전송 시도
      print('PDF 생성 실패: $e');
    }

    try {
      await send(message, smtpServer);
      return true;
    } on MailerException catch (e) {
      print('MailerException: $e');
      return false;
    } catch (e) {
      print('메일 전송 실패: $e');
      return false;
    }
  }

  // 유틸: 숫자 포매트(천단위)
  String _formatNumber(int v) {
    final s = v.toString();
    final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(reg, (m) => ',');
  }

  // 유틸: 날짜 포맷 YYYY년 MM월 DD일
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
