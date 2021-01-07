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
      home: ArticleList(),
    );
  }
}

class ArticleList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future articles = QiitaClient.fetchArticle();
    return Scaffold(
      appBar: AppBar(
        title: Text('FutureBuilder Test'),
      ),
      body: FutureBuilder(
        future: articles,
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (ctx, i) {
                return ListTile(
                  // leading: CircleAvatar(
                  //   child: Image.network(
                  //     snapshot.data[i].user.iconUrl,
                  //   ),
                  // ),
                  leading: CircleAvatar(
                    backgroundImage:
                        NetworkImage(snapshot.data[i].user.iconUrl),
                  ),
                  title: Text(snapshot.data[i].title),
                  subtitle: Text(snapshot.data[i].user.id),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DetailPage(
                          id: snapshot.data[i].id,
                          title: snapshot.data[i].title,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String id;
  final String title;
  DetailPage({this.id, this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(child: Text('Detail Page Contents')),
    );
  }
}
