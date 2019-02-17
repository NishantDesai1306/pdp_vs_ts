import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdp_vs_ts/constants/square.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutMePage extends StatefulWidget {
  static String route = '/about';
  _AboutMePageState createState() => _AboutMePageState();
}
double pageSpacing = 10;

class _AboutMePageState extends State<AboutMePage> {
  _AboutMePageState();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    final TextStyle textStyle = TextStyle(
      fontSize: 18
    );
      
    final TextStyle titleTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18
    );
    
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text("About"),
          centerTitle: true,
          elevation: 0,
        ),
        body: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 350,
                    color: theme.primaryColor,
                    child: Image.asset('assets/images/logo.png'),
                  ),
                )
              ],
            ),

            Expanded(
              child: Container(
                padding: EdgeInsets.all(pageSpacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: pageSpacing),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'About app:',
                            style: titleTextStyle,
                          ),
                          Text(
                            'This app is result of a pet project that I created in order to learn basics of Flutter SDK.',
                            style: textStyle,
                          )
                        ],
                      ),
                    ),

                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Developer:',
                            style: titleTextStyle,
                          ),
                          Text(
                            'Nishant Desai',
                            style: textStyle,
                          ),
                          InkWell(
                            onTap: () {
                              String url = "mailto:nishantdesai1306@gmail.com";
                              launch(url);
                            },
                            child: Text(
                              'nishantdesai1306@gmail.com',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 18,
                                textBaseline: TextBaseline.ideographic
                              ),
                            ),
                          )
                        ],
                      ),
                    )

                    
                  ],
                ),
              ),
            ),

            DonationSection()
          ],
        ),
      ),
    );
  }
}

class DonationSection extends StatefulWidget {
  @override
  _DonationSectionState createState() => _DonationSectionState();
}

class _DonationSectionState extends State<DonationSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left:pageSpacing, right: pageSpacing),
      child: OutlineButton(
        borderSide: BorderSide(
          width: 1,
          color: Colors.grey
        ),
        onPressed: () {
          Clipboard.setData(new ClipboardData(text: 'nishantdesai1306@gmail.com'));
          
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Email address copied to your clipboard'),
            duration: Duration(seconds: 3),
          ));
        },
        child: Text(
          "If you like this app, please consider supporting me through PayPal donations on nishantdesai1306@gmail.com",
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey
          ),
        ),
      ),
    );
  }
}