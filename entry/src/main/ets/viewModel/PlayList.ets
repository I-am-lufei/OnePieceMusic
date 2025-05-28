import SongInfo from "./SongInfo";

export default class PlayList {
  id: string;
  picurl: string;
  name: string;
  listening_num: string;
  creator_name: string;
  headpic: string = '';
  desc: string = '';
  song_list: SongInfo[] = [];

  constructor(id: string, picurl: string, name: string, listening_num: string, creator_name: string) {
    this.id = id;
    this.picurl = picurl;
    this.name = name;
    this.listening_num = listening_num;
    this.creator_name = creator_name;
  }
}