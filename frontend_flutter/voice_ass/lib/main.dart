import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  // Đảm bảo các ràng buộc hệ thống được khởi tạo trước khi vẽ giao diện
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DemoBankingApp());
}

class DemoBankingApp extends StatelessWidget {
  const DemoBankingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Voice Banking Assistant',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const MainBankingScreen(),
    );
  }
}

class MainBankingScreen extends StatefulWidget {
  const MainBankingScreen({super.key});

  @override
  State<MainBankingScreen> createState() => _MainBankingScreenState();
}

class _MainBankingScreenState extends State<MainBankingScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _isListening = false;
  String _speechText = "Nhấn nút màu xanh bên dưới để ra lệnh...";
  String _botResponse = "";
  final double _balance = 50000000; // Mô phỏng số dư tài khoản

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() {
    _flutterTts.setLanguage("vi-VN");
    _flutterTts.setSpeechRate(0.55); // Tốc độ nói chuẩn trợ lý ảo
  }

  // XỬ LÝ ĐIỀU KHIỂN GIỌNG NÓI (Tích hợp VAD và Barge-In)
  void _listenAndProcess() async {
    // [TÍNH NĂNG BARGE-IN]: Nếu Bot đang nói, người dùng bấm nút sẽ ngắt lời Bot ngay lập tức
    await _flutterTts.stop();

    if (!_isListening) {
      // Gọi hàm initialize, trình duyệt Chrome sẽ tự động hỏi quyền Micro tại đây
      bool available = await _speech.initialize(
        onStatus: (status) {
          debugPrint('STT Status: $status');
          // [TÍNH NĂNG VAD]: Phát hiện người dùng ngừng nói (notListening) thì tự ngắt mic và gửi dữ liệu
          if (status == 'notListening' && _isListening) {
            setState(() {
              _isListening = false;
            });
            _sendRequestToBackend(_speechText);
          }
        },
        onError: (error) {
          debugPrint('STT Error: $error');
          setState(() {
            _isListening = false;
            _speechText = "Tôi không nghe rõ, cậu có thể nói lại không?";
          });
        },
      );

      if (available) {
        setState(() {
          _isListening = true;
          _speechText = "Tôi đang nghe đây, cậu nói đi...";
        });

        _speech.listen(
          onResult: (result) {
            setState(() {
              _speechText = result.recognizedWords;
            });
          },
          localeId: 'vi_VN',
          // [TÍNH NĂNG VAD]: Sau 2 giây nếu không nhận thêm âm thanh, hệ thống coi như dứt câu
          pauseFor: const Duration(seconds: 2),
        );
      } else {
        setState(() {
          _speechText = "Trình duyệt không hỗ trợ hoặc bị từ chối quyền Micro.";
        });
      }
    } else {
      // Nếu đang nghe mà bấm lần nữa thì chủ động dừng
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // KẾT NỐI API ĐẾN PYTHON BACKEND
  Future<void> _sendRequestToBackend(String text) async {
    if (text.trim().isEmpty || text.startsWith("Tôi đang nghe") || text.startsWith("Nhấn nút")) return;

    // Vì chạy trên Web cùng máy với Python nên dùng trực tiếp localhost
    final url = Uri.parse('http://127.0.0.1:8000/api/voice-banking');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _botResponse = data['response'];
        });
        // Trợ lý ảo phát giọng nói phản hồi (Response / /rɪˈspɒns/ )
        await _flutterTts.speak(_botResponse);
      } else {
        setState(() => _botResponse = "Lỗi hệ thống máy chủ phục vụ.");
      }
    } catch (e) {
      setState(() => _botResponse = "Không thể kết nối đến Python Backend. Hãy đảm bảo server.py đang chạy.");
      debugPrint('Lỗi kết nối: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[900],
      appBar: AppBar(
        title: const Text('GENESIS DIGITAL BANK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Giao diện (Interface / /ˈɪn.tə.feɪs/ ) Thẻ Ngân Hàng mô phỏng
          Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.indigo, Colors.purple, Colors.pink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('VIP PLATINUM', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    Icon(Icons.wifi, color: Colors.white70,),
                  ],
                ),
                Text('${_balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VND',
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const Text('**** **** **** 8888', style: TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 3)),
              ],
            ),
          ),

          // Khung hiển thị tương tác Trợ lý giọng nói (Voice assistant / /vɔɪs əˈsɪs.tənt/ )
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(36), topRight: Radius.circular(36)),
              ),
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Nội dung cậu nói:',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500], fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '"$_speechText"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, color: Colors.black87, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
                  ),
                  const Divider(height: 60, thickness: 1),
                  Text(
                    'Trợ lý phản hồi:',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500], fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _botResponse.isNotEmpty ? _botResponse : "(Đang chờ lệnh...)",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, color: Colors.indigo, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          )
        ],
      ),

      // Nút kích hoạt hiệu ứng sóng âm khi AI đang lắng nghe
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Colors.purple,
        duration: const Duration(milliseconds: 1200),
        repeat: true,
        child: FloatingActionButton.large(
          onPressed: _listenAndProcess,
          backgroundColor: _isListening ? Colors.redAccent : Colors.tealAccent[700],
          elevation: 8,
          shape: const CircleBorder(),
          child: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.white, size: 36),
        ),
      ),
    );
  }
}