import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocProvider;
import 'package:flutter_icons/flutter_icons.dart';

import '../../blocs/profile_form/profile_form.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_form_field.dart';

/// A form allowing user to change main password.
class ProfileForm extends StatefulWidget {
  /// Creates the profile form.
  const ProfileForm({@required this.username, @required this.password});

  /// The username of user that is signed in.
  final String username;

  /// The password of user that is signed in.
  final String password;

  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _passwordController;
  TextEditingController _validationPasswordController;

  @override
  void initState() {
    _passwordController = TextEditingController();
    _validationPasswordController = TextEditingController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: FocusTraversalGroup(
            child: Form(
              key: _formKey,
              onChanged: () {
                Form.of(primaryFocus.context).save();
              },
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: CustomFormField(
                      controller: _passwordController,
                      hintText: 'New profile password',
                      inputType: TextInputType.visiblePassword,
                      iconData: FlutterIcons.lock1_ant,
                      validationErrorMessage: 'Please enter password',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: TextFormField(
                      keyboardType: TextInputType.visiblePassword,
                      maxLines: null,
                      controller: _validationPasswordController,
                      cursorColor: const Color(0xFF8858E1),
                      decoration: InputDecoration(
                        helperText: ' ',
                        helperStyle: const TextStyle(height: 1),
                        errorStyle: const TextStyle(height: 1, color: Colors.white),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Old password',
                        prefixIcon: const Icon(
                          FlutterIcons.lock1_ant,
                          color: Color(0xFF8858E1),
                        ),
                        focusColor: const Color(0xFF8858E1),
                        contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.redAccent),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.redAccent),
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      validator: (String value) {
                        if (value.isEmpty || value != widget.password) {
                          return 'Please enter valid password';
                        }
                        return null;
                      },
                    ),
                  ),
                  CustomButton(
                    submitWhenPressed: () {
                      if (_formKey.currentState.validate()) {
                        BlocProvider.of<ProfileFormBloc>(context).add(
                          ProfileFormEvent(
                            username: widget.username,
                            newPassword: _passwordController?.text,
                            oldPassword: widget.password,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Change password',
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
