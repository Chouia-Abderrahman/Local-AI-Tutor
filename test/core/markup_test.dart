import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_study_assistant/core/text/markup.dart';

void main() {
  test('bold markers become bold segments', () {
    expect(boldSegments('Mitochondria make **ATP** for the cell.'), [
      (text: 'Mitochondria make ', bold: false),
      (text: 'ATP', bold: true),
      (text: ' for the cell.', bold: false),
    ]);
    expect(boldSegments('**One** and **two**'), [
      (text: 'One', bold: true),
      (text: ' and ', bold: false),
      (text: 'two', bold: true),
    ]);
    expect(boldSegments('No markup.'), [(text: 'No markup.', bold: false)]);
    // Still streaming: the closing marker hasn't come yet.
    expect(boldSegments('They make **AT'), [
      (text: 'They make AT', bold: false),
    ]);
  });
}
