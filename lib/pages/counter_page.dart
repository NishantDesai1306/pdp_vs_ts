import "dart:async";
import "dart:io";
import "package:flutter/material.dart";
import "dart:typed_data";
import "dart:ui" as ui;
import "package:flutter/rendering.dart";
import "package:flutter_advanced_networkimage/flutter_advanced_networkimage.dart";
import "package:simple_permissions/simple_permissions.dart";
import "package:flutter_advanced_networkimage/transition_to_image.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:share_extend/share_extend.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:pdp_vs_ts/blocs/internet_connectivity/bloc.dart";
import "package:pdp_vs_ts/blocs/internet_connectivity/state.dart";

import "package:pdp_vs_ts/models/youtube_channel.dart";
import "package:pdp_vs_ts/widgets/counter.dart";
import "package:pdp_vs_ts/constants/index.dart";
import "package:pdp_vs_ts/pages/youtube_channel_details_page.dart";
import "package:pdp_vs_ts/blocs/counter_page/bloc.dart";
import "package:pdp_vs_ts/blocs/counter_page/state.dart";
import "package:pdp_vs_ts/helpers/shared_preference_helper.dart";

class CounterPage extends StatefulWidget {
  final bool isSettingsOpen;

  CounterPage({
    this.isSettingsOpen
  });

  _CounterPageState createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  final CounterPageBloc counterPageBloc = CounterPageBloc();
  final InternetChangeListener internetChangeListener = InternetChangeListener();
  InternetState internetState = InternetState();
  static GlobalKey widgetContainerKey = new GlobalKey();

  bool isConnectedToInternet = false;
  bool shouldRenderNotifier = false;
  
  final textStyle = TextStyle(
    fontSize: 25.0,
    fontWeight: FontWeight.bold,
    fontFamily: "Roboto"
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

  Future<bool> askPermissionIfRequired(Permission permission, String errorMessage) async {
    bool hasPermission = await SimplePermissions.checkPermission(permission);

    if (!hasPermission) {
      // if app does not have required permission then ask for it
      PermissionStatus result = await SimplePermissions.requestPermission(permission);

      if (result != PermissionStatus.authorized) {
        // if user has not given permission then show error message
        showSnackBar(message: "Please autorize this app to write on storgae");
        return false;
      }
    }

    return true;
  }

  Future<bool> confirmAboutScreenshot() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String key = SharedPreferenceHelper.getLongPressScreenshotKey();
    bool dontShowAgainValue = sp.getBool(key) ?? null;

    // if user has checked dont show again last time then send the value that was selected last time
    if (dontShowAgainValue != null) {
      return dontShowAgainValue;
    }

    bool returnValue = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => ConfrimScreenshotDialog(dontShowAgainPreferenceKey: key)
    );

    if (false == returnValue) {
      showSnackBar(
        message: "Screenshot cancelled"
      );
    }

    return returnValue;
  }

  Future<bool> checkPermissions() async {
    bool isSafeToProceed = false;

    isSafeToProceed = await confirmAboutScreenshot();

    if (!isSafeToProceed) {
      return false;
    }

    isSafeToProceed = await askPermissionIfRequired(
      Permission.WriteExternalStorage,
      "Please autorize this app to write on storage"
    );

    if (!isSafeToProceed) {
      return false;
    }

    isSafeToProceed = await askPermissionIfRequired(
      Permission.ReadExternalStorage, 
      "Please autorize this app to read from storage"
    );

    if (!isSafeToProceed) {
      return false;
    }

    return true;
  }

  Future<File> storeScreenShot() async {
    // genereate data for screenshot
    RenderRepaintBoundary boundary = widgetContainerKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    String timeStamp =DateTime.now().toString().substring(0, 18);
    String screenshotPath = "$BASE_FOLDER_PATH/screenshot $timeStamp.png";
    File screenshotImage = new File(screenshotPath);
    
    // write screenshot image
    await screenshotImage.writeAsBytes(pngBytes);

    return screenshotImage;
  }

  takeScreenShot() async {
    if (widget.isSettingsOpen) {
      return;
    }

    bool isSafeToProceed = await checkPermissions();

    if (!isSafeToProceed) {
      return;
    }

    // if directory does not exists then create it
    Directory dir = new Directory(BASE_FOLDER_PATH);

    if (!dir.existsSync()) {
      dir.createSync();
    }

    File savedImage = await storeScreenShot();

    // notify user and open share popup
    showSnackBar(message: "Screenshot saved successfully");
    ShareExtend.share(savedImage.path, "image");
  }

  showSnackBar({String message, int seconds = 3}) {
    if (message == null || message.length < 1) {
      return;
    }

    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: seconds)
    ));
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    if (shouldRenderNotifier) {
      Timer.run(() {
        String message = isConnectedToInternet
          ? "You're connected, please wait a few seconds for latest subscriber count"
          : "You're right now seeing last saved data, to check latest subscriber count connect this device to internet";

        showSnackBar(message: message);
      });
    }
    
    Widget screenUI = Container(
      color: theme.scaffoldBackgroundColor,
      child: BlocBuilder(
        bloc: counterPageBloc,
        builder: (context, CounterPageState mainCounterPageState) {
          YoutubeChannel tSeriesChannel = mainCounterPageState.getChannel(TSERIES_CHANNEL_ID);
          YoutubeChannel pewDiePieChannel = mainCounterPageState.getChannel(PEW_DIE_PIE_CHANNEL_ID);

          if (
            tSeriesChannel == null ||
            tSeriesChannel.subscriberCount == null ||
            pewDiePieChannel == null ||
            pewDiePieChannel.subscriberCount == null
          ) {
            Widget messageWidget = Text("Loading data...", style: textStyle);
            return FullscreenLoader(messageWidget);
          }

          List<YoutubeChannel> channels = [
            tSeriesChannel,
            pewDiePieChannel
          ];

          channels.sort((YoutubeChannel channelA, YoutubeChannel channelB) {
            return channelB.subscriberCount - channelA.subscriberCount;
          });

          return Container(
            color: Theme.of(context).backgroundColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ChannelUI(youtubeChannel: channels.elementAt(0), counterPageBloc: counterPageBloc,)
                  ],
                ),

                Container(
                  alignment: Alignment.center,
                  child: Container(
                    child: DifferenceWidget(
                      tSeriesChannel: tSeriesChannel,
                      pewDiePieChannel: pewDiePieChannel,
                    )
                  ),
                ),

                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ChannelUI(youtubeChannel: channels.elementAt(1), counterPageBloc: counterPageBloc,)
                    ],
                  ),
                ),
              ]
            )
          );
        }
      ),
    );

    return GestureDetector(
      child: RepaintBoundary(
        key: widgetContainerKey,
        child: screenUI
      ),
      onLongPress: takeScreenShot,
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
    fontFamily: "Roboto"
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
                tag: channelId + "_picture",
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
    String differenceText = "";

    if (difference == 0) {
      differenceText = tSeriesChannel.channelName + " and " + pewDiePieChannel.channelName + " has same number of subscribers";

      return Text(differenceText);
    }
    else if (difference > 0) {
      differenceText = pewDiePieChannel.channelName + " is ahead by";
    }
    else if (difference < 0) {
      differenceText = tSeriesChannel.channelName + " is ahead by";
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
          Text(differenceText + " ", style: textStyle),
          Counter(value: difference, textStyle: textStyle),
          Text(" subscribers.", style: textStyle),
        ],
      ),
    );
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

class ConfrimScreenshotDialog extends StatefulWidget {
  final String dontShowAgainPreferenceKey;

  ConfrimScreenshotDialog({
    this.dontShowAgainPreferenceKey
  });

  @override
  State<ConfrimScreenshotDialog> createState() => ConfrimScreenshotDialogState();
}
class ConfrimScreenshotDialogState extends State<ConfrimScreenshotDialog> {
  bool dontShowAgain = false;

  ConfrimScreenshotDialogState();

  handleDontShowAgainChange(bool isChecked) {
    setState(() {
      dontShowAgain = isChecked;
    });
  }

  setPreferenceAndReturn(bool isChecked) async {
    if (dontShowAgain) {
      SharedPreferences sp = await SharedPreferences.getInstance();
      sp.setBool(widget.dontShowAgainPreferenceKey, isChecked);
    }

    return Navigator.of(context).pop(isChecked);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextStyle textStyle =TextStyle(
      color: theme.textTheme.body1.color
    );

    return Container(
      child: SimpleDialog(
        title: Text("Press and Hold Screenshot", style: textStyle),
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: <Widget>[
                Text("Do you want to share a screenshot of current subscriber count ?", style: textStyle),

                Row(
                  children: <Widget>[
                    Switch(
                      activeColor: theme.primaryColor,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey,
                      onChanged: handleDontShowAgainChange,
                      value: dontShowAgain,
                    ),
                    Text("Don't ask me again", style: textStyle)
                  ],
                )
              ],
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              FlatButton(
                child: Text("Yes", style: textStyle),
                onPressed: () {
                  setPreferenceAndReturn(true);
                },
              ),

              FlatButton(
                child: Text("No", style: textStyle),
                onPressed: () {
                  setPreferenceAndReturn(false);
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
