import { avPlayerManager } from "../common/avPlayerManager";
import DataBase, { AlbumItem, PlayListItem, SingerItem, SongItem } from "../common/Database";
import { RCPUtils } from "../common/RCPUtils";
import SongInfo from "../viewModel/SongInfo";
import { promptAction } from "@kit.ArkUI";
import Singer from "../viewModel/Singer";
import Album from "../viewModel/Album";
import PlayList from "../viewModel/PlayList";

export class Item {
  index_singer: number = 0;
  index_album: number = 0;
  isAlbumLiked: boolean = false;
  isSongListLiked: boolean[] = [];
  isLoading: boolean = true
}

export class Item1 {
  index_singer: number = 0;
  isSingerLiked: boolean = false;
  isSongListLiked: boolean[] = [];
  isLoading: boolean = true
}

export class Item2 {
  index: number = 0;
  isPlayLiked: boolean = false;
  isSongListLiked: boolean[] = [];
  isLoading: boolean = true
}

@Builder
export function RecentPageBuilder() {
  RecentPage()
}

@Component
struct RecentPage {
  @State isLoadingDetails: boolean = true;
  @State index: number = 0;
  @State isGoingToPage: boolean = false;
  @State isLiked: boolean = false;
  @State isSongListLiked: boolean[] = [];
  @State isLoading: boolean = true;
  @LocalStorageLink('database') database: DataBase = new DataBase();
  @LocalStorageLink('liked_song') liked_song: SongItem[] = [];
  @LocalStorageLink('playerManager') playerManager: avPlayerManager = new avPlayerManager();
  @LocalStorageLink('pathStack') pathStack: NavPathStack = new NavPathStack();

  // async aboutToAppear(): Promise<void> {
  //
  // }

  build() {
    NavDestination() {
      Column() {
        if (!this.isLoadingDetails) {
          Tabs() {
            TabContent() {
              if (!this.isLoading) {
                List() {
                  ForEach(this.liked_song,
                    (item: SongItem, index: number) => {
                      ListItem() {
                        Row() {
                          Row() {
                            Column({ space: '5vp' }) {
                              Text(item.name)
                            }.margin({ left: '10vp' })
                            .alignItems(HorizontalAlign.Start)
                          }

                          Column() {
                            Row() {
                              if (!this.isSongListLiked[index]) {
                                Image($r('app.media.like'))
                                  .width('30vp')
                                  .height('30vp')
                                  .onClick(async () => {
                                    this.isSongListLiked[index] = true;
                                    await this.database.query_song_mid(item.song_mid).then(async (val) => {
                                      if (val.length > 0) {
                                        await this.database.update_like(0,
                                          item.song_mid)
                                      } else {
                                        let info: SongInfo =
                                          new SongInfo(index, item.song_mid, item.name, item.album_id, '', item.lyric,
                                            item.mp3_url, item.singer_name, item.singer_mid)
                                        await this.database.insert_song(info,
                                          '1')
                                      }
                                    })
                                  })
                              } else {
                                Image($r('app.media.like'))
                                  .width('30vp')
                                  .height('30vp')
                                  .fillColor('#D73533')
                                  .onClick(async () => {
                                    this.liked_song.splice(index, 1)
                                    this.isSongListLiked.splice(index, 1)
                                    await this.database.update_unlike(0,
                                      item.song_mid)
                                  })
                              }
                              Image($r('app.media.create'))
                                .alt($r('app.media.pre_load'))
                                .width('20vp')
                                .height('20vp')
                                .fillColor('#D73533')
                                .onClick(() => {
                                  this.pathStack.pushPathByName('AddToPlayListPage', item, null)
                                })
                            }
                          }
                        }.width('100%')
                        .alignItems(VerticalAlign.Center)
                        .justifyContent(FlexAlign.SpaceBetween)
                      }.width('100%')
                      .padding({ left: '10vp', bottom: '10vp', top: '10vp' })
                      .onClick(async () => {
                        let isRefresh: boolean = true;
                        let info: SongInfo =
                          new SongInfo(index, item.song_mid, item.name, item.album_id, '', item.lyric,
                            item.mp3_url, item.singer_name, item.singer_mid)
                        this.pathStack.replacePathByName("PlayPage", isRefresh, false);
                        if (this.isLoadingDetails) {
                          return;
                        } // 防止重复点击
                        this.isLoadingDetails = true; // 开始加载，显示菊花图等
                        let rcpUtil: RCPUtils | null = null; // 声明在 try 外面，确保 finally 中可以访问
                        rcpUtil = new RCPUtils(); // 创建实例
                        // 1. 并行获取播放URL和专辑封面
                        // Promise.all 会等待所有Promise都完成后再继续，或者任何一个Promise失败则立即失败
                        await Promise.all([
                          rcpUtil.getPlaySongUrl(item.song_mid),
                          rcpUtil.getPlayAlbumUrl(item.album_id),
                          rcpUtil.getPlaySongLyric(item.song_mid)
                        ]).then((value: [string, string, string]) => {
                          info.mp3_url = value[0];
                          info.cover_img_url = value[1];
                          info.lyric = value[2];
                          // 3. 数据准备完毕，设置给播放管理器并跳转
                          this.playerManager.playSelected(info); // 假设 playerManager 会处理 item 的更新
                          this.pathStack.pushPathByName("PlayPage", null, false);
                        });
                      })
                    }, (item: SongItem) => JSON.stringify(item))
                }.width('100%')
                .height('100%')
                .divider({ strokeWidth: '1vp', color: 'gray' })
              } else {
                LoadingProgress()
                  .width('100vp')
                  .height('100vp')
                  .color('#D73533')
              }

            }.tabBar(SubTabBarStyle.of('歌曲' + this.liked_song.length)
              .indicator({
                color: '#D73533'
              })
              .labelStyle({ selectedColor: '#D73533' }))

            TabContent() {
              if (this.playerManager.cur_play_song.liked_singer.length > 0) {
                List() {
                  ForEach(this.playerManager.cur_play_song.liked_singer, (item: SingerItem) => {
                    ListItem() {
                      Row() {
                        Image(item.pic)
                          .alt($r('app.media.pre_load'))
                          .width('60vp')
                          .height('60vp')
                          .borderRadius('30vp')
                        Text(item.name)
                          .margin({ left: '20vp' })
                      }.width('100%')
                      .padding({ left: '20vp', top: '10vp', bottom: '10vp' })
                      .justifyContent(FlexAlign.Start)
                    }.onClick(async () => {
                      this.playerManager.cur_singer_item.name = item.name;
                      this.playerManager.cur_singer_item.mid = item.singer_mid;
                      this.playerManager.cur_singer_item.pic_url = item.pic;
                      this.pathStack.pushPathByName('SingerPage', null, false);
                    })
                  }, (item: SingerItem) => JSON.stringify(item))
                }.width('100%')
                .height('100%')
                .divider({ strokeWidth: '1vp', color: 'gray' })
              } else {
                Text('你还没有收藏任何歌手')
              }
            }.tabBar(SubTabBarStyle.of('歌手' + this.playerManager.cur_play_song.liked_singer.length)
              .indicator({
                color: '#D73533'
              })
              .labelStyle({ selectedColor: '#D73533' }))

            TabContent() {
              if (this.playerManager.cur_play_song.liked_album.length > 0) {
                List() {
                  ForEach(this.playerManager.cur_play_song.liked_album, (item: AlbumItem) => {
                    ListItem() {
                      Row() {
                        Row() {
                          Column() {
                            Text(item.name)
                            Text(item.time)
                              .fontColor('gray')
                          }.margin({ left: '10vp' })
                          .alignItems(HorizontalAlign.Start)
                        }

                        Image($r("app.media.arrow_right"))
                          .width('20vp')
                          .height('20vp')
                      }
                      .onClick(async () => {
                        this.playerManager.cur_album_item.mid = item.album_mid;
                        this.playerManager.cur_album_item.name = item.name;
                        this.playerManager.cur_album_item.desc = item.desc;
                        this.playerManager.cur_album_item.time = item.time;
                        this.pathStack.pushPathByName('AlbumPage', null, false);
                      })
                      .width('100%')
                      .padding({
                        left: '10vp',
                        right: '10vp',
                        top: '10vp',
                        bottom: '10vp'
                      })
                      .alignItems(VerticalAlign.Center)
                      .justifyContent(FlexAlign.SpaceBetween)
                    }
                  }, (item: AlbumItem) => JSON.stringify(item))
                }.width('100%')
                .height('100%')
                .divider({ strokeWidth: '1vp', color: 'gray' })
              } else {
                Text('你还没有收藏任何专辑')
              }
            }.tabBar(SubTabBarStyle.of('专辑' + this.playerManager.cur_play_song.liked_album.length)
              .indicator({
                color: '#D73533'
              })
              .labelStyle({ selectedColor: '#D73533' }))

            TabContent() {
              if (this.playerManager.liked_playlist.length > 0) {
                List() {
                  ForEach(this.playerManager.liked_playlist, (item: PlayListItem) => {
                    ListItem() {
                      Row() {
                        Row() {
                          Image(item.pic_url)
                            .alt($r('app.media.pre_load'))
                            .width('60vp')
                            .height('60vp')
                          Column() {
                            Text(item.name)
                              .margin({ bottom: '5vp' })
                            Text(item.creator_name)
                              .fontColor('gray')
                          }.margin({ left: '10vp' })
                          .alignItems(HorizontalAlign.Start)
                        }

                        Image($r("app.media.arrow_right"))
                          .width('20vp')
                          .height('20vp')
                      }
                      .width('100%')
                      .padding({
                        left: '10vp',
                        right: '10vp',
                        top: '10vp',
                        bottom: '10vp'
                      })
                      .alignItems(VerticalAlign.Center)
                      .justifyContent(FlexAlign.SpaceBetween)
                    }.onClick(async () => {
                      this.playerManager.cur_playlist_item.id = item.play_mid;
                      this.playerManager.cur_playlist_item.picurl = item.pic_url;
                      this.playerManager.cur_playlist_item.name = item.name;
                      this.playerManager.cur_playlist_item.listening_num = item.listen_num;
                      this.playerManager.cur_playlist_item.creator_name = item.creator_name;
                      this.playerManager.cur_playlist_item.headpic = item.head_pic;
                      this.playerManager.cur_playlist_item.desc = item.desc;
                      this.pathStack.pushPathByName('PlayDetailPage', null, false)
                    })
                  }, (item: PlayListItem) => JSON.stringify(item))
                }.width('100%')
                .height('100%')
                .divider({ strokeWidth: '1vp', color: 'gray' })
              } else {
                Text('你还没有收藏任何专辑')
              }
            }.tabBar(SubTabBarStyle.of('歌单' + this.playerManager.liked_playlist.length)
              .indicator({
                color: '#D73533'
              })
              .labelStyle({ selectedColor: '#D73533' }))

          }.width('100%')
          .height('100%')
          .onChange(async (index: number) => {
            this.isLoading = true;
            this.isSongListLiked = [];
            if (index === 0) {
              for (let i = 0; i < this.liked_song.length; i++) {
                await this.database.query_song_mid(this.liked_song[i].song_mid)
                  .then((val) => {
                    let res: SongItem;
                    if (val.length > 0) {
                      res = val[0];
                      this.isSongListLiked.push(res.liked === '1' ? true : false);
                    } else {
                      this.isSongListLiked.push(false)
                    }
                    if (i === val.length - 1) {
                      this.isLoading = false;
                      this.isGoingToPage = false;
                      this.index = 0;
                    }
                  })
              }
            } else if (index === 1) {
              for (let i = 0; i < this.playerManager.cur_play_song.liked_singer.length; i++) {
                await this.database.query_singer_mid(this.playerManager.cur_play_song.liked_singer[i].singer_mid)
                  .then((val) => {
                    let res: SingerItem;
                    if (val.length > 0) {
                      res = val[0];
                      this.isSongListLiked.push(res.liked === '1' ? true : false);
                    } else {
                      this.isSongListLiked.push(false)
                    }
                    if (i === val.length - 1) {
                      this.isLoading = false;
                      this.isGoingToPage = false;
                      this.index = 0;
                    }
                  })
              }
            } else if (index === 2) {
              for (let i = 0; i < this.playerManager.cur_play_song.liked_album.length; i++) {
                await this.database.query_album_mid(this.playerManager.cur_play_song.liked_album[i].album_mid)
                  .then((val) => {
                    let res: AlbumItem;
                    if (val.length > 0) {
                      res = val[0];
                      this.isSongListLiked.push(res.liked === '1' ? true : false);
                    } else {
                      this.isSongListLiked.push(false)
                    }
                    if (i === val.length - 1) {
                      this.isLoading = false;
                      this.isGoingToPage = false;
                      this.index = 0;
                    }
                  })
              }
            } else {
              for (let i = 0; i < this.playerManager.liked_playlist.length; i++) {
                await this.database.query_playlist_mid(this.playerManager.liked_playlist[i].play_mid)
                  .then((val) => {
                    let res: PlayListItem;
                    if (val.length > 0) {
                      res = val[0];
                      this.isSongListLiked.push(res.liked === '1' ? true : false);
                    } else {
                      this.isSongListLiked.push(false)
                    }
                    if (i === val.length - 1) {
                      this.isLoading = false;
                      this.isGoingToPage = false;
                      this.index = 0;
                    }
                  })
              }
            }
            promptAction.showToast({
              message: index.toString()
            })
          })
        } else {
          LoadingProgress()
            .width('100vp')
            .height('100vp')
            .color('#D73533')
        }

      }.width('100%')
      .height('100%')
    }.width('100%')
    .height('100%')
    .onShown(async () => {
      await Promise.all([
        this.database.query_song_recent(),
        this.database.query_singer_liked(),
        this.database.query_album_liked(),
        this.database.query_playlist_liked()
      ]).then((value: [SongItem[], SingerItem[], AlbumItem[], PlayListItem[]]) => {
        this.liked_song = value[0];
        this.playerManager.cur_play_song.liked_singer = value[1];
        this.playerManager.cur_play_song.liked_album = value[2];
        this.playerManager.liked_playlist = value[3];
        this.isLoadingDetails = false;
      });
      for (let i = 0; i < this.liked_song.length; i++) {
        await this.database.query_song_mid(this.liked_song[i].song_mid)
          .then((val) => {
            let res: SongItem;
            if (val.length > 0) {
              res = val[0];
              this.isSongListLiked.push(res.liked === '1' ? true : false);
            } else {
              this.isSongListLiked.push(false)
            }
            if (i === val.length - 1) {
              this.isLoading = false;
              this.isGoingToPage = false;
              this.index = 0;
            }
          })
      }
    })
  }
}