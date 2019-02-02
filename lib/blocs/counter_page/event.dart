abstract class CounterPageEvent {}

class AddChannelEvent extends CounterPageEvent {
  String channelId;

  AddChannelEvent(this.channelId);
}

class RemoveChannelEvent extends CounterPageEvent {
  String channelId;

  RemoveChannelEvent(this.channelId);
}

class UpdateSubscriberCountEvent extends CounterPageEvent {
  String channelId;

  UpdateSubscriberCountEvent(this.channelId);
}

class UpdateAllSubscriberCountEvent extends CounterPageEvent {}