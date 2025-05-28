export class song {
  singer_name: string = '';
  song_name: string = '';

  constructor(singer_name: string, song_name: string) {
    this.song_name = song_name;
    this.singer_name = singer_name;
  }
}

export class RankList {
  topTitle: string = '';
  listenCount: string = '';
  picUrl: string = '';
  songList: song[] = [];

  constructor(topTitle: string, listenCount: string, picUrl: string, songList: song[]) {
    this.topTitle = topTitle;
    this.listenCount = listenCount;
    this.picUrl = picUrl;
    this.songList = songList;
  }
}