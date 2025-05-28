import DataBase from "../common/Database";
import { LrcParser } from "../common/LyricParser";
import { RCPUtils } from "../common/RCPUtils";
import hot_return from "../viewModel/hotReturn";
import SongInfo from "../viewModel/SongInfo";
import { systemDateTime } from '@kit.BasicServicesKit';
import { avPlayerManager } from "../common/avPlayerManager";
import { promptAction } from "@kit.ArkUI";
import CategoryList from "../viewModel/CategoryList";

@Builder
export function StartPageBuilder() {
  StartPage()
}


@Component
struct StartPage {
  @LocalStorageLink('pathStack') pathStack: NavPathStack = new NavPathStack();
  @LocalStorageLink('database') database: DataBase = new DataBase();
  @LocalStorageLink('playerManager') playerManager: avPlayerManager = new avPlayerManager();
  hot_song_id_list: hot_return[] = [];
  @State time: number = 0;
  @State time_id: number = 0;
  @State interval_id: number = 0;
  @State isLoading: boolean = false; // 用于显示加载指示
  parser: LrcParser = new LrcParser();
  singer_id: string =
    '000CK5xN3yZDJt'; //000CK5xN3yZDJt//0025NhlN2yWrP4//000aHmbL2aPXWH//001BLpXF2DyJe2//003Nz2So3XXYek//001Lr98T0yEWAk

  async getSongInfo(rcpUtil: RCPUtils, song_mid: string, album_id: string, id: number) {
    let song_info: SongInfo = new SongInfo(0, song_mid, '', album_id, '', '', '', '', '');
    await Promise.all([rcpUtil.getPlaySongUrl(song_mid), rcpUtil.getPlaySongInfo(song_mid),
      rcpUtil.getPlayAlbumUrl(album_id), rcpUtil.getPlaySongLyric(song_mid)
    ]).then((value: [string, SongInfo, string, string]) => {
      song_info.mp3_url = value[0];
      song_info.name = value[1].name;
      song_info.singer = value[1].singer;
      song_info.singer_id = value[1].singer_id;
      song_info.cover_img_url = value[2];
      song_info.lyric = value[3];
      this.playerManager.cur_play_song.songList.push(new SongInfo(id, song_mid, song_info.name, album_id,
        song_info.cover_img_url,
        song_info.lyric, song_info.mp3_url, song_info.singer, song_info.singer_id));
      if (this.playerManager.cur_play_song.songList.length === 1) {
        this.playerManager.cur_song_item = this.playerManager.cur_play_song.songList[0];
        this.playerManager.playSelected(this.playerManager.cur_song_item);
      }
      if (this.playerManager.cur_play_song.songList.length === this.hot_song_id_list.length) {
        this.isLoading = true;
        rcpUtil.destroySession();
      }
    })
    // await rcpUtil.getPlaySongUrl(song_mid).then((value: string) => {
    //   song_info.mp3_url = value;
    // });
    // await rcpUtil.getPlaySongInfo(song_mid).then((value: SongInfo) => {
    //   song_info.name = value.name;
    //   song_info.singer = value.singer;
    //   song_info.singer_id = value.singer_id;
    // });
    // await rcpUtil.getPlayAlbumUrl(album_id).then((value: string) => {
    //   song_info.cover_img_url = value;
    // });
    // await rcpUtil.getPlaySongLyric(song_mid).then((value: string) => {
    //   song_info.lyric = value;
    // });
  }

  async aboutToAppear(): Promise<void> {
    this.playerManager.init();
    let time = systemDateTime.getTime();
    // this.database.query_song_all();
    // this.database.delete('song');
    // this.database.delete('playlist');
    // this.database.delete('album');
    // this.database.delete('singer');
    promptAction.showToast({
      message: time.toString()
    })
    let rcpUtil: RCPUtils = new RCPUtils();

    await rcpUtil.getRankList().then((value) => {
      this.playerManager.cur_play_song.RankList = value;
    });
    await rcpUtil.getCategoryList().then((value: CategoryList[]) => {
      this.playerManager.cur_play_song.CategoryList = value;
    });
    await rcpUtil.getRankDetail().then((val) => {
      this.playerManager.Rank_Detail = val;
    })

    //拿到歌手热歌的id
    await rcpUtil.getSingerHotId(this.singer_id).then((value: hot_return[]) => {
      this.hot_song_id_list = value;
    });

    //初始化待播放歌曲列表
    this.hot_song_id_list.forEach(async (item, index) => {
      this.getSongInfo(rcpUtil, item.hot_song_id, item.album_id, index)
    })

  }

  build() {
    NavDestination() {
      Column() {
        Stack({ alignContent: Alignment.TopEnd }) {
          Image($r('app.media.player_cover'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Fill)
          Button('跳过 0' + (3 - this.time))
            .backgroundColor('#D73533')
            .fontColor('white')
            .opacity(0.8)
            .borderRadius('5vp')
            .margin({ top: '20vp', right: '20vp' })
            .onClick(() => {
              this.pathStack.replacePathByName('Layout', this.isLoading, false)
              clearInterval(this.interval_id)
              clearTimeout(this.time_id)
            })
        }
      }
      .width('100%')
      .height('100%')
    }.onShown(() => {
      this.interval_id = setInterval(() => {
        this.time += 1;
      }, 1000)
      this.time_id = setTimeout(() => {
        this.pathStack.replacePathByName('Layout', this.isLoading, false)
      }, 3000)
    })
  }
}