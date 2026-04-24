// A
//                 const SizedBox(height: 100),

//                 const Text(
//                   'Selamat Datang',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 36,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   'Silahkan masuk ke akun Identra Studio Anda.',
//                   style: TextStyle(
//                     color: Colors.grey,
//                     fontSize: 14,
//                   ),
//                 ),

//                 const SizedBox(height: 40),

//                 _buildLabel('EMAIL ADDRESS'),
//                 const SizedBox(height: 8),
//                 _buildTextField(hintText: 'User@gmail.com', obscureText: false),

//                 const SizedBox(height: 24),

//                 _buildLabel('PASSWORD'),
//                 const SizedBox(height: 8),
//                 _buildTextField(hintText: '*************', obscureText: true),

//                 const SizedBox(height: 32),

//                 SizedBox(
//                   width: double.infinity,
//                   height: 52,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // DUMMY LOGIN — langsung ke dashboard tanpa validasi backend
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const DashboardScreen(),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: Colors.black,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: const Text(
//                       'Masuk Sekarang',
//                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: GestureDetector(
//                     onTap: () {
//                       // TODO: navigasi ke halaman lupa password
//                     },
//                     child: const Text(
//                       'Lupa password?',
//                       style: TextStyle(color: Colors.grey, fontSize: 13),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 40),

//                 Center(
//                   child: GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const RegisterScreen(),
//                         ),
//                       );
//                     },
//                     child: RichText(
//                       text: const TextSpan(
//                         text: 'Belum bergabung dengan kami? ',
//                         style: TextStyle(color: Colors.grey, fontSize: 13),
//                         children: [
//                           TextSpan(
//                             text: 'DAFTAR AKUN',
//                             style: TextStyle(
//                                 color: Colors.white, fontWeight: FontWeight.bold),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLabel(String text) {
//     return Text(
//       text,
//       style: const TextStyle(
//         color: Colors.grey,
//         fontSize: 12,
//         fontWeight: FontWeight.bold,
//         letterSpacing: 1.2,
//       ),
//     );
//   }

//   Widget _buildTextField(
//       {required String hintText, required bool obscureText}) {
//     return TextField(
//       obscureText: obscureText,
//       style: const TextStyle(color: Colors.white),
//       decoration: InputDecoration(
//         filled: true,
//         fillColor: const Color(0xFF707172),
//         hintText: hintText,
//         hintStyle: const TextStyle(color: Colors.white70),
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'services/api_service.dart'; // Import service yang tadi dibuat

// void main() => runApp(const MyApp());

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: TestKoneksiScreen(),
//     );
//   }
// }

// class TestKoneksiScreen extends StatefulWidget {
//   @override
//   _TestKoneksiScreenState createState() => _TestKoneksiScreenState();
// }

// class _TestKoneksiScreenState extends State<TestKoneksiScreen> {
//   String hasilResponse = "Belum ada data";
//   final ApiService _apiService = ApiService(); // Panggil class service

//   void jalankanTes() async {
//     setState(() => hasilResponse = "Sedang menghubungkan...");
//     String pesan = await _apiService.cekKoneksiKeLaravel();
//     setState(() => hasilResponse = pesan);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Identra Studio - API Test")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(hasilResponse, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: jalankanTes,
//               child: const Text("Cek Koneksi ke Laravel"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// lib/main.dart

import 'package:flutter/material.dart';
import 'services_screen.dart';
import 'login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Identra Studio',
      home: const LoginScreen(), // Menuju halaman Service langsung
    );
  }
}