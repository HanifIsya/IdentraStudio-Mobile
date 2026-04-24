// import 'package:flutter/material.dart';

// // ─────────────────────────────────────────
// // HALAMAN REGISTER
// // ─────────────────────────────────────────

// class RegisterScreen extends StatelessWidget {
//   const RegisterScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           color: Color(0xFF181A1B),
//           gradient: RadialGradient(
//             center: Alignment(1.0, -1.0),
//             radius: 1.2,
//             colors: [
//               Color(0xFF4A4E53),
//               Color(0xFF181A1B),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'IDENTRA\nSTUDIO.',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.w900,
//                     height: 1.1,
//                   ),
//                 ),

//                 const SizedBox(height: 60),

//                 const Center(
//                   child: Text(
//                     'Create new\nAccount',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                       height: 1.1,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 50),

//                 Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _buildLabel('NAMA DEPAN'),
//                           const SizedBox(height: 8),
//                           _buildTextField(
//                               hintText: 'Nama Depan', obscureText: false),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _buildLabel('NAMA BELAKANG'),
//                           const SizedBox(height: 8),
//                           _buildTextField(
//                               hintText: 'Nama Belakang', obscureText: false),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 24),

//                 _buildLabel('EMAIL ADDRESS'),
//                 const SizedBox(height: 8),
//                 _buildTextField(
//                     hintText: 'User@gmail.com', obscureText: false),

//                 const SizedBox(height: 24),

//                 _buildLabel('PASSWORD'),
//                 const SizedBox(height: 8),
//                 _buildTextField(
//                     hintText: '*************', obscureText: true),

//                 const SizedBox(height: 32),

//                 SizedBox(
//                   width: double.infinity,
//                   height: 52,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // TODO: action daftar (hubungkan ke backend)
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: Colors.black,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: const Text(
//                       'DAFTAR SEKARANG',
//                       style:
//                           TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 24),

//                 Center(
//                   child: GestureDetector(
//                     onTap: () {
//                       Navigator.pop(context);
//                     },
//                     child: RichText(
//                       text: const TextSpan(
//                         text: 'Sudah punya akun? ',
//                         style: TextStyle(color: Colors.grey, fontSize: 11),
//                         children: [
//                           TextSpan(
//                             text: 'MASUK DI SINI',
//                             style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold),
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
//         fontSize: 11,
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




import 'package:flutter/material.dart';
import 'services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final ApiService _apiService = ApiService();

  void _handleRegister() async {
    String fullName = "${_fNameController.text} ${_lNameController.text}";
    try {
      // Pastikan fungsi register sudah kamu buat di ApiService
      await _apiService.register(fullName, _emailController.text, _passController.text);
      if (mounted) Navigator.pop(context); // Kembali ke login
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            const Text("IDENTRA\nSTUDIO.", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.2)),
            const SizedBox(height: 40),
            const Center(
              child: Text("Create new\nAccount", textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, height: 1.1)),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildLabel("NAMA DEPAN"), _buildTextField(_fNameController, "First", false)
                ])),
                const SizedBox(width: 15),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildLabel("NAMA BELAKANG"), _buildTextField(_lNameController, "Last", false)
                ])),
              ],
            ),
            const SizedBox(height: 20),
            _buildLabel("EMAIL ADDRESS"),
            _buildTextField(_emailController, "test@gmail.com", false),
            const SizedBox(height: 20),
            _buildLabel("PASSWORD"),
            _buildTextField(_passController, "password123", true),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("DAFTAR SEKARANG", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 60),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text("Sudah punya akun? MASUK DI SINI", style: TextStyle(color: Colors.white70, fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(left: 5, bottom: 8),
    child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
  );

  Widget _buildTextField(TextEditingController controller, String hint, bool isPass) => TextField(
    controller: controller,
    obscureText: isPass,
    style: const TextStyle(color: Colors.black),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black26),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    ),
  );
}