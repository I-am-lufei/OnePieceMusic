import MyInfo from '../view/MyInfo'
import Home from '../view/Home'
import SongInfo from '../viewModel/SongInfo'
import { RCPUtils } from "../common/RCPUtils";
import { avPlayerManager } from '../common/avPlayerManager'
import { LrcParser } from '../common/LyricParser';
import hot_return from '../viewModel/hotReturn'
import { promptAction } from '@kit.ArkUI';
import CategoryList from '../viewModel/CategoryList';
import DataBase, { PlayListItem, SongItem } from '../common/Database';
import { systemDateTime } from '@kit.BasicServicesKit';


@CustomDialog
export struct RecentPlayList {
  @State isLoading: boolean = true;
  controllerTwo?: CustomDialogController;
  @LocalStorageLink('database') database: DataBase = new DataBase();
  @LocalStorageLink('playerManager') playerManager: avPlayerManager = new avPlayerManager();

  build() {
    Column() {
      Tabs() {
        TabContent() {
          List() {
            ForEach(this.playerManager.cur_play_song.songList, (item: SongInfo) => {
              ListItem() {
                Row() {
                  Row() {
                    Text(item.name)
                      .fontColor('white')
                    Text('-')
                      .fontColor('white')
                    Text(item.singer)
                      .fontColor('white')
                  }

                  Image($r('app.media.delete'))
                    .width('15vp')
                    .height('15vp')
                    .fillColor('white')
                }
                .width('100%')
                .padding({
                  top: '10vp',
                  bottom: '10vp',
                  left: '10vp',
                  right: '10vp'
                })
                .onClick(() => {
                  promptAction.showToast({
                    message: item.name
                  })
                })
                .justifyContent(FlexAlign.SpaceBetween)
              }
            }, (item: SongItem) => JSON.stringify(item))
          }
          .width('100%')
          .height('90%')
          .divider({
            strokeWidth: '1vp',
            color: 'white',
            startMargin: '10vp',
            endMargin: '20vp'
          })
          .backgroundColor('#D73533')
        }
        .height('100%')
        .tabBar(SubTabBarStyle.of('当前播放')
          .indicator({
            color: '#D73533'
          })
          .labelStyle({ selectedColor: '#D73533' }))


        TabContent() {
          if (!this.isLoading) {
            List() {
              ForEach(this.playerManager.cur_play_song.recent_song, (item: SongItem, index: number) => {
                ListItem() {
                  Row() {
                    Row() {
                      Text(item.name)
                        .fontColor('white')
                      Text('-')
                        .fontColor('white')
                      Text(item.singer_name)
                        .fontColor('white')
                    }

                    Image($r('app.media.delete'))
                      .width('15vp')
                      .height('15vp')
                      .fillColor('white')
                      .onClick(() => {
                        this.playerManager.cur_play_song.recent_song.splice(index, 1)
                        this.database.update_un_recent(0, item.song_mid)
                      })
                  }
                  .width('100%')
                  .padding({
                    top: '10vp',
                    bottom: '10vp',
                    left: '10vp',
                    right: '10vp'
                  })
                  .onClick(async () => {
                    let song: SongInfo = new SongInfo(0, '', '', '', '', '', '', '', '');
                    song.song_mid = item.song_mid;
                    song.name = item.name;
                    song.album_id = item.album_id;
                    song.singer = item.singer_name;
                    song.singer_id = item.singer_mid;
                    song.lyric = item.lyric;
                    song.mp3_url = item.mp3_url;
                    let rcpUtil: RCPUtils = new RCPUtils();
                    this.playerManager.isShowPlayPage = false;
                    await rcpUtil.getPlayAlbumUrl(item.album_id).then(async (val) => {
                      song.cover_img_url = val;
                      rcpUtil.destroySession();
                      await this.playerManager.playSelected(song).then(() => {
                        this.playerManager.isShowPlayPage = true;
                      });
                    })
                  })
                  .justifyContent(FlexAlign.SpaceBetween)
                }
              }, (item: SongItem) => JSON.stringify(item))
            }
            .width('100%')
            .height('90%')
            .divider({
              strokeWidth: '1vp',
              color: 'white',
              startMargin: '10vp',
              endMargin: '20vp'
            })
            .backgroundColor('#D73533')
          } else {
            LoadingProgress()
              .width('100vp')
              .height('100vp')
              .color('#D73533')
          }
        }
        .tabBar(SubTabBarStyle.of('最近播放')
          .indicator({
            color: '#D73533'
          })
          .labelStyle({ selectedColor: '#D73533' }))
      }.width('100%')
      .height('85%')
      .onChange(async (index) => {
        if (index === 0) {
        } else {
          await this.database.query_song_recent().then((val) => {
            let length: number = Math.min(val.length, 10)
            this.playerManager.cur_play_song.recent_song = val.slice(0, length);
            this.isLoading = false;
          })
        }
      })

      Button('关闭')
        .width('100%')
        .height('10%')
        .type(ButtonType.Normal)
        .fontColor('black')
        .backgroundColor('white')
        .onClick(() => {
          this.controllerTwo?.close();
        })
    }.backgroundColor('#FFF0F0F0')
    .width('100%')
    .height('50%')
  }
}


@Builder
export function LayoutBuilder() {
  Layout()
}

@Component
struct Layout {
  parser: LrcParser = new LrcParser();
  singer_id: string =
    '000CK5xN3yZDJt'; //000CK5xN3yZDJt//0025NhlN2yWrP4//000aHmbL2aPXWH//001BLpXF2DyJe2//003Nz2So3XXYek//001Lr98T0yEWAk
  hot_song_id_list: hot_return[] = [];
  @LocalStorageLink('database') database: DataBase = new DataBase();
  @LocalStorageLink('playerManager') playerManager: avPlayerManager = new avPlayerManager();
  @LocalStorageLink('pathStack') pathStack: NavPathStack = new NavPathStack();
  Controller: CustomDialogController | null = new CustomDialogController({
    builder: RecentPlayList(),
    alignment: DialogAlignment.Bottom,
    customStyle: false
  });
  @State First: boolean = true;
  @State isLoading: boolean = false; // 用于显示加载指示

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

  // async aboutToAppear(): Promise<void> {
  //   this.playerManager.init();
  //   let time = systemDateTime.getTime();
  //   // this.database.query_song_all();
  //   // this.database.delete('song');
  //   // this.database.delete('playlist');
  //   // this.database.delete('album');
  //   // this.database.delete('singer');
  //   promptAction.showToast({
  //     message: time.toString()
  //   })
  //   let rcpUtil: RCPUtils = new RCPUtils();
  //
  //   await rcpUtil.getRankList().then((value) => {
  //     this.playerManager.cur_play_song.RankList = value;
  //   });
  //   await rcpUtil.getCategoryList().then((value: CategoryList[]) => {
  //     this.playerManager.cur_play_song.CategoryList = value;
  //   });
  //   await rcpUtil.getRankDetail().then((val) => {
  //     this.playerManager.Rank_Detail = val;
  //   })
  //
  //   //拿到歌手热歌的id
  //   await rcpUtil.getSingerHotId(this.singer_id).then((value: hot_return[]) => {
  //     this.hot_song_id_list = value;
  //   });
  //
  //   //初始化待播放歌曲列表
  //   this.hot_song_id_list.forEach(async (item, index) => {
  //     this.getSongInfo(rcpUtil, item.hot_song_id, item.album_id, index)
  //   })
  //
  // }

  build() {
    NavDestination() {
      Column() {
        Tabs({ barPosition: BarPosition.End }) {
          TabContent() {
            if (this.isLoading) {
              Home()
            } else {
              LoadingProgress()
                .width('100vp')
                .height('100vp')
                .color('#D73533')
            }
          }
          .tabBar(new BottomTabBarStyle($r('app.media.index'), '首页')
            .labelStyle({ selectedColor: '#D73533' })
            .iconStyle({ selectedColor: '#D73533' }))

          TabContent() {
            MyInfo()
          }
          .tabBar(new BottomTabBarStyle($r('app.media.my'), '我的')
            .labelStyle({ selectedColor: '#D73533' })
            .iconStyle({ selectedColor: '#D73533' }))
        }
        .onChange(async (index: number) => {
          if (index === 0) {
          } else {
            await Promise.all([this.database.query_playlist_self_create(),
              this.database.query_playlist_liked()
            ]).then((val: [PlayListItem[], PlayListItem[]]) => {
              this.playerManager.self_create_playlist = val[0]
              this.playerManager.liked_playlist = val[1];
            })
            promptAction.showToast({
              message: 'appear'
            })
          }
        })

        if (this.isLoading) {
          Row() {
            Row({ space: '20vp' }) {
              Image(this.playerManager.cur_song_item.cover_img_url)
                .alt($r('app.media.pre_load'))// 使用alt，在网络图片加载成功前使用占位图
                .width('50vp')
                .height('50vp')
              if (this.First) {
                Text(this.playerManager.cur_song_item.name)
                  .fontColor('white')
              } else if (this.playerManager.lyrics.length > 0) {
                Text(this.playerManager.lyrics[this.playerManager.currentLyricIndex].text)
                  .maxLines(1)
                  .width('200vp')
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .fontColor('white')
              } else {
                Text('歌词加载出错')
                  .fontColor('white')
              }
            }

            Row({ space: '20vp' }) {
              Image(this.playerManager.isPlaying ? $r("app.media.playing") : $r("app.media.pause"))
                .width('30vp')
                .height('30vp')
                .fillColor(Color.White)
                .onClick(async () => {
                  this.First = false;
                  if (!this.playerManager.isPlaying) {
                    this.playerManager.songPlay();
                  } else {
                    this.playerManager.songPause();
                  }
                })
              Image($r("app.media.list"))
                .fillColor('white')
                .width('30vp')
                .height('30vp')
                .onClick(() => {
                  this.Controller?.open();
                })
            }
          }
          .width('100%')
          .position({ x: 0, y: '670vp' })
          .justifyContent(FlexAlign.SpaceBetween)
          .backgroundColor('#D73533')
          .onClick(() => {
            let isRefresh: boolean = false;
            this.playerManager.isShowPlayPage = true;
            this.pathStack.pushPathByName("PlayPage", isRefresh, false)
          })
        }
      }
    }
    .onReady((ctx) => {
      this.isLoading = ctx.pathInfo.param as boolean;
    })
    .hideTitleBar(true)
    .hideToolBar(true)
  }
}