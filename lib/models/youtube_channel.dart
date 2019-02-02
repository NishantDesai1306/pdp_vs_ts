import 'package:connectivity/connectivity.dart';

import "package:pdp_vs_ts/api/youtube_api.dart";
import 'package:pdp_vs_ts/helpers/shared_preference_helper.dart';
import "package:pdp_vs_ts/models/youtube_video.dart";
import 'package:shared_preferences/shared_preferences.dart';

class YoutubeChannel {
  String _channelId;
  String _channelPicture;
  String _channelName;
  int _subscriberCount;
  List<YoutubeVideo> _videos = new List();

  String _error = '';

  String get channelId => _channelId; 
  String get channelPicture => _channelPicture; 
  String get channelName => _channelName; 
  List<YoutubeVideo> get videos => _videos; 
  int get subscriberCount => _subscriberCount; 

  YoutubeChannel(this._channelId, this._channelName, this._channelPicture, [this._subscriberCount, this._videos]);

  static empty(channelId) {
    return new YoutubeChannel(channelId, null, null, null);
  }

  static Future<YoutubeChannel> fromChannelId(channelId) async {
    YoutubeChannel youtubeChannel = await YoutubeAPI.getYoutubeChannel(channelId);
    return youtubeChannel;
  }

  static Future<YoutubeChannel> fromSharedPreferences(channelId) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String channelName = sp.getString(SharedPreferenceHelper.getNameKey(channelId));
    String  channelPicture = sp.getString(SharedPreferenceHelper.getProfilePictureKey(channelId));
    int subscriberCount = sp.getInt(SharedPreferenceHelper.getSubscribersKey(channelId));

    YoutubeChannel youtubeChannel = new YoutubeChannel(channelId, channelName, channelPicture);
    youtubeChannel.setSubscriberCount(subscriberCount);
    youtubeChannel.setVideos([]);

    return youtubeChannel;
  }

  void setError(String errorMessage) {
    this._error = errorMessage;
  }
  String getError() {
    return this._error;
  }

  Future writeToSharedPreferences({bool onlySubscriberCount = false}) async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    // save data to shared preferences
    if (!onlySubscriberCount) {
      sp.setString(SharedPreferenceHelper.getNameKey(this.channelId), this.channelName);
      sp.setString(SharedPreferenceHelper.getProfilePictureKey(this.channelId), this.channelPicture);
    }

    sp.setInt(SharedPreferenceHelper.getSubscribersKey(this.channelId), this.subscriberCount);
  }

  void setVideos(List<YoutubeVideo> videos) {
    this._videos = videos;
  }

  void setSubscriberCount(int subscriberCount) {
    this._subscriberCount = subscriberCount;
    this.writeToSharedPreferences(onlySubscriberCount: true);
  }

  @override
    String toString() {
      return (this._channelName ?? 'null') + ' - ' + (this._subscriberCount != null ? this._subscriberCount.toString() : 'null');
    }
}