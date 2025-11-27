import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
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

      // 한글 폰트: 프로젝트에 assets/fonts/NotoSansKR-Regular.ttf 등록 필요
      final fontData = await rootBundle.load(
        'lib/assets/fonts/NotoSansKR-Regular.ttf',
      );
      final ttf = pw.Font.ttf(fontData);

      // 단일 셀 헬퍼: minHeight == 0 이면 내용에 따라 높이 자동 확장
      pw.Widget cell(
        String text, {
        bool isHeader = false,
        double minHeight = 0,
      }) {
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
          // 세로 정렬을 위로 고정하여 비고 셀에 맞춰 행이 늘어나면 동일하게 확장되도록 함
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(text, style: style, textAlign: pw.TextAlign.center),
            ],
          ),
        );
      }

      // 동일한 행 레이아웃 생성기 (헤더/데이터 둘 다 사용)
      pw.TableRow buildRow(List<String> cols, {bool header = false}) {
        return pw.TableRow(
          decoration: header
              ? const pw.BoxDecoration(color: PdfColors.grey300)
              : null,
          children: List.generate(cols.length, (i) {
            return cell(cols[i], isHeader: header);
          }),
        );
      }

      // 스타일
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

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(18),
          build: (pw.Context ctx) {
            return [
              // 상단 박스: 제목 / 안내문 / 수신정보 등 (테이블과 분리)
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
                            borderRadius: pw.BorderRadius.circular(1),
                          ),
                          child: pw.Table(
                            columnWidths: {
                              0: const pw.FixedColumnWidth(50),
                              1: const pw.FlexColumnWidth(),
                              2: const pw.FlexColumnWidth(),
                            },
                            children: [
                              buildRow(['-', '수신인', '발신인'], header: true),
                              pw.TableRow(
                                children: [
                                  cell('상호', isHeader: true),
                                  cell('-'),
                                  cell('-'),
                                ],
                              ),
                              pw.TableRow(
                                children: [
                                  cell('성명', isHeader: true),
                                  cell(consignor),
                                  cell('-'),
                                ],
                              ),
                              pw.TableRow(
                                children: [
                                  cell('연락처', isHeader: true),
                                  cell('-'),
                                  cell('-'),
                                ],
                              ),
                              pw.TableRow(
                                children: [
                                  cell('E-mail', isHeader: true),
                                  cell(email),
                                  cell('-'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 18),

              // 견적 내역 제목 (표와 시각적으로 구분)
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
                  borderRadius: pw.BorderRadius.circular(1),
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

              // --- 표: Table.fromTextArray로 교체 (페이지 넘어갈 때 헤더 반복)
              (() {
                final pageW = PdfPageFormat.a4.width;
                final outerMargin = 18.0;
                final outerPadding = 16.0;
                final availableW =
                    pageW - (outerMargin * 2) - (outerPadding * 2);

                final w0 = 28.0;
                final w1 = 80.0;
                final w2 = 130.0;
                final w3 = 40.0;
                final w4 = 50.0;
                final w5 = 65.0;
                final fixedSum = w0 + w1 + w2 + w3 + w4 + w5;
                final w6 = (availableW - fixedSum).clamp(80.0, 400.0);

                final headers = [
                  'No',
                  '항구',
                  '지역',
                  '규격',
                  '할증률',
                  '가격(원)',
                  '비고(할증)',
                ];

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

                return pw.Container(
                  // 내부 셀별로 경계를 주기 때문에 외부 박스는 지양
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
                );
              }()),

              pw.SizedBox(height: 10),

              // 총합계 및 VAT 주석: 표 아래에 위치
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        color: PdfColors.grey400,
                        width: 0.8,
                      ),
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
            ];
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
