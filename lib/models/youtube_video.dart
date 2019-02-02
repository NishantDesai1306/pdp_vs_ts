class YoutubeVideo {
  String _id;
  String _title;
  String _description;
  String _thumbnail;

  String get id => _id; 
  String get title => _title; 
  String get description => _description; 
  String get thumbnail => _thumbnail; 

  YoutubeVideo(this._id, this._title, this._thumbnail, this._description);

  @override
    String toString() {
      return '$_id $_title';
    }
}