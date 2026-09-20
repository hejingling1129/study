import 'package:url_launcher/url_launcher.dart';

Future<bool> openDownloadUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    return launchUrl(uri, webOnlyWindowName: '_blank');
  }
  return false;
}
