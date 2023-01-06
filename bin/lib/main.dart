import 'dart:async';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

Future<void> main() async {
  int sayi = 1;
  var excel = Excel.createExcel();
  var sheet = excel['veriler'];
  Stopwatch stopwatch = Stopwatch()..start();
  print('${stopwatch.elapsed} Oluşturuldu');
  stopwatch.reset();
  sheet.appendRow([
    "firma Adı",
  ]);
  bool isSet = excel.setDefaultSheet(sheet.sheetName);
  if (isSet) {
    print("${sheet.sheetName} varsayılan sayfaya ayarlandı.");
  } else {
    print("${sheet.sheetName} varsayılan olarak ayarlanamıyor.");
  }
  int page1 = 1;
  int page2 = 4;

  // site Linki
  String url = "";

  for (var i = page1; i <= page2; i++) {
    RegExp regex = new RegExp(r'"@id":"(.*?)"');
    var response = await http.get(Uri.parse(url + i.toString()));
    var urller = regex.allMatches(response.body);
    for (var url in urller) {
      var response2 = await http.get(Uri.parse(url.group(1)));
      RegExpMatch firmaAdi;
      RegExp firmaAdiBul = new RegExp(
          r'<h1 data-test="salon-name" class="mb-0"><em>(.*?)</em></h1>');

      if (firmaAdiBul.hasMatch(response2.body)) {
        firmaAdi = firmaAdiBul.firstMatch(response2.body);
      } else {
        firmaAdi = firmaAdiBul.firstMatch(
            r'<h1 data-test="salon-name" class="mb-0"><em> </em></h1>');
      }

      sheet.appendRow([
        firmaAdi.group(1),
      ]);

      print("$sayi Firma Eklendi");
      sayi++;
    }
  }
  String outputFile = await Directory.current.path + "/veri.xlsx";
  List<int> fileBytes = await excel.save();
  if (fileBytes != null) {
    File(join(outputFile))
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes);
    print("Dosya Oluşturuldu");
  }
}
