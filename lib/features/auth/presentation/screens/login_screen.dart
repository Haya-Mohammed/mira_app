import 'package:booking_app/core/config/extensions/localization_extension.dart';
import 'package:booking_app/core/config/extensions/theme_extension.dart';
import 'package:booking_app/core/config/routes/routes.dart';
import 'package:booking_app/core/widgets/app_button.dart';
import 'package:booking_app/core/widgets/app_logo.dart';
import 'package:booking_app/core/widgets/app_password_field.dart';
import 'package:booking_app/core/widgets/app_text_field.dart';
import 'package:booking_app/features/auth/presentation/cubits/user_cubit.dart';
import 'package:booking_app/features/auth/presentation/cubits/user_state.dart';
import 'package:booking_app/features/auth/presentation/screens/auth_failure_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_form.currentState!.validate()) {
      context.read<UserCubit>().login(_email.text.trim(), _password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final failure = context.watch<UserCubit>().state.failure;
    return Scaffold(
      appBar: AppBar(title: Text(context.text.login)),
      body: BlocListener<UserCubit, UserState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == AuthStatus.authenticated,
        listener: (context, state) =>
            Navigator.of(context).popUntil((route) => route.isFirst),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _form,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const Center(child: AppLogo(size: 104)),
                    const SizedBox(height: 24),
                    Text(
                      context.text.login,
                      style: context.textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.text.splashTagline,
                      style: context.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),
                    AppTextField(
                      label: context.text.email,
                      controller: _email,
                      errorText: failure?.fieldError('email'),
                      onChanged: (_) => context.read<UserCubit>().clearError(),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: (value) =>
                          value == null ||
                              !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                  .hasMatch(value.trim())
                          ? context.text.invalidEmail
                          : null,
                    ),
                    const SizedBox(height: 16),
                    AppPasswordField(
                      label: context.text.password,
                      controller: _password,
                      errorText: failure?.fieldError('password'),
                      onChanged: (_) => context.read<UserCubit>().clearError(),
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      validator: (value) => value == null || value.isEmpty
                          ? context.text.requiredField
                          : null,
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<UserCubit, UserState>(
                      builder: (context, state) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (state.failure != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                state.failure!.authMessage(context),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          AppButton(
                            label: context.text.login,
                            loading: state.busy,
                            onPressed: state.busy ? null : _submit,
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.signup,
                      ),
                      child: Text(context.text.createAccount),
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
