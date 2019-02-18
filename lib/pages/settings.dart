import "package:dynamic_theme/dynamic_theme.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:pdp_vs_ts/constants/theme.dart";
import "package:pdp_vs_ts/helpers/shared_preference_helper.dart";
import "package:pdp_vs_ts/pages/about_me.dart";

class SettingsPage extends StatefulWidget {
  static final String route = "/settings";
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int subscriberDifference;
  bool hasDarkTheme = false;
  bool screenshotOnLongPress = false;

  String subscriberDifferencePreferenceKey = SharedPreferenceHelper.getSubscriberDiffernceKey();
  String longPressScreenshotPreferenceKey = SharedPreferenceHelper.getLongPressScreenshotKey();
  String darkThemePreferenceKey = SharedPreferenceHelper.getDarkThemeKey();

  _SettingsPageState() {
    
    SharedPreferences.getInstance()
    .then((SharedPreferences sp) {
      this.setState(() {
        subscriberDifference = sp.getInt(subscriberDifferencePreferenceKey) ?? 0;
        hasDarkTheme = sp.getBool(darkThemePreferenceKey) ?? false;
        screenshotOnLongPress = sp.getBool(longPressScreenshotPreferenceKey) ?? false;
      });
    });
  }

  openNotifyDifferenceModal() async {
    int returnedValue = await showDialog<int>(
      context: context,
      builder: (BuildContext context) => SubscriberSettingDialogue(
        subscriberDifference: subscriberDifference
      )
    );

    if (returnedValue != null && returnedValue > 0) {
      SharedPreferences sp = await SharedPreferences.getInstance();

      setState(() {
        sp.setInt(subscriberDifferencePreferenceKey, returnedValue);
        subscriberDifference = returnedValue;
      });
    } 
  }

  onDarkThemeToggleChange(bool useDarkTheme) async {
    DynamicThemeState dynamicTheme = DynamicTheme.of(context);
    ThemeData newTheme = useDarkTheme ? DARK_THEME : LIGHT_THEME;
    SharedPreferences sp = await SharedPreferences.getInstance();
    
    // change theme
    dynamicTheme.setThemeData(newTheme);

    // setting brightness even after setting theme because this lib checks shared preferences for key isDark
    sp.setBool(darkThemePreferenceKey, useDarkTheme);

    setState(() {
      hasDarkTheme = useDarkTheme; 
    });
  }

  onLongPressToggleChange(bool takeScreenshotOnLongPress) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    
    // change theme
    sp.setBool(longPressScreenshotPreferenceKey, takeScreenshotOnLongPress);

    setState(() {
      screenshotOnLongPress = takeScreenshotOnLongPress; 
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingCategoryTitle = TextStyle(
      color: Colors.white,
      fontSize: 13,
    );
    final settingTitle = TextStyle(
      color: Colors.white,
      fontSize: 15
    );
    final categoryTitleBottomMargin = EdgeInsets.only(bottom: 20);
    final settingsTitleBottomMargin = EdgeInsets.only(bottom: 5);

    return Container(
      padding: EdgeInsets.all(15),
      color: Theme.of(context).primaryColor,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Container(
                      //   margin: categoryTitleBottomMargin,
                      //   child: Text(
                      //     "Notification",
                      //     style: settingCategoryTitle
                      //   ),
                      // ),

                      // Container(
                      //   margin: settingsTitleBottomMargin,
                      //   child: InkWell(
                      //     onTap: openNotifyDifferenceModal,
                      //     child: Row(
                      //       children: <Widget>[
                      //         Expanded(
                      //           child: Column(
                      //             crossAxisAlignment: CrossAxisAlignment.start,
                      //             children: <Widget>[
                      //               Container(
                      //                 margin: settingsTitleBottomMargin,
                      //                 child: Text(
                      //                   "Notify me when differece goes below",
                      //                   style: settingTitle
                      //                 ),
                      //               ),
                      //               Container(
                      //                 child: Text(
                      //                   (subscriberDifference != null ? subscriberDifference.toString() + " subscribers" : ""),
                      //                   style: settingTitle
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //         )
                      //       ],
                      //     ),
                      //   ),
                      // ),

                      // Divider(
                      //   color: Colors.white,
                      //   height: 30,
                      // ),

                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              margin: settingsTitleBottomMargin,
                              child: Text(
                                "Dark Theme",
                                style: settingTitle
                              ),
                            ),
                            Switch(
                              activeColor: LIGHT_THEME.primaryColor,
                              inactiveThumbColor: Colors.white,
                              onChanged: onDarkThemeToggleChange,
                              value: hasDarkTheme,
                            ),
                          ],  
                        ),
                      ),

                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              margin: settingsTitleBottomMargin,
                              child: Text(
                                "Long press on counter page for screenshot",
                                style: settingTitle
                              ),
                            ),
                            Switch(
                              activeColor: hasDarkTheme ? LIGHT_THEME.primaryColor : DARK_THEME.primaryColor,
                              inactiveThumbColor: Colors.white,
                              onChanged: onLongPressToggleChange,
                              value: screenshotOnLongPress,
                            ),
                          ],  
                        ),
                      ),

                      Divider(
                        color: Colors.white,
                        height: 30,
                      ),

                      Container(
                        margin: settingsTitleBottomMargin,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed(AboutMePage.route);
                          },
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      margin: settingsTitleBottomMargin,
                                      child: Text(
                                        "About Me",
                                        style: settingTitle
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                )
              )
            ],
          )
        ],
      ),
    );
  }
}

class SubscriberSettingDialogue extends StatelessWidget {
  final int subscriberDifference;
  final double spacing = 20;
  TextEditingController notifyDifferenceController;

  SubscriberSettingDialogue({
    Key key,
    @required this.subscriberDifference,
  }) : super(key: key) {
    notifyDifferenceController = TextEditingController(
      text: subscriberDifference.toString()
    );

    // moves the cusor to end of field when focussed
    notifyDifferenceController.selection = TextSelection.fromPosition(
      TextPosition(offset: subscriberDifference.toString().length)
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextStyle textStyle = theme.textTheme.body1;

    return Container(
      child: SimpleDialog(
        titlePadding: EdgeInsets.only(top: spacing, bottom: spacing, left: spacing),
        title: Text("When to notify", style: textStyle),
        contentPadding: EdgeInsets.symmetric(horizontal: spacing),
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: spacing),
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: spacing),
                  child: Text("Notify me when difference in subscriber count goes below", style: textStyle),
                ),
                TextField(
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  controller: notifyDifferenceController,
                  style: TextStyle(
                    color: theme.primaryColor,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(5)
                  ),
                ),      
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: spacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, null);
                  },
                  child: const Text("Cancel"),
                ),
                RaisedButton(
                  onPressed: () {
                    int difference = int.tryParse(notifyDifferenceController.text);
                    // if this value is null then notify user accordingly
                    Navigator.pop(context, difference);
                  },
                  textColor: Colors.white,
                  child: const Text("OK"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
