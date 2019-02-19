import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/flutter_advanced_networkimage.dart';
import 'package:flutter_advanced_networkimage/transition_to_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import 'package:pdp_vs_ts/models/youtube_channel.dart';

const PEW_DIE_PIE_DECSRIPTION = "Felix Arvid Ulf Kjellberg known online as PewDiePie, is a Swedish YouTuber, comedian and video game commentator, formerly best known for his Let's Play commentaries and now mostly known for his comedic formatted shows. \n\n On 15 August 2013, PewDiePie became the most-subscribed user on YouTube, being briefly surpassed in late 2013 by YouTube Spotlight. After regaining the top position on 23 December 2013 the channel has now amassed over 79 million subscribers as of December 2018. From 29 December 2014 to 14 February 2017, PewDiePie's channel held the distinction of being the most-viewed YouTube channel, and as of November 2018, the channel has received over 19 billion video views.";
const T_SERIES_DESCRIPTION = "T-Series is an Indian music record label and film production company founded by Gulshan Kumar in 1983. It is primarily known for Bollywood music soundtracks and Indi-pop music. As of 2017, T-Series is one of the largest Indian music record labels, along with Zee Music and Sony Music India.\n\nThe T-Series YouTube channel, run by a small team of 13 people, primarily shows music videos and occasionally film trailers. It is the most-viewed YouTube channel, with over 56 billion views as of 19 December 2018. With over 77 million subscribers as of 30 December 2018, it also ranks as the second most-subscribed channel behind PewDiePie. In addition, T-Series has a multi-channel network, with 29 channels that have more than 100 million YouTube subscribers as of November 2018 and 61.5 billion views as of August 2018.";

class YoutubeChannelDetailsPage extends StatelessWidget {
  final String description;
  final YoutubeChannel youtubeChannel;
  
  final NumberFormat nf = new NumberFormat.simpleCurrency(decimalDigits: 0, name: 'JPY', locale: 'en_US');  
  final TextStyle textStyle = TextStyle(
    fontSize: 18
  );
  final TextStyle titleTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18
  );
  final EdgeInsets basicSpacing = EdgeInsets.only(top: 10, bottom: 10);
  
  YoutubeChannelDetailsPage({this.youtubeChannel, this.description});

  @override
  Widget build(BuildContext context) {
    String formattedSubscriberCount = nf.format(youtubeChannel.subscriberCount).substring(1);
    ThemeData theme = Theme.of(context);
    double imageDimension = 400;
    double sliverExapndedHeight = 350;

    return Container(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            String url = 'https://www.youtube.com/channel/${youtubeChannel.channelId}?sub_confirmation=1';
            launch(url);
          },
          tooltip: "Open ${youtubeChannel.channelName} in Youtube",
          child: Container(
            child: Image.asset('assets/images/youtube_icon.png'),
          ),
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: sliverExapndedHeight,
              floating: false,
              pinned: true,
              brightness: theme.brightness,
              
              primary: true,

              backgroundColor: theme.primaryColor,
              textTheme: theme.textTheme,
              iconTheme: theme.iconTheme,
              
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(youtubeChannel.channelName, style: theme.textTheme.title),
              
                background: Hero(
                  tag: youtubeChannel.channelId + '_picture',
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 60, horizontal: 75),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(imageDimension/2),
                      child: TransitionToImage(
                        AdvancedNetworkImage(youtubeChannel.channelPicture),
                        loadingWidget: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        fit: BoxFit.cover,
                        placeholder: Icon(Icons.refresh),
                        width: imageDimension,
                        height: imageDimension,
                      ),
                    ),
                  ),
                ),                
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Container(
                  color: theme.backgroundColor,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: basicSpacing,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Description:', style: titleTextStyle),
                            Text(description, style: textStyle),
                          ]
                        ),
                      ),

                      Container(
                        alignment: Alignment.topLeft,
                        margin: basicSpacing,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Subscriber Count:', style: titleTextStyle),
                            Text(formattedSubscriberCount, style: textStyle),
                          ]
                        ),
                      ),

                      Container(
                        margin: basicSpacing,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Top Videos:', style: titleTextStyle),
                            Container(
                              margin: EdgeInsets.only(top: 5),
                              height: 100,
                              child: TopVideoList(youtubeChannel),
                            ),
                          ]
                        ),
                      ),
                    ],
                  ),
                );
              }, childCount: 1),
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
              String url = 'https://www.youtube.com/watch?v=${video.id}';
              launch(url);
            },
          ),
        );
      }).toList()
    );
  }
}