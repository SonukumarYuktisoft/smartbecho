import 'package:url_launcher/url_launcher.dart';

class LinkOpenerHelper {
  LinkOpenerHelper._(); // private constructor (no object)

  static Future<void> open(String link) async {
    final Uri url = Uri.parse(link);

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $link';
    }
  }
}
