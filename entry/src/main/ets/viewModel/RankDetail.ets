export class songs {
  singer_name: string = '';
  song_name: string = '';
  singer_mid: string = '';
  cover: string = '';

  constructor(singer_name: string, song_name: string, singer_mid: string = '', cover: string = '') {
    this.song_name = song_name;
    this.singer_name = singer_name;
    this.singer_mid = singer_mid;
    this.cover = cover;
  }
}

export class RankDetail {
  topTitle: string = '';
  listenCount: string = '';
  songList: songs[] = [];

  constructor(topTitle: string, listenCount: string, songList: songs[]) {
    this.topTitle = topTitle;
    this.listenCount = listenCount;
    this.songList = songList;
  }
}