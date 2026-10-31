import 'dart:io';

void main() {
  final pdfFile = File(r'C:\Users\hamme\Downloads\Aae Study notes .pdf');
  print('PDF File Exists: ${pdfFile.existsSync()}');
  if (pdfFile.existsSync()) {
    print('PDF File Size: ${pdfFile.lengthSync()} bytes');
  }
}
