export default class SongInfo {
  id: number;
  song_mid: string;
  name: string;
  album_id: string;
  cover_img_url: string;
  lyric: string;
  mp3_url: string;
  singer: string;
  singer_id: string;

  constructor(id: number, song_id: string, name: string, album_id: string,
    cover_img_url: string, lyric: string, mp3_url: string, singer: string, singer_id: string) {
    this.id = id;
    this.song_mid = song_id;
    this.name = name;
    this.album_id = album_id;
    this.cover_img_url = cover_img_url;
    this.lyric = lyric;
    this.mp3_url = mp3_url;
    this.singer = singer;
    this.singer_id = singer_id;
  }
}