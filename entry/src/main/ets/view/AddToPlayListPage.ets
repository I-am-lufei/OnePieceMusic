import { avPlayerManager } from "../common/avPlayerManager";
import DataBase, { PlayListItem } from "../common/Database";
import { promptAction } from "@kit.ArkUI";
import { song } from "../viewModel/RankList";
import SongInfo from "../viewModel/SongInfo";
import { RCPUtils } from "../common/RCPUtils";

@Builder
export function AddToPlayListPageBuilder() {
  AddToPlayListPage()
}

@Component
struct AddToPlayListPage {
  @LocalStorageLink('database') database: DataBase = new DataBase();
  @LocalStorageLink('playerManager') playerManager: avPlayerManager = new avPlayerManager();
  @LocalStorageLink('pathStack') pathStack: NavPathStack = new NavPathStack();
  @State isLoading: boolean = true;
  @State song: SongInfo = new SongInfo(0, '', '', '', '', '', '', '', '');
  playlist: PlayListItem[] = [];

  async aboutToAppear(): Promise<void> {
    let i_like: PlayListItem = {
      id: 0,
      play_mid: '',
      name: '',
      desc: '',
      head_pic: '',
      creator_name: '',
      listen_num: '',
      pic_url: '',
      self_create: '',
      liked: '',
      recently: '',
      recent_play_time: 0
    };
    i_like.name = '我喜欢';
    await this.database.query_playlist_self_create().then((val) => {
      this.playlist = val;
      this.playlist.unshift(i_like!);
      this.isLoading = false;
    })
  }

  build() {
    NavDestination() {
      if (!this.isLoading) {
        List() {
          ForEach(this.playlist, (item: PlayListItem, index: number) => {
            ListItem() {
              Row() {
                if (item.pic_url === '') {
                  Image($r('app.media.pre_load'))
                    .width('50vp')
                    .height('50vp')
                } else {
                  Image(item.pic_url)
                    .width('50vp')
                    .height('50vp')
                }
                Column({ space: '10vp' }) {
                  Text(item.name)
                }
                .margin({ left: '10vp' })
              }
              .justifyContent(FlexAlign.Start)
              .width('100%')
            }
            .width('100%')
            .padding({
              left: '10vp',
              right: '10vp',
              bottom: '10vp',
              top: '10vp'
            })
            .onClick(async () => {
              if (index === 0) {
                await this.database.query_song_mid(this.song.song_mid).then(async (val) => {
                  if (val.length > 0) {
                    if (val[0].liked === '1') {
                      promptAction.showDialog({
                        message: '已经收藏过了！'
                      })
                    } else {
                      await this.database.update_like(0, this.song.song_mid)
                      promptAction.showToast({
                        message: '收藏成功！'
                      })
                      this.pathStack.pop('123')
                    }
                  } else {
                    await this.database.insert_song(this.song, '1')
                    promptAction.showToast({
                      message: '收藏成功！'
                    })
                    this.pathStack.pop('123')
                  }
                })
              } else {
                await this.database.query_song_mid(this.song.song_mid).then(async (val) => {
                  if (val.length > 0) {
                    if (val[0].play_id === item.id!.toString()) {
                      promptAction.showToast({
                        message: '已经存在该歌单中了！'
                      })
                    } else {
                      await this.database.update_playlist('song', this.song.song_mid, item.id!.toString())
                        .then(async () => {
                          let rcpUtil: RCPUtils | null = null; // 声明在 try 外面，确保 finally 中可以访问
                          rcpUtil = new RCPUtils(); // 创建实例
                          await rcpUtil.getPlayAlbumUrl(val[0].album_id).then(async (url) => {
                            await this.database.update_playlist_pic_url(item.play_mid, url).then(() => {
                              promptAction.showToast({
                                message: '收藏成功！'
                              })
                              this.pathStack.pop()
                            })
                          })
                        })
                    }
                  } else {
                    await this.database.insert_song(this.song, '0', '0', item.id!.toString())
                      .then(async () => {
                        let rcpUtil: RCPUtils | null = null; // 声明在 try 外面，确保 finally 中可以访问
                        rcpUtil = new RCPUtils(); // 创建实例
                        await rcpUtil.getPlayAlbumUrl(this.song.album_id).then(async (url) => {
                          await this.database.update_playlist_pic_url(item.play_mid, url).then(() => {
                            promptAction.showToast({
                              message: '收藏成功！'
                            })
                            this.pathStack.pop()
                          })
                        })
                      })
                  }
                })
              }
            })
          }, (item: PlayListItem) => JSON.stringify(item))
        }
        .width('100%')
        .divider({ strokeWidth: '1vp', color: 'gray' })
      } else {
        LoadingProgress()
          .width('100vp')
          .height('100vp')
          .color('#D73533')
      }
    }.width('100%')
    .height('100%')
    .onReady((ctx) => {
      this.song = ctx.pathInfo.param as SongInfo;
    })
  }
}