import 'package:flutter/material.dart';
import 'package:pdp_vs_ts/pages/counter_page.dart';
import 'package:pdp_vs_ts/pages/settings.dart';

class MainPage extends StatefulWidget {
  static final String route = '/main';
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isSettingsOpen = false;

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

    return Container(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          textTheme: theme.textTheme,
          iconTheme: theme.iconTheme,
          brightness: Brightness.dark,
          centerTitle: true,
          title: Text('PewDiePie vs T-Series'),
          actions: <Widget>[
            IconButton(
              tooltip: 'App Settings',
              onPressed: toggleSettingsPage,
              icon: Icon(isSettingsOpen ? Icons.close : Icons.settings),
            )
          ],
        ),
        body: MainPagePanels(
          panelToRender: isSettingsOpen
            ? MainPagePanels.SETTINGS_PANEL
            : MainPagePanels.COUNTER_PANEL
          )
      ),
    );
  }
}


class MainPagePanels extends StatefulWidget {
  final String panelToRender;
  static const double HEADER_HEIGHT = 300;
  static const String SETTINGS_PANEL = 'SETTINGS_PANEL';
  static const String COUNTER_PANEL = 'COUNTER_PANEL';

  MainPagePanels({this.panelToRender});

  @override
  State<StatefulWidget> createState() => _MainPagePanels();
}

class _MainPagePanels extends State<MainPagePanels> with SingleTickerProviderStateMixin {
  AnimationController animationController;
  String panelAtTop = MainPagePanels.COUNTER_PANEL;
  
  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
      value: 1
    );
  }

  @override
  void didUpdateWidget(MainPagePanels oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (panelAtTop != widget.panelToRender) {
      panelAtTop = widget.panelToRender;

      double velocity = widget.panelToRender == MainPagePanels.SETTINGS_PANEL ? -1 : 1;

      animationController.fling(velocity: velocity);
    }
  }

  Animation<RelativeRect> getPanelAnimation(BoxConstraints boxConstraints) {
    final height = boxConstraints.biggest.height;
    final settingsPageHeight = height - MainPagePanels.HEADER_HEIGHT;
    final counterPageHeight = -MainPagePanels.HEADER_HEIGHT;

    final RelativeRectTween tween = RelativeRectTween(
      begin: RelativeRect.fromLTRB(0, settingsPageHeight, 0, counterPageHeight),
      end: RelativeRect.fromLTRB(0, 0, 0, 0)
    );

    final CurvedAnimation curvedAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.linear
    );

    return tween.animate(curvedAnimation);
  }

  Widget renderPanels(BuildContext context, BoxConstraints boxConstrainsts) {
    return Container(
      child: Stack(
        children: <Widget>[
          SettingsPage(),

          PositionedTransition(
            rect: getPanelAnimation(boxConstrainsts),
            child: CounterPage(
              isSettingsOpen: widget.panelToRender == MainPagePanels.SETTINGS_PANEL
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: renderPanels,
    );
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }
}
