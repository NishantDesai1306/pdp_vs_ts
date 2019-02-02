import 'package:bloc/bloc.dart';
import 'package:pdp_vs_ts/api/youtube_api.dart';
import 'package:pdp_vs_ts/blocs/counter_page/event.dart';
import 'package:pdp_vs_ts/blocs/counter_page/state.dart';
import 'package:pdp_vs_ts/models/youtube_channel.dart';

class CounterPageBloc extends Bloc<CounterPageEvent, CounterPageState> {
  @override
  CounterPageState get initialState => CounterPageState.initial();

  addChannel(channelId) {
    dispatch(AddChannelEvent(channelId));
  }

  removeChannel(channelId) {
    dispatch(RemoveChannelEvent(channelId));
  }

  updateSubscriberCount(channelId) {
    dispatch(UpdateSubscriberCountEvent(channelId));
  }

  updateAllSubscriberCounts() {
    dispatch(UpdateAllSubscriberCountEvent());
  }

  @override
  Stream<CounterPageState> mapEventToState(
    CounterPageState currentState,
    CounterPageEvent event,
  ) async* {
    if (event is AddChannelEvent) {
      YoutubeChannel youtubeChannel;
      CounterPageState newState;

      youtubeChannel = currentState.getChannel(event.channelId);
      bool isChannelAlreadyInList = youtubeChannel != null;

      // don't use resources for channel that's already present in state
      if (!isChannelAlreadyInList) {
        // load channel
        youtubeChannel = await YoutubeAPI.getYoutubeChannel(event.channelId);
        
        // add channel to currentState
        currentState.channels.add(youtubeChannel);

        // clone a new state from current state
        newState = CounterPageState.clone(currentState);
      }

      yield newState;
    }
    else if (event is RemoveChannelEvent) {
      // remove channel from current state
      currentState.removeChannel(event.channelId);

      yield new CounterPageState.clone(currentState);
    }
    else if (event is UpdateSubscriberCountEvent) {
      YoutubeChannel youtubeChannel = currentState.getChannel(event.channelId);
      bool isChannelPresentInList = youtubeChannel != null;

      if (isChannelPresentInList) {
        int newSubscriberCount = await YoutubeAPI.getSubscriberCount(event.channelId);
        youtubeChannel.setSubscriberCount(newSubscriberCount);
      }

      yield new CounterPageState.clone(currentState);
    }
    else if (event is UpdateAllSubscriberCountEvent) {
      Iterable<Future<int>> futures = currentState.channels.map((youtubeChannel) {
        return YoutubeAPI.getSubscriberCount(youtubeChannel.channelId);
      });
      List<int> newSubscriberCounts = await Future.wait(futures);
      int index = 0;

      currentState.channels.forEach((youtubeChannel) {
        youtubeChannel.setSubscriberCount(newSubscriberCounts.elementAt(index));
        index++;
      });

      yield new CounterPageState.clone(currentState);
    }
  }
}
