class Validators {
  Validators._();

  //
  // static String? requiredField(String value, {required String requiredMsg, int minLength = 1}) {
  //   final trimmed = value.trim();
  //
  //   if (trimmed.isEmpty) {
  //     return requiredMsg;
  //   }
  //
  //   if (trimmed.length < minLength) {
  //     return S.current.min_length(minLength);
  //   }
  //
  //   return null;
  // }
  //
  // static String? email(String value) {
  //   final trimmed = value.trim();
  //   if (trimmed.isEmpty) return S.current.required_email;
  //   if (!_emailRegex.hasMatch(trimmed)) return S.current.invalid_email;
  //
  //   return null;
  // }
  //
  // static String? password(String value) {
  //   if (value.isEmpty) return S.current.required_password;
  //   if (value.length < 8) return S.current.password_min_length;
  //   if (!value.contains(RegExp(r'[a-zA-Z]'))) return S.current.password_char_required;
  //   if (!value.contains(RegExp(r'[0-9]'))) return S.current.password_num_required;
  //   if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')))
  //     return S.current.password_special_char_required;
  //
  //   return null;
  // }
  //
  // static String? firstName(String value) {
  //   final trimmed = value.trim();
  //
  //   if (trimmed.isEmpty) {
  //     return S.current.required_first_name;
  //   }
  //
  //   if (trimmed.length < 2) {
  //     return S.current.first_name_min_length;
  //   }
  //
  //   return null;
  // }
  //
  // static String? lastName(String value) {
  //   final trimmed = value.trim();
  //
  //   if (trimmed.isEmpty) {
  //     return S.current.required_last_name;
  //   }
  //
  //   if (trimmed.length < 2) {
  //     return S.current.last_name_min_length;
  //   }
  //
  //   return null;
  // }
  //
  // static String? username(String value) {
  //   final trimmed = value.trim();
  //
  //   if (trimmed.isEmpty) {
  //     return S.current.required_username;
  //   }
  //
  //   if (trimmed.length < 3) {
  //     return S.current.username_min_length;
  //   }
  //
  //   if (!_usernameRegex.hasMatch(trimmed)) {
  //     return S.current.username_invalid;
  //   }
  //
  //   return null;
  // }
  //
  // static String? phone(String value) {
  //   final trimmed = value.trim();
  //
  //   if (trimmed.isEmpty) {
  //     return S.current.phone_number_required;
  //   }
  //
  //   if (!_phoneRegex.hasMatch(trimmed)) {
  //     return S.current.invalid_phone_number;
  //   }
  //
  //   return null;
  // }
}
