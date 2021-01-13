import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show RepositoryProvider;
import 'package:flutter_icons/flutter_icons.dart';

import '../../data/models/models.dart';
import '../../services/services.dart';
import '../../utils/failure.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_form_field.dart';

/// A form allowing user to edit password.
class PasswordEditForm extends StatefulWidget {
  /// Creates the password form.
  const PasswordEditForm(
      {@required this.username, @required this.userPassword, @required this.password, @required this.callback});

  /// The username of user that is signed in.
  final String username;

  /// The password of user that is signed in.
  final String userPassword;

  /// The password that is being edited.
  final Password password;

  /// The callback to the parent widget.
  final ValueChanged<int> callback;

  @override
  _PasswordEditFormState createState() => _PasswordEditFormState();
}

class _PasswordEditFormState extends State<PasswordEditForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _loginController;
  TextEditingController _addressController;
  TextEditingController _passwordController;
  TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();

    _loginController = TextEditingController();
    _addressController = TextEditingController();
    _passwordController = TextEditingController();
    _descriptionController = TextEditingController();

    RepositoryProvider.of<PasswordService>(context)
        .getPassword(id: widget.password.id, userPassword: widget.userPassword)
        .then(
          (Either<Failure, String> result) => result.fold(
            (Failure failure) => null,
            (String decryptedPassword) => _passwordController.text = decryptedPassword,
          ),
        );

    _loginController.text = widget.password.login;
    _addressController.text = widget.password.webAddress;
    _descriptionController.text = widget.password.description;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0, left: 15.0),
              child: IconButton(
                icon: const Icon(FlutterIcons.back_ant, size: 60),
                color: const Color(0xFFE1DFF8),
                padding: const EdgeInsets.all(0),
                onPressed: () => widget.callback(-1),
              ),
            ),
            const Spacer(),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: FocusTraversalGroup(
            child: Form(
              key: _formKey,
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
                        widget.password.login = _loginController?.text;
                        widget.password.password = _passwordController?.text;
                        widget.password.webAddress = _addressController?.text;
                        widget.password.description = _descriptionController?.text;

                        RepositoryProvider.of<PasswordService>(context)
                            .updatePassword(
                              password: widget.password,
                              userPassword: widget.userPassword,
                              isRegistered: true,
                            )
                            .then((bool result) => widget.callback(result ? 1 : 0));
                      }
                    },
                    child: const Text(
                      'Edit password',
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
