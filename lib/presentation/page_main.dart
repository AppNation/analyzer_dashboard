import 'dart:async';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PageMain extends StatefulWidget {
  const PageMain({Key? key}) : super(key: key);

  @override
  _PageMainState createState() => _PageMainState();
}

class _PageMainState extends State<PageMain> {
  //Map<String, int> referrerCount = <String, int>{};
  List<dynamic> referrerCount = <dynamic>[];
  PlatformFile? file;
  var totalCount = 0;
  double heightSizer = 1;
  double widthSizer = 1;
  double pixelRatio = 1;
  double sp = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      setState(() {
        heightSizer = MediaQuery.of(context).size.height / 100;
        widthSizer = MediaQuery.of(context).size.width / 100;
        pixelRatio = MediaQuery.of(context).devicePixelRatio;
        sp = (MediaQuery.of(context).size.width / 3.4) * 100;
      });
    });
  }

  void analyze(List<dynamic> data) {
    setState(() {
      totalCount = data.length;
      var referrerValues = data.toSet();
      for (var element in referrerValues) {
        var count = data.where((e) => e == element).toList().length;
        referrerCount.add([element, count]);
        //referrerCount[element] = count;
      }
    });
  }

  Future<void> readFile(String fileContent) async {
    List<List<dynamic>> rowsAsListOfValues =
        const CsvToListConverter(fieldDelimiter: ";", eol: '\n')
            .convert(fileContent);
    int index = rowsAsListOfValues[0]
        .indexWhere((element) => element == "custom_attributes");
    var data = rowsAsListOfValues
        .map((e) => e[index])
        .toList()
        .where((element) => element.contains("{"))
        .toList()
        .map((e) => e.split("{value: ")[1])
        .map((e) => e.split(",")[0])
        .toList();
    analyze(data);
  }

  Future<void> onUploadTapped() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      setState(() {
        file = result.files.first;
        var fileContent = String.fromCharCodes(file!.bytes!.toList());
        readFile(fileContent);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Padding(
          padding:
              EdgeInsets.only(left: 0.12 * w, right: 0.12 * w, top: 0.13 * h),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: onUploadTapped,
                    child: Container(
                      height: 29,
                      width: 0.35 * w,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xFFBAABAB), width: 2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        file?.name ?? "",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 0.018 * w),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xFF0075FF),
                      ),
                      onPressed: onUploadTapped,
                      child: const Text("Upload"),
                    ),
                  ),
                ],
              ),
              referrerCount.isEmpty
                  ? const SizedBox.shrink()
                  : Flexible(child: listReferrer(w, h)),
              file == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: EdgeInsets.only(top: 0.06 * h, bottom: 0.19 * h),
                      child: Text(
                        "$totalCount Total",
                        style: TextStyle(
                            fontSize: 0.04 * h,
                            fontWeight: FontWeight.w300,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget listReferrer(double w, double h) {
    return Padding(
      padding: EdgeInsets.only(top: 0.1 * h),
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: referrerCount.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 0.04 * w,
          mainAxisSpacing: 0.04 * w,
        ),
        itemBuilder: (context, index) {
          double percent = referrerCount[index][1] * 100 / totalCount;
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: const Color(0xFFEAEAEA),
            ),
            child: Center(
                child: Column(
              children: [
                const Spacer(
                  flex: 3,
                ),
                Text(
                  "%${percent.toStringAsFixed(1)}",
                  style: TextStyle(
                      fontSize: 0.08 * h,
                      fontWeight: FontWeight.w700,
                      overflow: TextOverflow.ellipsis),
                ),
                const Spacer(
                  flex: 1,
                ),
                Text(
                  "${referrerCount[index][1]} units",
                  style: TextStyle(
                      fontSize: 0.026 * h,
                      fontWeight: FontWeight.w300,
                      overflow: TextOverflow.ellipsis),
                ),
                const Spacer(
                  flex: 1,
                ),
                Text(
                  referrerCount[index][0],
                  style: TextStyle(
                      fontSize: 0.04 * h,
                      fontWeight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis),
                ),
                const Spacer(
                  flex: 2,
                ),
              ],
            )),
          );
        },
      ),
    );
  }
}
