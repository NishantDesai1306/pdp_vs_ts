import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdp_vs_ts/constants/square.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:square_in_app_payments/models.dart';
import 'package:square_in_app_payments/in_app_payments.dart';
import 'package:square_in_app_payments/google_pay_constants.dart' as google_pay_constants;

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
  bool _googlePayEnabled = false;
  int donationAmount = 1;

  @override
  void initState() {
    super.initState();
    _initSquarePayment();
  }

  void _initSquarePayment() async {
    bool canUseGooglePay = false;

    if(Platform.isAndroid) {
      await InAppPayments.setSquareApplicationId(SQUARE_APP_ID);
      await InAppPayments.initializeGooglePay(
        SQUARE_LOCATION_ID,
        SQUARE_ENV == 'production'
          ? google_pay_constants.environmentProduction
          : google_pay_constants.environmentTest
      );
      
      canUseGooglePay = await InAppPayments.canUseGooglePay;

      setState(() { 
        _googlePayEnabled = canUseGooglePay;
      });
    }
  }

  void _onStartGooglePay(int amount) async {
    try {
      await InAppPayments.requestGooglePayNonce(
        priceStatus: google_pay_constants.totalPriceStatusFinal,
        price: '$amount.00',
        currencyCode: 'USD',
        onGooglePayNonceRequestSuccess: _onGooglePayNonceRequestSuccess,
        onGooglePayNonceRequestFailure: _onGooglePayNonceRequestFailure,
        onGooglePayCanceled: _onGooglePayCancel);
    } on InAppPaymentsException catch(ex) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Error occurred while processing transaction'),
        duration: Duration(seconds: 3),
      ));
    }
  }

  void _onGooglePayNonceRequestSuccess(CardDetails result) async {
    String message = 'Thank you for your contribution';

    try {
      print('complete');
      print(result);
    } on Exception catch (ex) {
      message = 'Error occurred while processing transaction';
    } finally {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ));
    }
  }

  void _onGooglePayCancel() {
    // handle google pay canceled
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text('Tranaction cancelled'),
      duration: Duration(seconds: 3),
    ));
  }

  void _onGooglePayNonceRequestFailure(ErrorInfo errorInfo) {
    // handle google pay failure
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text('Something went wrong'),
      duration: Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (!_googlePayEnabled) {
      return Container();
    }

    return Container(
      padding: EdgeInsets.only(left: pageSpacing, right: pageSpacing, bottom: pageSpacing),
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: pageSpacing),
            child: RaisedButton(
              onPressed: () {
                _onStartGooglePay(1);
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
                  Text("Buy me a coffee (\$1)"),
                ],
              )
            ),
          ),

          Container(
            child: RaisedButton(
              onPressed: () {
                _onStartGooglePay(5);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: pageSpacing),
                    margin: EdgeInsets.only(right: pageSpacing),
                    child: Icon(Icons.local_pizza)
                  ),
                  Text("Buy me a pizza (\$5)"),
                ],
              )
            ),
          )
        ],
      )
    );
  }
}