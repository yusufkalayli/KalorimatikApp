import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FoodEntryScreen extends StatefulWidget {
  final User? user;

  FoodEntryScreen({required this.user});

  @override
  _FoodEntryScreenState createState() => _FoodEntryScreenState();
}

class _FoodEntryScreenState extends State<FoodEntryScreen> {
  String selectedFood = ''; // Seçilen yiyecek

  void _saveFoodEntry() {
    // Firebase Firestore'a yiyecek girişi kaydetme işlemi
    if (widget.user != null && selectedFood.isNotEmpty) {
      FirebaseFirestore.instance.collection('food_entries').add({
        'userId': widget.user!.uid,
        'foodName': selectedFood,
        'timestamp': DateTime.now(),
      }).then((value) {
        // Başarılı kayıt mesajı veya işlem
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Yemek girişi başarıyla kaydedildi.')));
      }).catchError((error) {
        // Hata durumunda kullanıcıya bilgi verme
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Yemek girişi kaydedilirken hata oluştu: $error')));
      });
    } else {
      // Kullanıcı seçim yapmadıysa uyarı ver
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lütfen bir yiyecek seçiniz.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yemek Girişi'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Yemek Seçimi',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedFood,
              onChanged: (String? newValue) {
                setState(() {
                  selectedFood = newValue!;
                });
              },
              items: <String>[
                'Yemek 1',
                'Yemek 2',
                'Yemek 3'
              ] // Buraya Firebase'den veya başka bir kaynaktan yiyecek listesi getirilebilir
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveFoodEntry,
              child: Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
