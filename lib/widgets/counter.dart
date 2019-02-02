import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Counter extends StatefulWidget {
  int _value = 0;
  TextStyle _textStyle;

  Counter({int value, Key key, maxTime, TextStyle textStyle}) {
    _value = value;
    _textStyle = textStyle;
  }

  @override
  CounterState createState() => new CounterState(_value);
}

class CounterState extends State<Counter> {
  static const int UPDATE_FREQUENCY = 75;
  int _counter = 0;
  int finalValue = 0;
  
  Timer timer, maxTimeLimit;
  NumberFormat nf = new NumberFormat.simpleCurrency(decimalDigits: 0, name: 'JPY', locale: 'en_US');  
  String formattedCounter = '';

  CounterState(int value) {
    finalValue = _counter = value;
    formattedCounter = formatNumber(_counter);
  }

  formatNumber(int value) {
    if (value != null) {
      return nf.format(value).substring(1);
    }

    return 0;
  }

  @override
  void didUpdateWidget(Counter oldWidget) {
    
    if (timer != null) {
      timer.cancel();
      setState(() {      
        _counter = finalValue;
      });
    }

    finalValue = oldWidget != null ? oldWidget._value : widget._value;

    timer = Timer.periodic(Duration(milliseconds: UPDATE_FREQUENCY), updateCounter);
    super.didUpdateWidget(oldWidget);
  }

  setFinalValue() {
    setState(() {
      _counter = finalValue;
      formattedCounter = formatNumber(_counter);
    });
  }

  void updateCounter(Timer timer) {
    if (_counter == finalValue) {
      setFinalValue();
      timer.cancel();
      return;
    }

    int difference =  finalValue - _counter;
    int delta = difference < 0 ? -1 : 1;

    setState(() {
      _counter +=  delta;
      formattedCounter = formatNumber(_counter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Text(
      '$formattedCounter',
      style: widget._textStyle,
    );
  }
}
