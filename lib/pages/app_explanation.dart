import 'dart:io';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pdp_vs_ts/helpers/shared_preference_helper.dart';
import 'package:pdp_vs_ts/pages/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppExplanation extends StatefulWidget {
  static String route = '/explanation';
  _AppExplanationState createState() => _AppExplanationState();
}

class _AppExplanationState extends State<AppExplanation> {
  int _currentPage = 0;  

  _AppExplanationState() {
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      String key = SharedPreferenceHelper.getAppExplanationKey();
      sp.setBool(key, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;
    double bottomButtonBarHeight = screenSize.height * 0.075;

    final CarouselSlider slider = CarouselSlider(
      aspectRatio: 1,
      items: [
        Stack(
          alignment: Alignment.center,
          children: <Widget>[
            FlareActor(
              'assets/flares/counter.flr',
              animation: "counter",
              fit: BoxFit.cover,
            ),
          ],
        ),

        Stack(
          alignment: Alignment.center,
          children: <Widget>[
            FlareActor(
              'assets/flares/screenshot.flr',
              animation: "screenshot",
              fit: BoxFit.cover,
            ),
          ],
        ),
      ],
      onPageChanged: (currentPageIndex) {
        setState(() {
          _currentPage = currentPageIndex;
        });
      },
    );

    String message =_currentPage == 0
      ? "Check the subscriber count live."
      : "Tap and hold on main page to share screenshot with your contacts.";
    
    return Container(
      child: Scaffold(
        backgroundColor: theme.primaryColor,
        body: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(20),
              alignment: Alignment.center,
              height: screenSize.height - bottomButtonBarHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  slider,

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    height: 100,  // just a hack so that height does not changes when text gets wrapped in smaller screens
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 20
                      )
                    ),
                  )
                ],
              ),
            ),

            BottomButtonBar(
              bottomButtonBarHeight: bottomButtonBarHeight,
              slider: slider,
              currentPageIndex:_currentPage
            )
          ]
        ),
      ),
    );
  }
}

class BottomButtonBar extends StatelessWidget {
  final CarouselSlider slider;
  final double bottomButtonBarHeight;
  final int currentPageIndex;
  final double buttonWidth = 150;

  Duration pageChangeAnimationDuration = Duration(milliseconds: 250); 
  Curve pageChangeAnimationCurve = Curves.linear;

  BottomButtonBar({
    Key key,
    @required this.bottomButtonBarHeight,
    @required this.slider,
    @required this.currentPageIndex,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    bool isAtLastPage = currentPageIndex == slider.items.length - 1;
    bool isAtFirstPage =currentPageIndex == 0;

    Function getOnPrevious() {
      // current page is first page page
      if (isAtFirstPage) {
        return null;
      }
      
      return () {
        slider.previousPage(
          duration: pageChangeAnimationDuration,
          curve: pageChangeAnimationCurve
        );
      };
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white))
      ),
      height: bottomButtonBarHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: bottomButtonBarHeight,
            width: buttonWidth,
            child: FlatButton(

              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.chevron_left),
                  Text("Previous")
                ],
              ),
              onPressed: getOnPrevious(),
            ),
          ),

          Container(
            height: bottomButtonBarHeight,
            width: buttonWidth,
            child: FlatButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(isAtLastPage ? "Go to App" : "Next"),
                  Icon(Icons.chevron_right),
                ],
              ),
              onPressed: () {
                if (isAtLastPage) {
                  Navigator.of(context).pushReplacementNamed(MainPage.route);
                }
                else {
                  slider.nextPage(
                    duration: pageChangeAnimationDuration,
                    curve: pageChangeAnimationCurve
                  );
                }
              }
            ),
          ),
        ],
      ),
    );
  }
}