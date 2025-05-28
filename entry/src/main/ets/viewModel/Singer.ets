import Album from "./Album";
import SongInfo from "./SongInfo";

export default class Singer {
  name: string = '';
  mid: string = '';
  pic_url: string = '';
  hot_list: SongInfo[] = [];
  album: Album[] = [];
}