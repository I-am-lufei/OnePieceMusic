import { avPlayerManager } from "../common/avPlayerManager";
import { RCPUtils } from "../common/RCPUtils";
import SongInfo from "../viewModel/SongInfo";
import { promptAction } from "@kit.ArkUI";
import DataBase, { AlbumItem, SongItem } from "../common/Database";
import Album from "../viewModel/Album";

@Builder
export function AlbumPageBuilder() {
  AlbumPage()
}

@Component
struct AlbumPage {
  @LocalStorageLink('database') database: DataBase = new DataBase();
  @LocalStorageLink('playerManager') playerManager: avPlayerManager = new avPlayerManager();
  @LocalStorageLink('pathStack') pathStack: NavPathStack = new NavPathStack();
  @State isLoading: boolean = true;
  @State isLoadingDetails: boolean = false; // 用于显示加载指示
  @State isAlbumLiked: boolean = false;
  @State isPop: boolean = false;
  @State isSongListLiked: boolean[] = [];

  async aboutToAppear(): Promise<void> {

  }

  build() {
    NavDestination() {
      if (this.isLoading) {
        LoadingProgress()
          .color('#D73533')
          .width('50vp')
          .height('50vp')
          .layoutWeight(1)
      } else {
        Column() {
          Row() {
            Image(this.playerManager.cur_album_item.cover_url)
              .width('30%')
              .height('200vp')
              .alt($r('app.media.pre_load'))
              .objectFit(ImageFit.ScaleDown)
            Column() {
              Text(this.playerManager.cur_album_item.name)
                .width('100%')
                .height('25%')
              if (!(this.playerManager.cur_singer_item.name === '')) {
                Row() {
                  Image(this.playerManager.cur_singer_item.pic_url)
                    .width('20vp')
                    .height('20vp')
                    .alt($r('app.media.pre_load'))
                  Text(this.playerManager.cur_singer_item.name)
                }
                .width('100%')
                .height('25%')
              }

              Text(this.playerManager.cur_album_item.desc)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(1)
                .width('100%')
                .height('50%')
            }
            .width('70%')
            .height('100%')
            .padding({ left: '10vp' })
          }.width('100%')
          .height('20%')

          Row() {
            if (!this.isAlbumLiked) {
              Image($r('app.media.like'))
                .width('30vp')
                .height('30vp')
                .onClick(async () => {
                  this.isAlbumLiked = true;
                  await this.database.query_album_mid(this.playerManager.cur_album_item.mid)
                    .then(async (val) => {
                      if (val.length > 0) {
                        await this.database.update_like(2,
                          this.playerManager.cur_album_item.mid)
                      } else {
                        await this.database.insert_album(this.playerManager.cur_album_item,
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
                  this.isAlbumLiked = false;
                  await this.database.update_unlike(2,
                    this.playerManager.cur_album_item.mid)
                })
            }
          }.width('100%')
          .justifyContent(FlexAlign.Center)

          List() {
            ForEach(this.playerManager.cur_album_item.song_list,
              (item: SongInfo, index: number) => {
                ListItem() {
                  Row() {
                    Row() {
                      Text((item.id + 1).toString())
                      Column({ space: '5vp' }) {
                        Text(item.name)
                        Text(item.singer)
                          .fontColor('gray')
                      }.margin({ left: '10vp' })
                      .alignItems(HorizontalAlign.Start)
                    }
                    .onClick(async () => {
                      let isRefresh: boolean = true;
                      this.playerManager.cur_song_item = item;
                      this.pathStack.replacePathByName("PlayPage", isRefresh, false);
                    })

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
                                this.isLoading = true;
                                this.isSongListLiked = [];
                                let rcpUtil: RCPUtils = new RCPUtils();
                                await Promise.all([rcpUtil.getAlbumInfo(this.playerManager.cur_album_item.mid),
                                  rcpUtil.getPlayAlbumUrl(this.playerManager.cur_album_item.mid)
                                ])
                                  .then(async (value: [Album, string]) => {
                                    rcpUtil.destroySession();
                                    this.playerManager.cur_album_item.song_list =
                                      value[0].song_list;
                                    this.playerManager.cur_album_item.desc = value[0].desc;
                                    this.playerManager.cur_album_item.cover_url = value[1];
                                    await this.database.query_album_mid(this.playerManager.cur_album_item.mid)
                                      .then((val) => {
                                        let res: AlbumItem;
                                        if (val.length > 0) {
                                          res = val[0];
                                          this.isAlbumLiked = res.liked === '1' ? true : false;
                                        } else {
                                          this.isAlbumLiked = false;
                                        }
                                      })
                                    for (let i = 0; i < this.playerManager.cur_album_item.song_list.length; i++) {
                                      await this.database.query_song_mid(this.playerManager.cur_album_item.song_list[i].song_mid)
                                        .then((val) => {
                                          let res: SongItem;
                                          if (val.length > 0) {
                                            res = val[0];
                                            this.isSongListLiked.push(res.liked === '1' ? true : false);
                                          } else {
                                            this.isSongListLiked.push(false)
                                          }
                                          if (i === this.playerManager.cur_album_item.song_list.length - 1) {
                                            this.isLoading = false;
                                          }
                                        })
                                    }
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
              }, (item: SongInfo) => JSON.stringify(item))
          }.width('100%')
          .height('80%')
          .divider({ strokeWidth: '1vp', color: 'gray' })
        }.width('100%')
        .height('100%')
      }
    }.width('100%')
    .onShown(async () => {
      if (!this.isPop) {
        this.isLoading = true;
        this.isSongListLiked = [];
        let rcpUtil: RCPUtils = new RCPUtils();
        await Promise.all([rcpUtil.getAlbumInfo(this.playerManager.cur_album_item.mid),
          rcpUtil.getPlayAlbumUrl(this.playerManager.cur_album_item.mid)
        ])
          .then(async (value: [Album, string]) => {
            this.playerManager.cur_album_item.song_list =
              value[0].song_list;
            this.playerManager.cur_album_item.desc = value[0].desc;
            this.playerManager.cur_album_item.cover_url = value[1];
            await this.database.query_album_mid(this.playerManager.cur_album_item.mid)
              .then((val) => {
                let res: AlbumItem;
                if (val.length > 0) {
                  res = val[0];
                  this.isAlbumLiked = res.liked === '1' ? true : false;
                } else {
                  this.isAlbumLiked = false;
                }
              })
            for (let i = 0; i < this.playerManager.cur_album_item.song_list.length; i++) {
              await this.database.query_song_mid(this.playerManager.cur_album_item.song_list[i].song_mid)
                .then((val) => {
                  let res: SongItem;
                  if (val.length > 0) {
                    res = val[0];
                    this.isSongListLiked.push(res.liked === '1' ? true : false);
                  } else {
                    this.isSongListLiked.push(false)
                  }
                  if (i === this.playerManager.cur_album_item.song_list.length - 1) {
                    this.isLoading = false;
                  }
                })
            }
          })
      }
    })
  }
}