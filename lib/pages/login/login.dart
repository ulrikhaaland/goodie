import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../bloc/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _smsCodeController = TextEditingController();
  String phoneNumber = "+47";

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.pink[300]!, Colors.pink[100]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.phone,
                size: 80,
                color: Colors.white70,
              ),
              const SizedBox(height: 20),
              if (authProvider.verificationId == null) ...[
                Row(
                  children: [
                    const Text("+47",
                        style: TextStyle(fontSize: 16, color: Colors.white70)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          phoneNumber = "+47$value";
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Phone number',
                          labelStyle: TextStyle(color: Colors.white70),
                          hintText: 'Enter your phone number',
                          hintStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    authProvider.verifyPhoneNumber(phoneNumber);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                  ),
                  child: const Text('Verify Phone Number'),
                ),
              ] else ...[
                TextField(
                  controller: _smsCodeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Verification code',
                    labelStyle: TextStyle(color: Colors.white70),
                    hintText: 'Enter the verification code',
                    hintStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                ElevatedButton(
                  onPressed: () {
                    authProvider
                        .signInWithVerificationCode(_smsCodeController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                  ),
                  child: const Text('Login'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
