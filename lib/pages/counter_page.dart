import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/flutter_advanced_networkimage.dart';
import 'package:flutter_advanced_networkimage/transition_to_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdp_vs_ts/blocs/internet_connectivity/bloc.dart';
import 'package:pdp_vs_ts/blocs/internet_connectivity/state.dart';

import 'package:pdp_vs_ts/models/youtube_channel.dart';
import 'package:pdp_vs_ts/widgets/counter.dart';
import 'package:pdp_vs_ts/constants/index.dart';
import 'package:pdp_vs_ts/pages/youtube_channel_details_page.dart';
import 'package:pdp_vs_ts/blocs/counter_page/bloc.dart';
import 'package:pdp_vs_ts/blocs/counter_page/state.dart';

class CounterPage extends StatefulWidget {
  _CounterPageState createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  final CounterPageBloc counterPageBloc = CounterPageBloc();
  final InternetChangeListener internetChangeListener = InternetChangeListener();
  InternetState internetState = InternetState();

  bool isConnectedToInternet = false;
  bool shouldRenderNotifier = false;
  bool isSettingsOpen = false;
  
  final textStyle = TextStyle(
    fontSize: 25.0,
    fontWeight: FontWeight.bold,
    fontFamily: 'Roboto'
  );

  _CounterPageState() {
    Timer.periodic(Duration(seconds: 3), reloadSubscriberCount);

    counterPageBloc.addChannel(TSERIES_CHANNEL_ID);
    counterPageBloc.addChannel(PEW_DIE_PIE_CHANNEL_ID);

    isConnectedToInternet = internetState.isConnected();
    shouldRenderNotifier = !isConnectedToInternet;

    // listen to change in internet connectivity
    internetChangeListener.onChange.listen((InternetState _) {
      this.setState(() {
        isConnectedToInternet = internetState.isConnected();
        shouldRenderNotifier = true;
      });
    });
  }

  void reloadSubscriberCount(Timer timer) {
    shouldRenderNotifier = false;
    counterPageBloc.updateAllSubscriberCounts();
  }

  void toggleSettingsPage() {
    if (isSettingsOpen) {
      this.setState(() {
        isSettingsOpen = false;
      });
    }
    else {
      this.setState(() {
        isSettingsOpen = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Widget internetConnectivityNotifier = shouldRenderNotifier
      ? InternetConnectivityNotifier(isConnected: isConnectedToInternet)
      : Container();

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: BlocBuilder(
        bloc: counterPageBloc,
        builder: (context, CounterPageState mainCounterPageState) {
          YoutubeChannel tSeriesChannel = mainCounterPageState.getChannel(TSERIES_CHANNEL_ID);
          YoutubeChannel pewDiePieChannel = mainCounterPageState.getChannel(PEW_DIE_PIE_CHANNEL_ID);

          if (tSeriesChannel == null || pewDiePieChannel == null) {
            Widget messageWidget = Text('Loading data...', style: textStyle);
            return FullscreenLoader(messageWidget);
          }

          return Container(
            color: Theme.of(context).backgroundColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ChannelUI(youtubeChannel: tSeriesChannel, counterPageBloc: counterPageBloc,)
                  ],
                ),

                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Container(
                      child: DifferenceWidget(
                        tSeriesChannel: tSeriesChannel,
                        pewDiePieChannel: pewDiePieChannel,
                      )
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ChannelUI(youtubeChannel: pewDiePieChannel, counterPageBloc: counterPageBloc,)
                  ],
                ),

                internetConnectivityNotifier
              ]
            )
          );
        }
      ),
    );
  }

  @override
  void dispose() {
    counterPageBloc.dispose();
    super.dispose();   
  }
}

class ChannelUI extends StatelessWidget {
  final YoutubeChannel youtubeChannel;
  final textStyle = TextStyle(
    fontSize: 25.0,
    fontWeight: FontWeight.bold,
    fontFamily: 'Roboto'
  );
  final defaultMargin = EdgeInsets.fromLTRB(0, 10, 0, 0);
  final CounterPageBloc counterPageBloc;
  
  ChannelUI({
    Key key,
    this.youtubeChannel,
    this.counterPageBloc
  });

  @override
  Widget build(BuildContext context) {
    String channelId = youtubeChannel.channelId;
    String profilePictureUrl = youtubeChannel.channelPicture;
    String channelName = youtubeChannel.channelName;
    int subscriberCount = youtubeChannel.subscriberCount;

    ThemeData theme = Theme.of(context);
    double imageDimension = 160;
    double borderWidth = 5;

    if (profilePictureUrl == null) {
      return Container();
    }

    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: defaultMargin,
            child: Container(
              alignment: Alignment.center,
              child: Hero(
                tag: channelId + '_picture',
                child: GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(imageDimension/2 + borderWidth),
                      border: Border.all(color: theme.primaryColor, width: borderWidth)
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(imageDimension/2),
                      child: TransitionToImage(
                        AdvancedNetworkImage(profilePictureUrl, useDiskCache: true),
                        loadingWidget: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                        ),
                        fit: BoxFit.cover,
                        placeholder: Icon(Icons.refresh),
                        width: imageDimension,
                        height: imageDimension,
                      ),
                    ),
                  ),
                  onDoubleTap: () {
                    this.counterPageBloc.removeChannel(TSERIES_CHANNEL_ID);
                    this.counterPageBloc.removeChannel(PEW_DIE_PIE_CHANNEL_ID);

                    this.counterPageBloc.addChannel(TSERIES_CHANNEL_ID);
                    this.counterPageBloc.addChannel(PEW_DIE_PIE_CHANNEL_ID);
                  },
                  onTap: () {
                    Navigator.push(
                      context, 
                      new MaterialPageRoute(
                        builder: (context) => new YoutubeChannelDetailsPage(
                          youtubeChannel: youtubeChannel,
                          description: youtubeChannel.channelId == TSERIES_CHANNEL_ID ? T_SERIES_DESCRIPTION : PEW_DIE_PIE_DECSRIPTION
                        )
                      )
                    );
                  },
                ),
              ),
            ),
          ),
          Container(
            margin: defaultMargin,
            child: Text(
              channelName,
              style: textStyle,
            ),
          ),
          Container(
            margin: defaultMargin,
            child: new Counter(value: subscriberCount, textStyle: textStyle),
          )
        ],
      )
    );
  } 
}

class DifferenceWidget extends StatelessWidget {
  final YoutubeChannel tSeriesChannel, pewDiePieChannel;
  
  DifferenceWidget({
    Key key,
    this.tSeriesChannel,
    this.pewDiePieChannel
  });

  @override
  Widget build(BuildContext context) {
    if (tSeriesChannel == null || tSeriesChannel.subscriberCount == null || pewDiePieChannel == null || pewDiePieChannel.subscriberCount == null) {
      return Container();
    }

    int difference = pewDiePieChannel.subscriberCount - tSeriesChannel.subscriberCount;
    String differenceText = '';

    if (difference == 0) {
      differenceText = tSeriesChannel.channelName + ' and ' + pewDiePieChannel.channelName + ' has same number of subscribers';

      return Text(differenceText);
    }
    else if (difference > 0) {
      differenceText = pewDiePieChannel.channelName + ' is ahead by';
    }
    else if (difference < 0) {
      differenceText = tSeriesChannel.channelName + ' is ahead by';
    }

    TextStyle textStyle = new TextStyle(
      color: Colors.white,
      fontSize: 18.0,
    );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(5.0)
      ),
      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(differenceText + ' ', style: textStyle),
          Counter(value: difference, textStyle: textStyle),
          Text(' subscribers.', style: textStyle),
        ],
      ),
    );
  }
}

class InternetConnectivityNotifier extends StatelessWidget {
  final bool isConnected;

  InternetConnectivityNotifier({
    Key key,
    this.isConnected
  });

  @override
  Widget build(BuildContext context) {
    Timer.run(() {
      String message = isConnected
        ? "You're connected, please wait a few seconds for latest subscriber count"
        : "You're right now seeing last saved data, to check latest subscriber count connect this device to internet";

      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ));
    });

    return Container();
  }
}

class FullscreenLoader extends StatelessWidget {
  final Widget messageWidget;

  const FullscreenLoader(this.messageWidget);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
          Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              ),
            ),
            messageWidget
          ],
        )
      ],
    );
  }
}