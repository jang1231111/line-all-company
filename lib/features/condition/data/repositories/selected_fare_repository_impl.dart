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
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(18),
          build: (pw.Context ctx) {
            return pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey700, width: 0.9),
              ),
              padding: const pw.EdgeInsets.all(16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(child: pw.Text('운 임 견 적 서', style: titleStyle)),
                  pw.SizedBox(height: 18),

                  // 상단: 좌(문구) 우(수신/발신)
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

                      // 우측 카드: 3열(레이블, 수신인, 발신인)
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

                  pw.SizedBox(height: 18),

                  // 견적 내역 제목
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        color: PdfColors.grey400,
                        width: 0.8,
                      ),
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
                  // --- 커스텀 표: row-기반으로 각 행 높이를 "행 내에서 가장 큰 셀 높이"로 맞춤 ---
                  // 컬럼 폭 정의 (flex 칼럼은 나머지 너비를 차지)
                  (() {
                    final pageW = PdfPageFormat.a4.width;
                    final outerMargin = 18.0; // pw.Page margin
                    final outerPadding = 16.0; // 본문 Container padding
                    final availableW =
                        pageW - (outerMargin * 2) - (outerPadding * 2);

                    // 고정/대체 폭 (총합이 availableW 가 되도록 flex 컬럼 계산)
                    final w0 = 28.0;
                    final w1 = 80.0;
                    final w2 = 130.0;
                    final w3 = 40.0;
                    final w4 = 50.0;
                    final w5 = 65.0;
                    final fixedSum = w0 + w1 + w3 + w4 + w5 + w2;
                    final w6 = (availableW - fixedSum).clamp(80.0, 400.0);
                    final colWidths = [w0, w1, w2, w3, w4, w5, w6];

                    // 텍스트 높이(근사) 계산: 글자 수 기반으로 줄 수 추정
                    double estimateTextHeight(
                      String text,
                      double width,
                      double fontSize,
                    ) {
                      if (text.isEmpty) return fontSize * 1.6;
                      final avgCharWidth = fontSize * 0.55; // 근사값
                      final charsPerLine = (width / avgCharWidth).floor().clamp(
                        6,
                        300,
                      );
                      final lines = (text.length / charsPerLine).ceil();
                      final lineHeight = fontSize * 1.15;
                      final paddingV = 12.0;
                      return lines * lineHeight + paddingV + 20;
                    }

                    // 셀 빌더 (height 고정)
                    pw.Widget buildCell(
                      String text,
                      double w,

                      double height, {
                      bool isHeader = false,
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
                        width: w,
                        height: height,
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: pw.BoxDecoration(
                          color: bg,
                          border: pw.Border.all(
                            color: PdfColors.grey400,
                            width: 0.8,
                          ),
                        ),
                        child: pw.Align(
                          alignment: pw.Alignment.center,

                          child: pw.Text(
                            text,
                            style: style,
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      );
                    }

                    // 헤더 행 렌더러
                    final headerHeight = 32.0;
                    final headerRow = pw.Row(
                      children: [
                        for (var i = 0; i < 7; i++)
                          buildCell(
                            [
                              'No',
                              '항구',
                              '지역',
                              '규격',
                              '할증률',
                              '가격(원)',
                              '비고(할증)',
                            ][i],
                            colWidths[i],
                            headerHeight,
                            isHeader: true,
                          ),
                      ],
                    );

                    // 데이터 행들: 각 셀 예상 높이를 구해 그 중 최대값으로 통일
                    final dataRows = fares.map<pw.Widget>((f) {
                      final region =
                          '${f.row.sido}${f.row.sigungu.isNotEmpty ? ' ${f.row.sigungu}' : ''}${f.row.eupmyeondong.isNotEmpty ? ' ${f.row.eupmyeondong}' : ''}';
                      final surcharge = f.surchargeLabels.isNotEmpty
                          ? f.surchargeLabels.join(', ')
                          : '';
                      final cols = [
                        '${fares.indexOf(f) + 1}',
                        getSectionLabelSafe(f.row.section),
                        region,
                        f.type == FareType.ft20 ? '20FT' : '40FT',
                        '${(f.rate * 100).toStringAsFixed(2)}%',
                        _formatNumber(f.price),
                        surcharge,
                      ];

                      // 각 컬럼별 예상 높이
                      final estHeights = List<double>.generate(7, (i) {
                        final txt = cols[i];
                        return estimateTextHeight(
                          txt,
                          colWidths[i] - 16 /*padding 양쪽*/,
                          i == 5 ? 10 : 9,
                        );
                      });
                      final rowH = estHeights
                          .reduce((a, b) => a > b ? a : b)
                          .clamp(36.0, 999.0);

                      return pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: List.generate(7, (i) {
                          return buildCell(cols[i], colWidths[i], rowH);
                        }),
                      );
                    }).toList();

                    // 총합계 바 (표 바로 아래에 가로로)
                    final totalBar = pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border(
                          top: pw.BorderSide(
                            color: PdfColors.grey700,
                            width: 1,
                          ),
                          left: pw.BorderSide(
                            color: PdfColors.grey400,
                            width: 0.8,
                          ),
                          right: pw.BorderSide(
                            color: PdfColors.grey400,
                            width: 0.8,
                          ),
                          bottom: pw.BorderSide(
                            color: PdfColors.grey400,
                            width: 0.8,
                          ),
                        ),
                        color: PdfColors.grey50,
                      ),
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 6,
                      ),
                      width: colWidths.reduce((a, b) => a + b),
                      child: pw.Row(
                        children: [
                          pw.SizedBox(width: colWidths[6] - colWidths[5]),
                          pw.Expanded(
                            child: pw.Text(
                              '총 합계',
                              style: pw.TextStyle(
                                font: ttf,
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Text(
                            _formatNumber(total),
                            style: pw.TextStyle(
                              font: ttf,
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.right,
                          ),
                          pw.SizedBox(width: colWidths[6] - colWidths[5]),
                        ],
                      ),
                    );

                    return pw.Column(
                      children: [
                        // 외곽 상단 경계
                        headerRow,
                        for (final r in dataRows) r,
                        // 총합계
                        pw.SizedBox(height: 4),
                        totalBar,
                      ],
                    );
                  }()),

                  // --- end custom table ---
                  pw.SizedBox(height: 10),

                  // VAT 주석
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
                ],
              ),
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
