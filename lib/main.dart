import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class User {
  final String id;
  final String iconUrl;
  User({this.id, this.iconUrl});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      iconUrl: json['profile_image_url'],
    );
  }
}

class Article {
  final String id;
  final String title;
  final User user;
  Article({this.id, this.title, this.user});

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'],
      user: User.fromJson(json['user']),
    );
  }
}

class QiitaClient {
  static Future<List<Article>> fetchArticle() async {
    final String url = 'https://qiita.com/api/v2/items';
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List jsonArray = jsonDecode(response.body);
      List<Article> newArray = [];
      jsonArray.forEach((data) {
        newArray.add(Article.fromJson(data));
      });
      return newArray;
      // return jsonArray.map((json) {
      //   return Article.fromJson(json);
      // }).toList();
    } else {
      throw Exception('Faied to load article');
    }
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Test002 Demo'),
        ),
        body: ArticleList(),
      ),
    );
  }
}

class ArticleList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future articles = QiitaClient.fetchArticle();
    return FutureBuilder(
      future: articles,
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (ctx, i) {
              return Card(
                child: Text(snapshot.data[i].title),
              );
            },
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
