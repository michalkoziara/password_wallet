import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocProvider;
import 'package:flutter_icons/flutter_icons.dart';

import '../../blocs/password_form/password_form.dart';
import '../../blocs/password_list/password_list.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_form_field.dart';

/// A form allowing user to add new password to the wallet.
class PasswordForm extends StatefulWidget {
  /// Creates the password form.
  const PasswordForm({@required this.username, @required this.password});

  /// The username of user that is signed in.
  final String username;

  /// The password of user that is signed in.
  final String password;

  @override
  _PasswordFormState createState() => _PasswordFormState();
}

class _PasswordFormState extends State<PasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _loginController;
  TextEditingController _addressController;
  TextEditingController _passwordController;
  TextEditingController _descriptionController;

  @override
  void initState() {
    _loginController = TextEditingController();
    _addressController = TextEditingController();
    _passwordController = TextEditingController();
    _descriptionController = TextEditingController();

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
                      controller: _loginController,
                      hintText: 'Login',
                      inputType: TextInputType.text,
                      iconData: FlutterIcons.user_ant,
                      validationErrorMessage: 'Please enter login',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: CustomFormField(
                      controller: _addressController,
                      hintText: 'Website address',
                      inputType: TextInputType.url,
                      iconData: FlutterIcons.web_mco,
                      validationErrorMessage: 'Please enter website address',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: CustomFormField(
                      controller: _passwordController,
                      hintText: 'Password',
                      inputType: TextInputType.visiblePassword,
                      iconData: FlutterIcons.lock1_ant,
                      validationErrorMessage: 'Please enter password',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: CustomFormField(
                      controller: _descriptionController,
                      hintText: 'Description',
                      inputType: TextInputType.multiline,
                      iconData: FlutterIcons.text_ent,
                      validationErrorMessage: 'Please enter description',
                    ),
                  ),
                  CustomButton(
                    submitWhenPressed: () {
                      if (_formKey.currentState.validate()) {
                        BlocProvider.of<PasswordFormBloc>(context).add(
                          PasswordFormEvent(
                            username: widget.username,
                            userPassword: widget.password,
                            login: _loginController?.text,
                            password: _passwordController?.text,
                            webAddress: _addressController?.text,
                            description: _descriptionController?.text,
                          ),
                        );

                        BlocProvider.of<PasswordListBloc>(context).add(
                          PasswordListOpenEvent(
                            username: widget.username,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Add password',
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
