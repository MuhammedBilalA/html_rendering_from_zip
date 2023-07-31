

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_rendering_from_zip/src/presentation/view/web_page/web_page.dart';
import 'package:html_rendering_from_zip/src/presentation/widget/loading_dialog/loading_dialog.dart';


import '../../../data/datasources/local/database_functions.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('API Test'),
        ),
        body: Center(
          child: ElevatedButton(
              onPressed: () async {
                try {
                  showLoaderDialog(context);
                  await DataBaseFunctions().insertExtractedData();
                  String? path = await DataBaseFunctions().getHtmlFilePath();
                  if (path != null) {
                    Get.to(WebPage(filePath: path));
                  } else {
                    Get.snackbar('Failed', 'html not found',
                        snackPosition: SnackPosition.BOTTOM);
                  }
                } catch (e) {
                  Get.back();
                  Get.snackbar('Failed', 'Something went wrong',
                      snackPosition: SnackPosition.BOTTOM);
                }
              },
              child: const Text('Get zip file and render html')),
        ));
  }
}
