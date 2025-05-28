import { avPlayerManager } from "../common/avPlayerManager";
import { RCPUtils } from "../common/RCPUtils";
import SongInfo from "../viewModel/SongInfo";
import { promptAction } from "@kit.ArkUI";
import Album from "../viewModel/Album";
import DataBase, { AlbumItem, SingerItem, SongItem } from "../common/Database";
import Singer from "../viewModel/Singer";
import rcp from "@hms.collaboration.rcp";


@Builder
export function SingerPageBuilder() {
  SingerPage()
}

@Component
struct SingerPage {
  @LocalStorageLink('database') database: DataBase = new DataBase();
  @LocalStorageLink('playerManager') playerManager: avPlayerManager = new avPlayerManager();
  @LocalStorageLink('pathStack') pathStack: NavPathStack = new NavPathStack();
  @State isLoading: boolean = true;
  @State isLoadingDetails: boolean = false; // 用于显示加载指示
  @State isPop: boolean = false;
  @State isSingerLiked: boolean = false;
  @State isSongListLiked: boolean[] = [];

  async aboutToAppear(): Promise<void> {
  }

  @State isLoadMore: boolean = false;

  build() {
    NavDestination() {
      if (!this.isLoading) {
        Column() {
          Image(this.playerManager.cur_singer_item.pic_url)
            .alt($r('app.media.pre_load'))
            .width('100%')
            .height('40%')
          Text(this.playerManager.cur_singer_item.name)
          if (!this.isSingerLiked) {
            Row() {
              Image($r('app.media.like'))
                .width('30vp')
                .height('30vp')
                .onClick(async () => {
                  this.isSingerLiked = true;
                  await this.database.query_singer_mid(this.playerManager.cur_singer_item.mid)
                    .then(async (val) => {
                      if (val.length > 0) {
                        await this.database.update_like(1,
                          this.playerManager.cur_singer_item.mid)
                      } else {
                        await this.database.insert_singer(this.playerManager.cur_singer_item,
                          '1')
                      }
                    })
                })
            }.width('100%')
            .justifyContent(FlexAlign.Center)
          } else {
            Row() {
              Image($r('app.media.like'))
                .width('30vp')
                .height('30vp')
                .fillColor('#D73533')
                .onClick(async () => {
                  this.isSingerLiked = false;
                  await this.database.update_unlike(1,
                    this.playerManager.cur_singer_item.mid)
                })
            }.width('100%')
            .justifyContent(FlexAlign.Center)
          }

          Tabs() {
            TabContent() {
              Column() {
                if (!this.isLoadMore) {
                  List() {
                    ForEach(this.playerManager.cur_singer_item.hot_list,
                      (item: SongInfo, index: number) => {
                        ListItem() {
                          Row() {
                            Row() {
                              Text((index + 1).toString())
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
                                          await this.database.insert_song(item,
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
                                      this.isSongListLiked[index] = false;
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
                                    this.pathStack.pushPath({
                                      name: 'AddToPlayListPage', param: item, onPop: (async (info) => {
                                        this.isPop = true;
                                        this.isLoading = false;
                                        this.isSongListLiked = [];
                                        let rcpUtil: RCPUtils = new RCPUtils();
                                        await Promise.all([rcpUtil.getSingerHotList(this.playerManager.cur_singer_item.mid),
                                          rcpUtil.getSingerAlbumList(this.playerManager.cur_singer_item.mid)
                                        ])
                                          .then(async (value: [Singer, Singer]) => {
                                            this.playerManager.cur_singer_item.hot_list = value[0].hot_list;
                                            this.playerManager.cur_singer_item.album = value[1].album;
                                            await this.database.query_singer_mid(this.playerManager.cur_singer_item.mid)
                                              .then((val) => {
                                                let res: SingerItem;
                                                if (val.length > 0) {
                                                  res = val[0];
                                                  this.isSingerLiked = res.liked === '1' ? true : false;
                                                } else {
                                                  this.isSingerLiked = false;
                                                }
                                              })
                                            for (let i = 0; i < this.playerManager.cur_singer_item.hot_list.length;
                                              i++) {
                                              await this.database.query_song_mid(this.playerManager.cur_singer_item.hot_list[i].song_mid)
                                                .then((val) => {
                                                  let res: SongItem;
                                                  if (val.length > 0) {
                                                    res = val[0];
                                                    this.isSongListLiked.push(res.liked === '1' ? true : false);
                                                  } else {
                                                    this.isSongListLiked.push(false)
                                                  }
                                                  if (i === this.playerManager.cur_singer_item.hot_list.length - 1) {
                                                    this.isLoading = false;
                                                  }
                                                })
                                            }
                                          })
                                        promptAction.showToast({
                                          message: 'popout',
                                          duration: 1000
                                        })
                                      })
                                    })
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
                          this.playerManager.cur_song_item = item;
                          this.pathStack.pushPathByName("PlayPage", isRefresh, false);
                        })
                      }, (item: SongInfo) => JSON.stringify(item))
                  }
                  .width('100%')
                  .height('250vp')
                  .divider({ strokeWidth: '1vp', color: 'gray' })
                  .scrollBar(BarState.Off)

                  Text('点击加载更多')
                    .onClick(async () => {
                      this.isLoadMore = true;
                      // 模拟新数据加载。
                      let rcpUtil: RCPUtils = new RCPUtils();
                      await rcpUtil.getSingerHotList(this.playerManager.cur_singer_item.mid,
                        (Math.floor(this.playerManager.cur_singer_item.hot_list.length / 5) + 1).toString(), '5')
                        .then((val) => {
                          for (let i = 0; i < val.hot_list.length; i++) {
                            this.playerManager.cur_singer_item.hot_list.push(val.hot_list[i]);
                          }
                          this.isLoadMore = false;
                        })
                    })
                } else {
                  LoadingProgress().height(32).width(48).color('#D73533')
                  Text("加载中")
                }
              }
            }.tabBar(SubTabBarStyle.of('热门歌曲' + this.playerManager.cur_singer_item.hot_list.length)
              .indicator({
                color: '#D73533'
              })
              .labelStyle({ selectedColor: '#D73533' })
            )
            .width('100%')
            .height('100%')

            TabContent() {
              List() {
                ForEach(this.playerManager.cur_singer_item.album, (item: Album, index: number) => {
                  ListItem() {
                    Row() {
                      Row() {
                        Text((index + 1).toString())
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
                    }.width('100%')
                    .padding({ left: '10vp', right: '10vp' })
                    .alignItems(VerticalAlign.Center)
                    .justifyContent(FlexAlign.SpaceBetween)
                  }.width('100%')
                  .onClick(() => {
                    this.playerManager.cur_album_item = item;
                    this.pathStack.pushPathByName('AlbumPage', null, false);
                  })
                }, (item: Album) => JSON.stringify(item))
              }.width('100%')
              .height('100%')
              .divider({ strokeWidth: '1vp', color: 'gray' })
            }.tabBar(SubTabBarStyle.of('专辑' + this.playerManager.cur_singer_item.album.length)
              .indicator({
                color: '#D73533'
              })
              .labelStyle({ selectedColor: '#D73533' })
            )
            .width('100%')
            .height('100%')
          }.width('100%')
          .height('50%')
        }.width('100%')
        .height('100%')
      } else {
        LoadingProgress()
          .width('100vp')
          .height('100vp')
          .color('#D73533')
      }
    }.width('100%')
    .height('100%')
    .onShown(async () => {
      if (!this.isPop) {
        let rcpUtil: RCPUtils = new RCPUtils();
        await Promise.all([rcpUtil.getSingerHotList(this.playerManager.cur_singer_item.mid),
          rcpUtil.getSingerAlbumList(this.playerManager.cur_singer_item.mid)
        ])
          .then(async (value: [Singer, Singer]) => {
            this.playerManager.cur_singer_item.hot_list = value[0].hot_list;
            this.playerManager.cur_singer_item.album = value[1].album;
            await this.database.query_singer_mid(this.playerManager.cur_singer_item.mid)
              .then((val) => {
                let res: SingerItem;
                if (val.length > 0) {
                  res = val[0];
                  this.isSingerLiked = res.liked === '1' ? true : false;
                } else {
                  this.isSingerLiked = false;
                }
              })
            for (let i = 0; i < this.playerManager.cur_singer_item.hot_list.length; i++) {
              await this.database.query_song_mid(this.playerManager.cur_singer_item.hot_list[i].song_mid)
                .then((val) => {
                  let res: SongItem;
                  if (val.length > 0) {
                    res = val[0];
                    this.isSongListLiked.push(res.liked === '1' ? true : false);
                  } else {
                    this.isSongListLiked.push(false)
                  }
                  if (i === this.playerManager.cur_singer_item.hot_list.length - 1) {
                    this.isLoading = false;
                  }
                })
            }
          })
        promptAction.showToast({
          message: 'singerpageshow'
        })
      }
    })
  }
}