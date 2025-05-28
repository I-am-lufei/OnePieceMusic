import { avPlayerManager } from "../common/avPlayerManager";
import { RCPUtils } from "../common/RCPUtils";
import SongInfo from "../viewModel/SongInfo";
import { promptAction } from "@kit.ArkUI";
import DataBase, { PlayListItem, SongItem } from "../common/Database";
import PlayList from "../viewModel/PlayList";


@Builder
export function PlayDetailPageBuilder() {
  PlayDetailPage()
}

@Component
struct PlayDetailPage {
  @State isPlayLiked: boolean = false;
  @State isSongListLiked: boolean[] = [];
  @State isLoading: boolean = true
  @State isLoadingDetails: boolean = false; // 用于显示加载指示
  @LocalStorageLink('database') database: DataBase = new DataBase();
  @LocalStorageLink('playerManager') playerManager: avPlayerManager = new avPlayerManager();
  @LocalStorageLink('pathStack') pathStack: NavPathStack = new NavPathStack();

  // async aboutToAppear(): Promise<void> {
  //
  // }

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
                  .alt($r('app.media.pre_load'))
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

          if (!this.isPlayLiked) {
            Row() {
              Image($r('app.media.like'))
                .width('30vp')
                .height('30vp')
                .onClick(async () => {
                  this.isPlayLiked = true;
                  await this.database.query_playlist_mid(this.playerManager.cur_playlist_item.id)
                    .then(async (val) => {
                      if (val.length > 0) {
                        await this.database.update_like(3,
                          this.playerManager.cur_playlist_item.id)
                      } else {
                        await this.database.insert_playlist(this.playerManager.cur_playlist_item,
                          '0', '1', '0')
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
                  this.isPlayLiked = false;
                  await this.database.update_unlike(3,
                    this.playerManager.cur_playlist_item.id)
                })
            }.width('100%')
            .justifyContent(FlexAlign.Center)
          }

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
                          this.pathStack.pushPath({
                            name: 'AddToPlayListPage', param: item, onPop: async (info) => {
                              promptAction.showToast({
                                message: 'popout'
                              })
                              console.log(info.result.toString())
                              // this.isLoading = true;
                              // this.isSongListLiked = [];
                              // //接收返回的数据
                              // let rcpUtil: RCPUtils = new RCPUtils();
                              // await rcpUtil.getPlayDetail(this.playerManager.cur_playlist_item.id)
                              //   .then(async (value: PlayList) => {
                              //     this.playerManager.cur_playlist_item.headpic = value.headpic;
                              //     this.playerManager.cur_playlist_item.desc = value.desc;
                              //     this.playerManager.cur_playlist_item.song_list = value.song_list;
                              //     await this.database.query_playlist_mid(this.playerManager.cur_playlist_item.id)
                              //       .then((val) => {
                              //         let res: PlayListItem;
                              //         if (val.length > 0) {
                              //           res = val[0];
                              //           this.isPlayLiked = res.liked === '1' ? true : false;
                              //         } else {
                              //           this.isPlayLiked = false;
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
            })
          }.width('100%')
          .height('80%')
          .divider({ strokeWidth: '1vp', color: 'gray' })
        }.width('100%')
        .height('100%')
      } else {
        LoadingProgress()
          .width('100vp')
          .height('100vp')
          .color('#D73533')
      }
    }.width('100%')
    .onShown(async () => {
      promptAction.showToast({
        message: '执行show'
      })
      this.isLoading = true;
      this.isSongListLiked = [];
      let rcpUtil: RCPUtils = new RCPUtils();
      await rcpUtil.getPlayDetail(this.playerManager.cur_playlist_item.id).then(async (value: PlayList) => {
        this.playerManager.cur_playlist_item.headpic = value.headpic;
        this.playerManager.cur_playlist_item.desc = value.desc;
        this.playerManager.cur_playlist_item.song_list = value.song_list;
        await this.database.query_playlist_mid(this.playerManager.cur_playlist_item.id)
          .then((val) => {
            let res: PlayListItem;
            if (val.length > 0) {
              res = val[0];
              this.isPlayLiked = res.liked === '1' ? true : false;
            } else {
              this.isPlayLiked = false;
            }
          })
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
  }
}