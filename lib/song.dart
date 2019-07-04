class Song{
  String key;
  bool major, begin, mid, end;

  Song(this.key, this.major, this.begin, this.mid, this.end);

  toJson(){
    return{
      "key": key,
      "major": major,
      "begin": begin,
      "mid": mid,
      "end": end,
    };
  }
}