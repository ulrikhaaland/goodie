import 'package:flutter/material.dart';
import 'package:goodie/main.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:phone_text_field/phone_text_field.dart';
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
  String phoneNumber = "+47";
  bool isLoadingVerify = false;
  bool isLoadingSignIn = false;
  final OtpFieldController _otpFieldController = OtpFieldController();
  final otpFieldKey = GlobalKey();

  bool otpHasGottenFocus = false;

  String? errorMessage;

  late final AuthProvider authProvider;

  @override
  void initState() {
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.verificationId.addListener(_rebuild);
    super.initState();
  }

  @override
  void dispose() {
    authProvider.verificationId.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authProvider.verificationId.value != null) {
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
                        if (authProvider.verificationId.value == null)
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
                        if (authProvider.verificationId.value == null) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // const Text("+47",
                              //     style: TextStyle(
                              //         fontSize: 16, color: Colors.black)),
                              // const SizedBox(width: 8),
                              Expanded(
                                child: PhoneTextField(
                                  disableLengthCheck: true,
                                  dialogTitle: "Velg land",
                                  invalidNumberMessage: "Ugyldig telefonnummer",
                                  locale: const Locale('no'),
                                  decoration: InputDecoration(
                                    filled: true,
                                    // contentPadding: const EdgeInsets.all(12),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide:
                                          BorderSide(color: Colors.grey[600]!),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide: BorderSide(),
                                    ),
                                    labelText: "Telefonnummer",
                                    labelStyle: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                  searchFieldInputDecoration:
                                      const InputDecoration(
                                    filled: true,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide: BorderSide(),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide: BorderSide(),
                                    ),
                                    suffixIcon: Icon(Icons.search),
                                    hintText: "Søk etter land",
                                  ),
                                  initialCountryCode: "NO",
                                  onChanged: (value) {
                                    if (!isLoadingSignIn) {
                                      phoneNumber = value.completeNumber;
                                    }
                                  },
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: isLoadingSignIn
                                ? null
                                : () async {
                                    // remove focus
                                    FocusScope.of(context).unfocus();
                                    setState(() {
                                      isLoadingSignIn = true;
                                    });
                                    try {
                                      await authProvider
                                          .verifyPhoneNumber(phoneNumber);
                                    } catch (e) {
                                      errorMessage =
                                          "Verification failed. Please try again.";
                                    }
                                    setState(() {
                                      isLoadingSignIn = false;
                                    });
                                  },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: isLoadingSignIn
                                  ? Colors
                                      .grey // Change the background color to grey when disabled
                                  : primaryColor,
                            ),
                            child: const Text('Verifiser telefonnummer'),
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
                              try {
                                await authProvider
                                    .signInWithVerificationCode(pin);
                              } catch (e) {
                                errorMessage =
                                    "Sign in failed. Please try again.";
                              }
                              if (mounted) {
                                setState(() {
                                  isLoadingSignIn = false;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () async {
                              setState(() {
                                authProvider.verificationId.value = null;
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
                        if (errorMessage != null)
                          Text(
                            errorMessage!,
                            style: TextStyle(color: Colors.red),
                          ),
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

  void _rebuild() {
    isLoadingSignIn = false;
    setState(() {});
  }
}
