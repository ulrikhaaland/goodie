import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goodie/bloc/auth_provider.dart';
import 'package:goodie/main.dart';
import 'package:provider/provider.dart';

import '../../model/user.dart';

class IntroPage extends StatefulWidget {
  final VoidCallback onDone;
  const IntroPage({super.key, required this.onDone});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final PageController _pageController = PageController(initialPage: 0);

  String? fullName;
  String? userName;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: _IntroPageWidget(
                          key: const Key('intro_page_1'),
                          title: 'Hva heter du?',
                          description:
                              'Legg til navnet ditt, slik at venner kan finne deg.',
                          buttonText: 'Neste',
                          label: 'Fullt navn',
                          errorText: 'Vennligst skriv inn navnet ditt',
                          onTextFieldChange: (value) {
                            fullName = value;
                          },
                          shouldCheckFirestore: false,
                          onButtonPressed: () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          ),
                          value: fullName,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              height: 40,
                              child:
                                  // back button
                                  InkWell(
                                onTap: () {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: const Icon(Icons.arrow_back_ios),
                              )),
                          _IntroPageWidget(
                            key: const Key('intro_page_2'),
                            title: 'Velg et brukernavn',
                            description:
                                'Legg til et brukernavn. Du kan når som helst endre det.',
                            buttonText: 'Ferdig',
                            label: 'Brukernavn',
                            onTextFieldChange: (name) {
                              userName = name;
                            },
                            errorText: "Vennligst velg et brukernavn",
                            shouldCheckFirestore: true,
                            onButtonPressed: () {
                              final AuthProvider authProvider =
                                  Provider.of<AuthProvider>(context,
                                      listen: false);

                              final User user = authProvider.user.value!;

                              user.username = userName;
                              user.fullName = fullName;
                              user.isNewUser = false;
                              widget.onDone();
                              authProvider.updateUserData();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )),
      ),
    ));
  }
}

class _IntroPageWidget extends StatefulWidget {
  final String title;
  final String description;
  final String buttonText;
  final String label;
  final String errorText;
  final String? value;
  final Function(String name) onTextFieldChange;
  final bool shouldCheckFirestore;
  final VoidCallback onButtonPressed;

  const _IntroPageWidget(
      {Key? key,
      required this.title,
      required this.description,
      required this.buttonText,
      required this.label,
      required this.onTextFieldChange,
      required this.errorText,
      required this.shouldCheckFirestore,
      required this.onButtonPressed,
      this.value})
      : super(key: key);

  @override
  _IntroPageWidgetState createState() => _IntroPageWidgetState();
}

class _IntroPageWidgetState extends State<_IntroPageWidget> {
  final TextEditingController _textController = TextEditingController();
  String? _errorMessage;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool hasSubmitted = false;

  // Add a focus node
  final FocusNode _focusNode = FocusNode();

  // Add a variable to hold the stream
  Stream<QuerySnapshot>? usernameStream;

  // Update this function to set the stream based on the text entered
  void updateStream(String text) {
    setState(() {
      usernameStream = _firestore
          .collection('users')
          .where('username', isEqualTo: text)
          .snapshots();
    });
  }

  @override
  void initState() {
    _textController.text = widget.value ?? "";
    _focusNode.requestFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget textFieldWidget = widget.shouldCheckFirestore
        ? StreamBuilder<QuerySnapshot>(
            stream: usernameStream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData &&
                  snapshot.data!.docs.isNotEmpty &&
                  !hasSubmitted) {
                _errorMessage =
                    "Brukernavnet er allerede i bruk, velg et annet";
              } else if (_textController.text.isNotEmpty) {
                _errorMessage = null;
              }

              return buildTextField();
            },
          )
        : buildTextField();

    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        Text(
          widget.description,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        textFieldWidget,
        const SizedBox(
          height: 16,
        ),
        ElevatedButton(
          onPressed: () {
            if (_textController.text.isEmpty) {
              setState(() {
                _errorMessage = widget.errorText;
              });
            } else {
              // unfocus the text field
              if (widget.shouldCheckFirestore) FocusScope.of(context).unfocus();
              hasSubmitted = true;
              widget.onButtonPressed();
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            minimumSize: const Size(double.infinity, 48),
          ),
          child: Text(widget.buttonText),
        ),
      ],
    );
  }

  TextField buildTextField() {
    return TextField(
      focusNode: _focusNode,
      controller: _textController,
      textCapitalization: widget.shouldCheckFirestore
          ? TextCapitalization.none
          : TextCapitalization.words,
      onChanged: (text) {
        widget.onTextFieldChange(text);
        if (widget.shouldCheckFirestore) {
          updateStream(text); // Update the stream when text changes
        } else {
          setState(() {
            _errorMessage = text.isEmpty ? widget.errorText : null;
          });
        }
      },
      decoration: InputDecoration(
        filled: true,
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(),
        ),
        labelText: widget.label,
        hintText: widget.shouldCheckFirestore ? null : "Ola Nordmann",
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 16,
        ),
        errorText: _errorMessage,
      ),
      cursorColor: primaryColor,
    );
  }
}
