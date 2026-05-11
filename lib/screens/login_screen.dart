import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final googleSignIn = GoogleSignIn.instance;
      
      await googleSignIn.initialize(
        serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
      );

      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final clientAuth = await googleUser.authorizationClient.authorizeScopes(['email', 'profile']);

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: clientAuth.accessToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        debugPrint("Accesso completato con successo: ${userCredential.user!.displayName}");
      }
    } catch (e) {
      debugPrint("Errore o login annullato: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF007AFF).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(CupertinoIcons.square_stack_3d_up, color: Colors.white, size: 50),
                ),
              ),
              const SizedBox(height: 32),
              
              const Text(
                'SubWallet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34, 
                  fontWeight: FontWeight.bold, 
                  letterSpacing: -1
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tieni sotto controllo i tuoi\nabbonamenti in un unico posto.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16, 
                  color: CupertinoColors.systemGrey, 
                  height: 1.3
                ),
              ),
              
              const Spacer(),

              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _signInWithGoogle(context),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05), 
                        blurRadius: 10, 
                        offset: const Offset(0, 4)
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://cdn-icons-png.flaticon.com/512/300/300221.png', 
                        width: 23,
                        height: 23,
                        errorBuilder: (c, e, s) => const Icon(Icons.g_mobiledata, color: Colors.black, size: 28),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Continua con Google', 
                        style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.w600)
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Fluttertoast.showToast(
                    msg: "Login con Apple in arrivo!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: const Color(0xFF333333),
                    textColor: Colors.white,
                    fontSize: 15.0,
                  );
                },
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.apple, color: Colors.white, size: 30),
                      SizedBox(width: 12),
                      Text(
                        'Continua con Apple', 
                        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}