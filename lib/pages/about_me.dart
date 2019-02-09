import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/flutter_advanced_networkimage.dart';
import 'package:flutter_advanced_networkimage/transition_to_image.dart';
import 'package:flutter_youtube/flutter_youtube.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import 'package:pdp_vs_ts/models/youtube_channel.dart';
import 'package:pdp_vs_ts/constants/index.dart';

class AboutMePage extends StatelessWidget {
  static String route = '/about';
  AboutMePage();

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

    double pageSpacing = 10;
    
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

            Container(
              padding: EdgeInsets.only(left: pageSpacing, right: pageSpacing, bottom: pageSpacing),
              child: RaisedButton(
                onPressed: () {
                  String url = "https://paypal.me/nishant1306/1";
                  launch(url);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(vertical: pageSpacing),
                      margin: EdgeInsets.only(right: pageSpacing),
                      child: Container(
                        height: 25,
                        width: 25,
                        child: Image.asset('assets/images/coffee.png'),
                      )
                    ),
                    Text("Buy me a coffee"),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TopVideoList extends StatelessWidget {
  final YoutubeChannel youtubeChannel;

  TopVideoList(this.youtubeChannel);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return ListView(
      scrollDirection: Axis.horizontal,
      children: youtubeChannel.videos.map((video) {
        return Container(
          padding: EdgeInsets.only(right: 20),
          child: GestureDetector(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: TransitionToImage(
                AdvancedNetworkImage(video.thumbnail),
                loadingWidget: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                ),
                fit: BoxFit.cover,
                height: 25,
                width: 180,
              ),
            ),
            onTap: () {
              FlutterYoutube.playYoutubeVideoById(
                apiKey: YOUTUBE_API_KEY,
                videoId: video.id,
              );
            },
          ),
        );
      }).toList()
    );
  }
}