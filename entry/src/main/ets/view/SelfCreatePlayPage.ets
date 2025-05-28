import { avPlayerManager } from "../common/avPlayerManager";
import { RCPUtils } from "../common/RCPUtils";
import SongInfo from "../viewModel/SongInfo";
import { promptAction } from "@kit.ArkUI";
import DataBase, { PlayListItem, SongItem } from "../common/Database";
import PlayList from "../viewModel/PlayList";


@Builder
export function SelfCreatePlayPageBuilder() {
  SelfCreatePlayPage()
}

@Component
struct SelfCreatePlayPage {
  @State isSongListLiked: boolean[] = [];
  @State isLoading: boolean = true
  @State isLoadingDetails: boolean = false; // 用于显示加载指示
  @LocalStorageLink('database') database: DataBase = new DataBase();
  @LocalStorageLink('playerManager') playerManager: avPlayerManager = new avPlayerManager();
  @LocalStorageLink('pathStack') pathStack: NavPathStack = new NavPathStack();

  async aboutToAppear(): Promise<void> {
    // this.isLoading = true;
    // this.isSongListLiked = [];
    // await this.database.query_playlist_mid(this.playerManager.cur_playlist_item.id)
    //   .then(async (value: PlayListItem[]) => {
    //     this.playerManager.cur_playlist_item.desc = value[0].desc;
    //     await this.database.query_song_playlist(value[0].id!.toString())
    //       .then((val: SongItem[]) => {
    //         if (val.length > 0) {
    //           let song_list: SongInfo[] = [];
    //           let limit: number = Math.min(val.length, 10);
    //           for (let index = 0; index < limit; index++) {
    //             song_list.push(new SongInfo(index, val[index].song_mid, val[index].name, val[index].album_id, '',
    //               val[index].lyric, val[index].mp3_url, val[index].singer_name, val[index].singer_mid))
    //           }
    //           this.playerManager.cur_playlist_item.song_list = song_list;
    //
    //         } else {
    //
    //         }
    //       })
    //     for (let i = 0; i < this.playerManager.cur_playlist_item.song_list.length; i++) {
    //       await this.database.query_song_mid(this.playerManager.cur_playlist_item.song_list[i].song_mid)
    //         .then((val) => {
    //           let res: SongItem;
    //           if (val.length > 0) {
    //             res = val[0];
    //             this.isSongListLiked.push(res.liked === '1' ? true : false);
    //           } else {
    //             this.isSongListLiked.push(false)
    //           }
    //           if (i === this.playerManager.cur_playlist_item.song_list.length - 1) {
    //             this.isLoading = false;
    //           }
    //         })
    //     }
    //   })
  }

  @Builder
  itemEnd(index: number) {
    // 构建尾端滑出组件
    Image($r('app.media.delete_1'))
      .fillColor('#D73533')
      .width('30vp')
      .height('30vp')
      .onClick(() => {
        // this.messages为列表数据源，可根据实际场景构造。点击后从数据源删除指定数据项。
        this.database.update_playlist('song', this.playerManager.cur_playlist_item.song_list[index].song_mid, '0');
        this.playerManager.cur_playlist_item.song_list.splice(index, 1);
      })
  }

  build() {
    NavDestination() {
      if (!this.isLoading) {
        Column() {
          Row() {
            Image(this.playerManager.cur_playlist_item.picurl)
              .width('30%')
              .height('200vp')
              .alt($r('app.media.pre_load'))
              .objectFit(ImageFit.ScaleDown)
            Column() {
              Text(this.playerManager.cur_playlist_item.name)
                .width('100%')
                .height('25%')
              Row() {
                Image(this.playerManager.cur_playlist_item.headpic)
                  .width('20vp')
                  .height('20vp')
                  .alt($r('app.media.startIcon'))
                Text(this.playerManager.cur_playlist_item.creator_name)
              }
              .width('100%')
              .height('25%')

              Text(this.playerManager.cur_playlist_item.desc)
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


          List() {
            ForEach(this.playerManager.cur_playlist_item.song_list, (item: SongInfo, index: number) => {
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
                          // this.pathStack.pushPathByName('AddToPlayListPage', item)
                          this.pathStack.pushPath({
                            name: 'AddToPlayListPage', param: item, onPop: (async () => {
                              this.isLoading = true;
                              this.isSongListLiked = [];
                              await this.database.query_playlist_mid(this.playerManager.cur_playlist_item.id)
                                .then(async (value: PlayListItem[]) => {
                                  this.playerManager.cur_playlist_item.desc = value[0].desc;
                                  await this.database.query_song_playlist(value[0].id!.toString())
                                    .then(async (val: SongItem[]) => {
                                      if (val.length > 0) {
                                        let song_list: SongInfo[] = [];
                                        let limit: number = Math.min(val.length, 10);
                                        for (let index = 0; index < limit; index++) {
                                          song_list.push(new SongInfo(index, val[index].song_mid, val[index].name,
                                            val[index].album_id, '',
                                            val[index].lyric, val[index].mp3_url, val[index].singer_name,
                                            val[index].singer_mid))
                                        }
                                        this.playerManager.cur_playlist_item.song_list = song_list;
                                      } else {

                                      }
                                      for (let i = 0; i < this.playerManager.cur_playlist_item.song_list.length; i++) {
                                        await this.database.query_song_mid(this.playerManager.cur_playlist_item.song_list[i].song_mid)
                                          .then((val) => {
                                            let res: SongItem;
                                            if (val.length > 0) {
                                              res = val[0];
                                              this.isSongListLiked.push(res.liked === '1' ? true : false);
                                            } else {
                                              this.isSongListLiked.push(false)
                                            }
                                            if (i === this.playerManager.cur_playlist_item.song_list.length - 1) {
                                              this.isLoading = false;
                                            }
                                          })
                                      }
                                    })

                                })
                            })
                          })
                        })
                    }
                  }
                }
                .width('100%')
                .alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .width('100%')
              .padding({ left: '10vp', bottom: '10vp', top: '10vp' })
              .swipeAction({
                end: {
                  // index为该ListItem在List中的索引值。
                  builder: () => {
                    this.itemEnd(index)
                  },
                }
              })
              .onClick(async () => {
                let isRefresh: boolean = true;
                this.playerManager.cur_song_item = item;
                this.pathStack.replacePathByName("PlayPage", isRefresh, false);
              })
            })
          }.width('100%')
          .height('80%')
          .divider({ strokeWidth: '1vp', color: 'gray' })
        }.width('100%')
        .height('100%')
      } else {
        if (this.playerManager.cur_playlist_item.song_list.length > 0) {
          LoadingProgress()
            .width('100vp')
            .height('100vp')
            .color('#D73533')
        } else {
          Text('你还没有收藏任何歌曲')
        }
      }
    }.width('100%')
    .onShown(async () => {
      this.isLoading = true;
      this.isSongListLiked = [];
      await this.database.query_playlist_mid(this.playerManager.cur_playlist_item.id)
        .then(async (value: PlayListItem[]) => {
          this.playerManager.cur_playlist_item.desc = value[0].desc;
          await this.database.query_song_playlist(value[0].id!.toString())
            .then(async (val: SongItem[]) => {
              if (val.length > 0) {
                let song_list: SongInfo[] = [];
                let limit: number = Math.min(val.length, 10);
                for (let index = 0; index < limit; index++) {
                  song_list.push(new SongInfo(index, val[index].song_mid, val[index].name, val[index].album_id, '',
                    val[index].lyric, val[index].mp3_url, val[index].singer_name, val[index].singer_mid))
                }
                this.playerManager.cur_playlist_item.song_list = song_list;
                for (let i = 0; i < this.playerManager.cur_playlist_item.song_list.length; i++) {
                  await this.database.query_song_mid(this.playerManager.cur_playlist_item.song_list[i].song_mid)
                    .then((val) => {
                      let res: SongItem;
                      if (val.length > 0) {
                        res = val[0];
                        this.isSongListLiked.push(res.liked === '1' ? true : false);
                      } else {
                        this.isSongListLiked.push(false)
                      }
                      if (i === this.playerManager.cur_playlist_item.song_list.length - 1) {
                        this.isLoading = false;
                      }
                    })
                }
              } else {
              }
            })

        })
    })
  }
}