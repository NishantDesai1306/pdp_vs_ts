import 'package:pdp_vs_ts/models/youtube_channel.dart';

class CounterPageState {
  List<YoutubeChannel> _channels = [];

  CounterPageState();

  factory CounterPageState.initial() {
    CounterPageState instance = CounterPageState();
    return instance;
  }
  
  factory CounterPageState.createNew(List<YoutubeChannel> channels) {
    CounterPageState instance = CounterPageState();

    instance._channels = channels;

    return instance;
  }

  factory CounterPageState.clone(CounterPageState state) {
    CounterPageState instance = CounterPageState();

    instance._channels = List.from(state.channels);

    return instance;
  }

  List<YoutubeChannel> get channels => _channels;

  addChannel(YoutubeChannel youtubeChannel) {
    int index = this._channels.indexWhere((channel) => channel.channelId == youtubeChannel.channelId);

    if (index == -1) {
      this._channels.add(youtubeChannel);
    }
  }

  YoutubeChannel getChannel(String channelId) {
    if (this._channels.isEmpty) {
      return null;
    }

    YoutubeChannel youtubeChannel = this._channels.firstWhere(
      (youtubeChannel) => youtubeChannel.channelId == channelId,
      orElse: () => null
    );

    return youtubeChannel;
  }

  YoutubeChannel updateSubscriberCount(String channelId, int newSubscriberCount) {
    YoutubeChannel youtubeChannel = this.getChannel(channelId);

    if (youtubeChannel == null) {
      return null;
    }
    
    youtubeChannel.setSubscriberCount(newSubscriberCount);
    return youtubeChannel;
  }

  void removeChannel(channelId) {
    if (this._channels.isNotEmpty) {
      this._channels.removeWhere((youtubeChannel) => youtubeChannel.channelId == channelId);
    }
  }
}