import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

class ApiFunctions {
  Future<List<int>> getZippedData() async {
    try {
      final response = await Dio().get(
          'https://drive.google.com/uc?id=142FpmY5XtoU7BPRiGOUDZ3StXOekskFj&export=download',
          // 'https://dashboard-xli.s3.ap-south-1.amazonaws.com/14-05-2023/Alphabet_with_picture.zip',
          options: Options(responseType: ResponseType.bytes));
      if (response.statusCode == 200) {
        List<int> list = response.data as List<int>;

        return list;
      } else {
        throw Exception();
      }
    } catch (e) {
      Get.snackbar('something went wrong', e.toString());
      log(e.toString());
      throw Exception();
    }
  }
}
