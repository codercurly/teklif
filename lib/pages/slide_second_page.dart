import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:teklif/base/dimension.dart';
import 'package:teklif/pages/auth/register_page.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
String? selectedvalue;
  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: Dimension.getHeight100(context) * 3),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.scale(
                scale: _animation.value,
                child: child,
              );
            },
            child: const Text(
              'Kayıt olmak için rolünüzü seçerek başlayın...🚀',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: Dimension.getHeight30(context)),
          Padding(
            padding: EdgeInsets.all(Dimension.getFont20(context)),
            child: DropdownSearch<String>(
              dropdownButtonProps: DropdownButtonProps(
                isVisible: true,
                icon: Icon(Icons.search, size: 16),
              ),
              popupProps: PopupProps.dialog(
                interceptCallBacks: true,
                title: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "Rolünüzü giriniz",
                    style: TextStyle(fontFamily: "Kreon Light", fontSize: 18),
                  ),
                ),
                dialogProps: DialogProps(
                  backgroundColor: Colors.white,

                  contentPadding: EdgeInsets.all(10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                loadingBuilder: (context, item) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.pink,
                      backgroundColor: Colors.greenAccent,
                    ),
                  );
                },
                searchFieldProps: TextFieldProps(
                  cursorColor: Colors.blue,
                ),
                emptyBuilder: (context, searchEntry) => Center(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text(
                          'Rol bulunamadı',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                showSelectedItems: true,
                showSearchBox: true,
              ),
              items: ["İşletme Sahibi", "Yönetici", "Pazarlamacı-Satıcı"],
              dropdownDecoratorProps: DropDownDecoratorProps(
                baseStyle: TextStyle(fontSize: 18),
                dropdownSearchDecoration: InputDecoration(
                  contentPadding: EdgeInsets.all(15.0),
                  suffix: Text(""),
                  hintText: "Sektör seçin",
                  hintStyle: TextStyle(fontSize: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              onChanged: (selected) {

                selectedvalue= selected;
              },
              clearButtonProps: ClearButtonProps(
                iconSize: 16,
                icon: Icon(Icons.clear),
                isVisible: true,
                onPressed: () {
                  print('Clear button pressed');
                },
              ),
            ),
          ),
          SizedBox(height: Dimension.getHeight30(context)),
          GestureDetector(
            child: Container(
              width: Dimension.getHeight100(context) * 2,
              height: Dimension.getHeight45(context) * 1.3,
              decoration: BoxDecoration(
                color: Colors.orange.shade500,
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Devam',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Dimension.getFont20(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 10), // Metin ile ok ikonu arasına boşluk ekleyin
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  RegisterPage(role: selectedvalue!,)));

            },
          )


        ],
      ),
    );
  }
}
