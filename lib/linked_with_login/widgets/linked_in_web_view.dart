///
/// Created By Guru (guru@smarttersstudio.com) on 27/06/20 3:46 PM
///
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:loginwithlinkedin/linked_with_login/data_model/auth_error_response.dart';
import 'package:loginwithlinkedin/linked_with_login/data_model/auth_success_response.dart';
import 'package:loginwithlinkedin/linked_with_login/helpers/authorization_helper.dart';

class LinkedInWebView extends StatefulWidget {
  final String clientId, clientSecret, redirectUri;

  final bool destroySession;

  final PreferredSizeWidget appBar;

  LinkedInWebView(
      {@required this.clientId,
      @required this.clientSecret,
      @required this.redirectUri,
      this.destroySession = true,
      this.appBar});

  @override
  _LinkedInWebViewState createState() => _LinkedInWebViewState();
}

class _LinkedInWebViewState extends State<LinkedInWebView> {
  final GlobalKey webViewKey = GlobalKey();
  String _oldUrl;

  InAppWebViewController webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions();

  final urlController = TextEditingController();

  void _urlChanged(String url) {
    if (this._oldUrl == url) {
      return;
    }

    if (url.startsWith(widget.redirectUri)) {
      Uri uri = Uri.parse(url);
      if (uri.queryParameters.containsKey('code')) {
        Navigator.pop(context,
            AuthorizationSuccessResponse.fromJson(uri.queryParameters));
      } else if (uri.queryParameters.containsKey('error')) {
        Navigator.pop(
            context, AuthorizationErrorResponse.fromJson(uri.queryParameters));
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      key: webViewKey,
      initialUrlRequest: URLRequest(
        url: Uri.parse(
          getAuthorizationUrl(
            clientId: widget.clientId,
            clientSecret: widget.clientSecret,
            redirectUri: widget.redirectUri,
          ),
        ),
      ),
      initialOptions: options,
      onWebViewCreated: (controller) {
        webViewController = controller;
      },
      onLoadStart: (controller, url) {
        _urlChanged(url.toString());
      },
      androidOnPermissionRequest: (controller, origin, resources) async {
        return PermissionRequestResponse(
            resources: resources,
            action: PermissionRequestResponseAction.GRANT);
      },
      onLoadStop: (controller, url) async {
        _urlChanged(url.toString());
      },
    );
  }
}
