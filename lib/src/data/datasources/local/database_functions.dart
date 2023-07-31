import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../../domain/models/local_model_class/local_model_class.dart';
import '../../repositories/repositories.dart';

class DataBaseFunctions {
  Database? _db;

  Future<void> initDataBase() async {
    try {
      _db = await openDatabase(
        'zipped_data.db',
        version: 1,
        onCreate: (db, version) async {
          db.execute('CREATE TABLE extracteddata (id INTEGER PRIMARY KEY, path TEXT)');
        },
      );
    } catch (e) {
      Get.snackbar('something went wrong', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<List<int>?> getCompressedData(List<File> fileList) async {
    final archive = Archive();

    for (var element in fileList) {
      final fileBytes = await element.readAsBytes();

      archive.addFile(ArchiveFile(element.path, fileBytes.length, fileBytes));
    }
    final zipEncoder = ZipEncoder();
    List<int>? compressedData = zipEncoder.encode(archive);
    return compressedData;
  }

  Future<Directory> getExtractedData() async {
    try {
      if (_db == null) {
        await initDataBase();
      }

      List<int> compressedData = await ApiFunctions().getZippedData();

      final zipDecoder = ZipDecoder();
      // try {
      Archive archive = zipDecoder.decodeBytes(compressedData,
          verify: true,
          password: 'PAS454454488SWORD'); // Replace 'PASSWORD' with your known password
      // If the decoding succeeds without an exception, the zip file is not password-protected
      //   log('pass');
      // // } catch (e) {
      //   log(e.toString());

      //   log('fail');

      // throw Exception();
      // If an exception occurs during decoding, the zip file is password-protected
      // }
      // Archive archive = zipDecoder.decodeBytes(compressedData);

      Directory cacheDir = await getTemporaryDirectory();

      for (final file in archive) {
        final filename = file.name;

        if (file.isFile) {
          List<int> data = file.content as List<int>;
          File newFile = File('${cacheDir.path}/$filename');


          await newFile.create(recursive: true);
          await newFile.writeAsBytes(data);
        } else {
          Directory('${cacheDir.path}/$filename').create(recursive: true);
        }
      }

      return cacheDir;
    } on ArchiveException catch (e) {
      log(e.message);
      log(e.toString());
      throw Exception();
    }
  }

  Future<void> insertExtractedData() async {
    if (_db == null) {
      await initDataBase();
    }
    final int count = await _db!.query('extracteddata').then((results) => results.length);

    if (count == 0) {
      Directory dir = await getExtractedData();
      DirectoryModel directoryModel = DirectoryModel(
        path: dir.path,
      );
      await _db!.insert('extracteddata', directoryModel.toMap());

      Get.snackbar('Success', 'Zip file extracted and stored in local successfully',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<String?> getHtmlFilePath() async {
    if (_db == null) {
      await initDataBase();
    }
    List<Map<String, Object?>> list = await _db!.rawQuery('SELECT * FROM extracteddata');
    Directory directory = Directory(list.first["path"].toString());
    bool dirExists = await directory.exists();
    if (dirExists) {
      return await findHtmlFiles(directory);
    }
    return null;
  }

  Future<String?> findHtmlFiles(Directory directory) async {
    String? htmlFilePath;
    for (FileSystemEntity entity in directory.listSync()) {
      if (entity is File && entity.path.toLowerCase().endsWith('.html')) {
        htmlFilePath = entity.path;
        break;
      } else if (entity is Directory) {
        String? filePath = await findHtmlFiles(entity);
        if (filePath != null) {
          htmlFilePath = filePath;
          break;
        }
      }
    }
    return htmlFilePath;
  }
}
