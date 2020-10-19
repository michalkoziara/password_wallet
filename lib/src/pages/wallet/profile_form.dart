import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  void initState() {
    _passwordController = TextEditingController();

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
