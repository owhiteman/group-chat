import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:group_chat/firebase/auth_service.dart';
import 'package:group_chat/widgets/button.dart';
import 'package:group_chat/widgets/error_message.dart';
import 'package:group_chat/widgets/text_field_styling.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _confirmPassword;
  Uint8List? _image;
  bool isLoading = false;

  @override
  void initState() {
    _name = TextEditingController();
    _email = TextEditingController();
    _password = TextEditingController();
    _confirmPassword = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  pickImage(ImageSource source) async {
    final ImagePicker imagePicker = ImagePicker();

    XFile? file = await imagePicker.pickImage(source: source);

    if (file != null) {
      return await file.readAsBytes();
    } else {
      if (!mounted) return;
      return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: ErrorMessage(errorText: 'No image selected'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ));
    }
  }

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  //backgroundColor: Colors.white,
                  ),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(children: [
                const SizedBox(height: 10),
                TextField(
                  controller: _name,
                  enableSuggestions: false,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.words,
                  decoration: LoginTextFieldDecoration().decoration("Name"),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _email,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: LoginTextFieldDecoration().decoration("Email"),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _password,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: LoginTextFieldDecoration().decoration("Password"),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _confirmPassword,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration:
                      LoginTextFieldDecoration().decoration("Confirm password"),
                ),
                const SizedBox(height: 20),
                //circular widget to show accepted file
                Stack(
                  children: [
                    _image != null
                        ? CircleAvatar(
                            radius: 64,
                            backgroundImage: MemoryImage(_image!),
                          )
                        : const CircleAvatar(
                            radius: 64,
                            backgroundImage: NetworkImage(
                              "https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg",
                            ),
                          ),
                    Positioned(
                        bottom: -10,
                        left: 80,
                        child: IconButton(
                          onPressed: () {
                            selectImage();
                          },
                          icon: const Icon(Icons.add_a_photo),
                        ))
                  ],
                ),
                const Padding(padding: EdgeInsets.all(10)),
                CustomButton(
                  onPressed: () async {
                    if (_name.text.isNotEmpty &&
                        _email.text.isNotEmpty &&
                        (_password.text.isNotEmpty &&
                            _password.text == _confirmPassword.text)) {
                      setState(() {
                        isLoading = true;
                      });
                      var res = await context.read<AuthService>().signUp(
                            email: _email.text.trim(),
                            password: _password.text.trim(),
                            name: _name.text,
                            file: _image,
                          );
                      setState(() {
                        isLoading = false;
                      });
                      if (mounted) {
                        if (res != 'Success') {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: ErrorMessage(
                                errorText: res ??
                                    'There was a problem with registration, please try again'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                          ));
                        } else {
                          Navigator.of(context)
                              .pushNamedAndRemoveUntil('/', (route) => false);
                        }
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: ErrorMessage(
                            errorText:
                                'Password does not match password confirmation'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                      ));
                    }
                  },
                  inputText: 'Register',
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('If you are already registered, click'),
                    TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: const Text(' here to log in'),
                    ),
                  ],
                )
              ]),
            ),
    );
  }
}
