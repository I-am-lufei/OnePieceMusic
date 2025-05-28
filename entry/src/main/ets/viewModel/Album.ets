import Singer from "./Singer";
import SongInfo from "./SongInfo";

export default class Album {
  name: string = '';
  mid: string = '';
  cover_url: string = '';
  desc: string = '';
  time: string = '';
  singer: Singer[] = [];
  song_list: SongInfo[] = [];
}