class Song{
  String title, key;
  bool major, begin, mid, end;

  Song(this.title, this.key, this.major, this.begin, this.mid, this.end);

  toJson(){
    return{
      "title": null,
      "key": key,
      "major": major,
      "begin": begin,
      "mid": mid,
      "end": end,
    };
  }

  toString(){
    return title + ": " + key + " " + (major ? "major" : "minor");
  }
}