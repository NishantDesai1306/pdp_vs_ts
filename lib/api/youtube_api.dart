import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;

import 'package:pdp_vs_ts/blocs/internet_connectivity/state.dart';
import 'package:pdp_vs_ts/models/youtube_channel.dart';
import 'package:pdp_vs_ts/models/youtube_video.dart';
import 'package:pdp_vs_ts/constants/index.dart';

class YoutubeAPI {

  static Future<YoutubeChannel> getYoutubeChannel(channelId) async {
    InternetState internetState = InternetState();
    
    // if internet connection is not available then load info from shared preferences
    if (!internetState.isConnected()) {
      YoutubeChannel youtubeChannel = await YoutubeChannel.fromSharedPreferences(channelId);
      return youtubeChannel;
    }

    List<String> fields = [
      'snippet',
    ];
    String requiredFields = fields.join("%2C");
    String url = "$YOUTUBE_API_URL/channels?id=$channelId&part=$requiredFields&key=$YOUTUBE_API_KEY";
    Object headers = {"Accept": "application/json"};

    var response;
    String responseBody;
    
    try {
      response = await http.get(url, headers: headers);
      responseBody = response.body;
    }
    catch (e) {
      print(e.toString());
    }

    if (response != null && response.statusCode != 200) {
      String errorMessage = "got invalid response $responseBody";
      YoutubeChannel emptyChannel = YoutubeChannel.empty(channelId);
      
      emptyChannel.setError(errorMessage);

      return emptyChannel;
    }

    var responseJSON = json.decode(responseBody);
    var channelDetails = responseJSON['items'][0];

    if (channelDetails == null) {
      String errorMessage = 'Something went wrong. \nresponse Code : ${response.statusCode}';
      YoutubeChannel emptyChannel = YoutubeChannel.empty(channelId);
      
      emptyChannel.setError(errorMessage);

      return emptyChannel;
    }

    var snippet = responseJSON['items'][0]['snippet'];

    String channelName = snippet['title'];
    String channelPicture = snippet['thumbnails']['high']['url'];

    int subscriberCount = await getSubscriberCount(channelId);
    List<YoutubeVideo> videos = await getTopVideos(channelId);
    YoutubeChannel youtubeChannel = new YoutubeChannel(channelId, channelName, channelPicture);

    youtubeChannel.setSubscriberCount(subscriberCount);
    youtubeChannel.setVideos(videos);
    youtubeChannel.writeToSharedPreferences();

    return youtubeChannel;
  }

  static Future<int> getSubscriberCount(channelId) async {  
    InternetState internetState = InternetState();

    // if internet connection is not available then load info from shared preferences
    if (!internetState.isConnected()) {
      YoutubeChannel youtubeChannel = await YoutubeChannel.fromSharedPreferences(channelId);
      return youtubeChannel.subscriberCount;
    }

    int subscriberCount;
    List<String> fields = [
      'statistics'
    ];
    String requiredFields = fields.join("%2C");
    String url = "$YOUTUBE_API_URL/channels?id=$channelId&part=$requiredFields&key=$YOUTUBE_API_KEY";
    Object headers = {"Accept": "application/json"};

    var response;
    
    try {
      response = await http.get(url, headers: headers);
    }
    catch (e) {
      print(e.toString());
    }

    if (response != null && response.statusCode == 200) {
      String responseBody = response.body;
      var responseJSON = json.decode(responseBody);
      var channelDetails = responseJSON['items'][0];

      if (channelDetails != null) {
        var statistics = responseJSON['items'][0]['statistics'];

        subscriberCount = num.parse(statistics['subscriberCount']);
      }
    }

    return subscriberCount;
  }

  static Future<List<YoutubeVideo>> getTopVideos(channelId) async {
    String url = "$YOUTUBE_API_URL/search?part=snippet&channelId=$channelId&maxResults=$VIDEO_LIST_SIZE&order=viewCount&key=$YOUTUBE_API_KEY&type=video";
    Object headers = {"Accept": "application/json"};
    print('inside '+ channelId);

    List<YoutubeVideo> videos = [];

    var response;
    
    try {
      response = await http.get(url, headers: headers);
    }
    catch (e) {
      print(e.toString());
    }

    if (response != null && response.statusCode == 200) {
      String responseBody = response.body;
      var responseJSON = json.decode(responseBody);
      List videoDetails = responseJSON['items'];

      videoDetails.forEach((videoDetail) {
        String videoId = videoDetail['id']['videoId'];
        var snippet = videoDetail['snippet'];
        String videoTitle = snippet['title'];
        String videoDescription = snippet['description'];
        String videoThumbnailUrl = snippet['thumbnails']['high']['url'];
        YoutubeVideo youtubeVideo = new YoutubeVideo(videoId, videoTitle, videoThumbnailUrl, videoDescription);
        
        videos.add(youtubeVideo);
      });
    }

    return videos;
  }
}
