// Xóa bỏ dòng nhập thư viện dư thừa dưới đây:
// import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:voice_ass/main.dart'; // Lưu ý đổi tên voice_ass theo đúng dự án của cậu

void main() {
  testWidgets('Kiểm tra khởi tạo giao diện DemoBankingApp', (WidgetTester tester) async {
    await tester.pumpWidget(const DemoBankingApp());
    expect(find.text('Trợ lý Ảo Ngân Hàng'), findsOneWidget);
  });
}