// // ignore: file_names
// import 'package:url_launcher/url_launcher.dart';

// /// Opens WhatsApp chat / phone dialer directly — this is the app's whole
// /// "contact" mechanism (per the design: Call / WhatsApp buttons), so there
// /// is no in-app chat or image upload to build or maintain.
// class WhatsAppService {
//   /// [phone] should include country code, digits only, e.g. "923001234567".
//   static Future<void> openChat(String phone, {String message = ''}) async {
//     final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
//     final uri = Uri.parse(
//       'https://wa.me/$cleanPhone${message.isNotEmpty ? '?text=${Uri.encodeComponent(message)}' : ''}',
//     );
//     await launchUrl(uri, mode: LaunchMode.externalApplication);
//   }

//   static Future<void> call(String phone) async {
//     final uri = Uri(scheme: 'tel', path: phone);
//     await launchUrl(uri);
//   }
// }
