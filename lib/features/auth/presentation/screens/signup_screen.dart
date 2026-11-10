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

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    for (final controller in [
      _name,
      _email,
      _phone,
      _password,
      _confirmation,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (_form.currentState!.validate()) {
      context.read<UserCubit>().register(
        _name.text.trim(),
        _email.text.trim(),
        _phone.text.trim(),
        _password.text,
        _confirmation.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final failure = context.watch<UserCubit>().state.failure;
    return Scaffold(
      appBar: AppBar(title: Text(context.text.createAccount)),
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
                      context.text.createAccount,
                      style: context.textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.text.splashTagline,
                      style: context.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),
                    AppTextField(
                      label: context.text.name,
                      controller: _name,
                      errorText: failure?.fieldError('name'),
                      onChanged: (_) => context.read<UserCubit>().clearError(),
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? context.text.requiredField
                          : null,
                    ),
                    const SizedBox(height: 16),
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
                    AppTextField(
                      label: context.text.phone,
                      controller: _phone,
                      errorText: failure?.fieldError('phone'),
                      onChanged: (_) => context.read<UserCubit>().clearError(),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? context.text.requiredField
                          : null,
                    ),
                    const SizedBox(height: 16),
                    AppPasswordField(
                      label: context.text.password,
                      controller: _password,
                      errorText: failure?.fieldError('password'),
                      onChanged: (_) => context.read<UserCubit>().clearError(),
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      validator: (value) => value == null || value.length < 8
                          ? context.text.passwordMinLength
                          : null,
                    ),
                    const SizedBox(height: 16),
                    AppPasswordField(
                      label: context.text.confirmPassword,
                      controller: _confirmation,
                      errorText: failure?.fieldError('password_confirmation'),
                      onChanged: (_) => context.read<UserCubit>().clearError(),
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      validator: (value) => value != _password.text
                          ? context.text.passwordMismatch
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
                            label: context.text.createAccount,
                            loading: state.busy,
                            onPressed: state.busy ? null : _submit,
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.login,
                      ),
                      child: Text(context.text.alreadyHaveAccount),
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
