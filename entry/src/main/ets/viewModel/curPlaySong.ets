import { AlbumItem, PlayListItem, SingerItem, SongItem } from "../common/Database";
import CategoryList from "./CategoryList";
import PlayList from "./PlayList";
import { RankList } from "./RankList";
import Singer from "./Singer";
import SongInfo from "./SongInfo";


export default class curPlaySong {
  song_info: SongInfo = new SongInfo(0, '', '', '', '', '', '', '', '');
  curPlayIndex: number = 0;
  songList: SongInfo[] = [];
  // recentPlayList: SongInfo[] = [];
  search_list: SongInfo[] = [];
  keyword: string = '';
  search_page: number = 1;
  search_limit: number = 10;
  RankList: RankList[] = [];
  CategoryList: CategoryList[] = [];
  playList: PlayList[] = [];
  singerList: Singer[] = [];
  self_create_playlist: PlayListItem[] = [];
  liked_playlist: PlayListItem[] = [];
  liked_album: AlbumItem[] = [];
  liked_song: SongItem[] = [];
  liked_singer: SingerItem[] = [];
  recent_playlist: PlayListItem[] = [];
  recent_album: AlbumItem[] = [];
  recent_song: SongItem[] = [];
  recent_singer: SingerItem[] = [];
  // play_song_list: SongInfo[] = [];
}