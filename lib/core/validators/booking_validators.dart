class BookingValidators {
  static String? validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Name is required';
    }

    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (name.length > 60) {
      return 'Name must not exceed 60 characters';
    }

    return null;
  }

  static String? validatePhone(String? value) {
    final phone = value?.trim() ?? '';

    if (phone.isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(r'^\+?[0-9]{9,15}$');

    if (!phoneRegex.hasMatch(phone)) {
      return 'Enter a valid phone number';
    }

    return null;
  }

  static String? validateAddress(String? value) {
    final address = value?.trim() ?? '';

    if (address.isEmpty) {
      return 'Address is required';
    }

    if (address.length < 10) {
      return 'Address must be at least 10 characters';
    }

    if (address.length > 300) {
      return 'Address must not exceed 300 characters';
    }

    return null;
  }

  static String? validateJobDescription(String? value) {
    final description = value?.trim() ?? '';

    if (description.isEmpty) {
      return 'Job description is required';
    }

    if (description.length < 10) {
      return 'Job description must be at least 10 characters';
    }

    if (description.length > 300) {
      return 'Job description must not exceed 300 characters';
    }

    return null;
  }
}
