import 'package:flutter/material.dart';
import 'package:goodie/main.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:provider/provider.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

import '../../bloc/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _smsCodeController = TextEditingController();
  String phoneNumber = "+47";
  bool isLoadingVerify = false;
  bool isLoadingSignIn = false;
  final OtpFieldController _otpFieldController = OtpFieldController();
  final otpFieldKey = GlobalKey();

  bool otpHasGottenFocus = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authProvider.verificationId != null) {
        if (otpFieldKey.currentState != null && !otpHasGottenFocus) {
          _otpFieldController.setFocus(0);
          otpHasGottenFocus = true;
        }
      }
    });

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false, // Prevent screen from adjusting
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus(); // Dismiss keyboard
          },
          child: Center(
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 60),
                        // title with appname 'Goodie
                        const Text(
                          'Goodie',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: accent2Color,
                          ),
                        ),
                        // text saying we will send you and sms with a verification code
                        const SizedBox(height: 50),
                        if (authProvider.verificationId == null)
                          const Text(
                            'Vi sender deg en SMS med en verifiseringskode...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.black,
                            ),
                          )
                        else

                          /// use rich text and make phonenumber bold 'Vi har sendt en SMS med en verifiseringskode til $phoneNumber'
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text:
                                  'Vi har sendt en SMS med en verifiseringskode til ',
                              style: const TextStyle(
                                fontSize: 22,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: phoneNumber,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 50),
                        const Icon(
                          Icons.phone,
                          size: 80,
                          color: accent1Color,
                        ),
                        const SizedBox(height: 20),
                        if (authProvider.verificationId == null) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text("+47",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  onChanged: (value) {
                                    phoneNumber = "+47$value";
                                  },
                                  style: const TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    labelText: 'Telefonnummer',
                                    labelStyle:
                                        TextStyle(color: Colors.grey[600]),
                                    hintText: 'Skriv inn telefonnummeret ditt',
                                    hintStyle:
                                        TextStyle(color: Colors.grey[600]),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: accent1Color),
                                    ),
                                  ),
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                isLoadingVerify = true;
                              });
                              await authProvider.verifyPhoneNumber(phoneNumber);
                              setState(() {
                                isLoadingVerify = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: primaryColor,
                            ),
                            child: isLoadingVerify
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text('Verifiser telefonnummer'),
                          ),
                        ] else ...[
                          OTPTextField(
                            key: otpFieldKey,
                            otpFieldStyle: OtpFieldStyle(
                              borderColor: accent1Color,
                            ),
                            length: 6,
                            fieldWidth: 40,
                            style: const TextStyle(
                                fontSize: 17, color: Colors.black),
                            textFieldAlignment: MainAxisAlignment.spaceAround,
                            fieldStyle: FieldStyle.underline,
                            controller: _otpFieldController,
                            onChanged: (pin) {},
                            onCompleted: (pin) async {
                              setState(() {
                                isLoadingSignIn = true;
                              });
                              await authProvider
                                  .signInWithVerificationCode(pin);
                              setState(() {
                                isLoadingSignIn = false;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () async {
                              setState(() {
                                authProvider.verificationId = null;
                              });
                            },
                            child: const Text(
                              'Fikk du ingen SMS? Trykk her',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (isLoadingSignIn)
                      const Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          color: primaryColor,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
