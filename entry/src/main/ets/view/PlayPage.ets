import { avPlayerManager } from '../common/avPlayerManager'
import { LyricLine } from '../common/LyricLine'
import { promptAction } from '@kit.ArkUI';
import { LrcParser } from '../common/LyricParser';
import DataBase, { SongItem } from '../common/Database';
import { RecentPlayList } from '../view/Layout';
import { RCPUtils } from '../common/RCPUtils';

@Builder
export function PlayPageBuilder() {
  PlayPage()
}

@Component
export struct PlayPage {
  min: string = '0:00';
  max: string = '0:00';
  parser: LrcParser = new LrcParser();
  mode_icon_list: Resource[] = [$r("app.media.circle1"), $r('app.media.list_circle'), $r("app.media.random_circle")];
  @State play_mode: number = 0;
  @State isShowLyric: boolean = false;
  @State isShow: boolean = false;
  @State isLoading: boolean = false;
  @State isSongLike: boolean = false;
  @State isRefresh: boolean = false;
  @LocalStorageLink('database') database: DataBase = new DataBase();
  @LocalStorageLink('playerManager') playerManager: avPlayerManager = new avPlayerManager();
  @LocalStorageLink('pathStack') pathStack: NavPathStack = new NavPathStack();
  Controller: CustomDialogController | null = new CustomDialogController({
    builder: RecentPlayList(),
    alignment: DialogAlignment.Bottom,
    customStyle: false
  });

  // async aboutToAppear(): Promise<void> {
  // }

  formatTime(time: number): string {
    let min: string = '0';
    let sec: string = '0';
    if (time / 60000 < 10) {
      min = min + Math.floor(time / 60000);
    } else {
      min = Math.floor(time / 60000).toString();
    }
    if ((time / 1000) % 60 < 10) {
      sec = sec + Math.floor((time / 1000) % 60);
    } else {
      sec = (Math.floor(time / 1000) % 60).toString();
    }
    return min + ":" + sec;
  }

  build() {
    NavDestination() {
      if (!this.playerManager.isShowPlayPage) {
        LoadingProgress()
          .color('#D73533')
          .width('50vp')
          .height('50vp')
          .layoutWeight(1)
      } else {
        Column({ space: '50vp' }) {
          Column() {
            if (!this.isShowLyric) {
              Image(this.playerManager.cur_song_item.cover_img_url)
                .alt($r('app.media.pre_load'))// 使用alt，在网络图片加载成功前使用占位图
                .width('300vp')
                .height('300vp')
                .borderRadius(20)// 图片圆角
                .shadow({
                  radius: 8,
                  color: '#00000033',
                  offsetX: 1,
                  offsetY: 1
                })// 浅一点的阴影，因为背景有白色
                .margin({ top: '20vp' })
                .onClick(() => {
                  this.isShowLyric = true;
                })
            }
            Row() {
              Column({ space: '10vp' }) {
                Column() {
                  Text(this.playerManager.cur_song_item.name)
                    .fontSize('24fp')
                    .fontColor('white')
                  Text(this.playerManager.cur_song_item.singer)
                    .fontColor('white')
                    .onClick(() => {

                    })
                }.onClick(() => {
                  this.isShowLyric = !this.isShowLyric;
                })
                .margin({ top: this.isShowLyric ? '10vp' : '10vp' })

                if (this.isShowLyric) {
                  if (this.playerManager.lyrics.length > 0) {
                    List({ space: '20vp', scroller: this.playerManager.scroller }) {
                      ForEach(this.playerManager.lyrics, (item: LyricLine, index?: number) => {
                        ListItem() {
                          Text(item.text)
                            .fontColor('white')
                            .fontSize(index === this.playerManager.currentLyricIndex ? '24fp' : "18fp")
                        }
                        .gesture(
                          TapGesture({ count: 2 })
                            .onAction((event: GestureEvent) => {
                              this.playerManager.scroller.scrollToIndex(index, true, ScrollAlign.CENTER);
                              this.playerManager.ToLyric(item.text)
                            })
                        )
                        .width('100%')
                      }, (item: LyricLine) => JSON.stringify(item))
                    }
                    .height('90%')
                    .margin({ top: '10vp' })
                    .scrollBar(BarState.Off)
                  } else {
                    Text('歌词加载出错')
                      .fontColor('white')
                  }
                } else {
                  if (this.playerManager.lyrics.length > 0) {
                    Text(this.playerManager.lyrics[this.playerManager.currentLyricIndex].text)
                      .fontColor('white')
                      .margin({ top: '10vp' })
                  } else {
                    Text('歌词加载出错')
                      .fontColor('white')
                  }
                  Row() {
                    if (!this.isSongLike) {
                      Image($r('app.media.like'))
                        .alt($r('app.media.pre_load'))
                        .width('30vp')
                        .height('30vp')
                        .fillColor('white')
                        .onClick(async () => {
                          this.isSongLike = true;
                          await this.database.query_song_mid(this.playerManager.cur_song_item.song_mid)
                            .then(async (val) => {
                              if (val.length > 0) {
                                await this.database.update_like(0, this.playerManager.cur_song_item.song_mid)
                              } else {
                                await this.database.insert_song(this.playerManager.cur_song_item, '1')
                              }
                            })
                        })
                    } else {
                      Image($r('app.media.like'))
                        .alt($r('app.media.pre_load'))
                        .width('30vp')
                        .height('30vp')
                        .fillColor('#e89a09')
                        .onClick(async () => {
                          this.isSongLike = false;
                          await this.database.update_unlike(0, this.playerManager.cur_song_item.song_mid)
                        })
                    }
                    Image($r('app.media.create'))
                      .alt($r('app.media.pre_load'))
                      .width('30vp')
                      .height('30vp')
                      .fillColor('white')
                      .onClick(() => {
                        this.pathStack.pushPath({
                          name: 'AddToPlayListPage', param: this.playerManager.cur_song_item, onPop: (() => {
                            promptAction.showToast({
                              message: 'pop'
                            })
                          })
                        })
                      })
                  }.width('100%')
                  .margin({ top: '10vp' })
                  .justifyContent(FlexAlign.SpaceAround)
                }
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center)
            }
            .width('90%')
            .justifyContent(FlexAlign.Center)
          }.width('100%')
          .height('60%')

          Row() {
            Text(this.formatTime(this.playerManager.currentTimeMs))
              .fontColor('white')
            Slider({
              min: 0,
              max: this.playerManager.total_time,
              value: this.playerManager.currentTimeMs,
              step: 1,
              style: SliderStyle.InSet
            })
              .width('70%')
              .blockColor('black')
              .selectedColor('white')
              .trackColor('gray')
              .onChange(async (value: number) => {
                this.playerManager.currentTimeMs = value;
                this.playerManager.SongSeek(this.playerManager.currentTimeMs);
              })
            Text(this.formatTime(this.playerManager.total_time))
              .fontColor('white')
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)

          Row({ space: '20vp' }) {
            Image(this.mode_icon_list[this.playerManager.play_mode])
              .fillColor('white')
              .width('30vp')
              .height('30vp')
              .onClick(() => {
                this.playerManager.play_mode = (this.playerManager.play_mode + 1) % 3;
              })
            Image($r("app.media.pre"))
              .fillColor('white')
              .width('30vp')
              .height('30vp')
              .onClick(async () => {
                this.playerManager.isShowPlayPage = false;
                await this.playerManager.playPre().then(() => {
                  this.playerManager.isShowPlayPage = true;
                });
              })
            Image((!this.playerManager.isPlaying || this.playerManager.isCompleted) ? $r("app.media.pause") :
            $r("app.media.playing"))
              .fillColor('white')
              .width('50vp')
              .height('50vp')
              .onClick(async () => {
                if (!this.playerManager.isPlaying) {
                  this.playerManager.songPlay();
                } else {
                  this.playerManager.songPause();
                }
              })
            Image($r("app.media.next"))
              .fillColor('white')
              .width('30vp')
              .height('30vp')
              .onClick(async () => {
                this.playerManager.isShowPlayPage = false;
                await this.playerManager.playNext().then(() => {
                  this.playerManager.isShowPlayPage = true;
                });
              })
            Image($r("app.media.list"))
              .fillColor('white')
              .width('30vp')
              .height('30vp')
              .onClick(() => {
                this.Controller?.open();
              })
          }
          .width('90%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width('100%')
        .height('100%')
        .sweepGradient({
          center: [0.5, 0.5], // 渐变中心点
          start: 0, // 起始角度 (0度代表3点钟方向)
          end: 360, // 结束角度 (360度完成一个整圆)
          colors: [
            ['#E74C3C', 0.0], // 红色 (起始)
            ['#D73533', 0.33], // 淡粉色
            ['#FFFFFF', 0.66], // 白色
            ['#E74C3C', 1.0]// 回到红色 (使闭合处平滑)
          ],
          //  rotation: 45, // 可选：整体旋转渐变图案的角度
        })
        .alignItems(HorizontalAlign.Center) // 使 Stack 内的子组件在交叉轴（此处为垂直）和主轴（此处为水平）居中
        .justifyContent(FlexAlign.Center) // 确保子项在主轴居中（对于Stack，此属性主要影响子项对齐方式）
      }
    }
    .height('100%')
    .hideTitleBar(true)
    .onShown(async () => {
      if (this.isRefresh) {
        this.isSongLike = false;
        this.playerManager.isShowPlayPage = false; // 开始加载，显示菊花图等
        let rcpUtil: RCPUtils = new RCPUtils();
        // 创建实例
        // 1. 并行获取播放URL和专辑封面
        // Promise.all 会等待所有Promise都完成后再继续，或者任何一个Promise失败则立即失败
        this.playerManager.cur_song_item.cover_img_url = this.playerManager.cur_album_item.cover_url;
        await Promise.all([
          rcpUtil.getPlaySongUrl(this.playerManager.cur_song_item.song_mid),
          rcpUtil.getPlaySongLyric(this.playerManager.cur_song_item.song_mid),
          this.database.query_song_mid(this.playerManager.cur_song_item.song_mid)
        ]).then(async (value: [string, string, SongItem[]]) => {
          this.playerManager.cur_song_item.mp3_url = value[0];
          this.playerManager.cur_song_item.lyric = value[1];
          if (value[2].length > 0) {
            let res: SongItem;
            res = value[2][0];
            this.isSongLike = res.liked === '1' ? true : false;
          }
          await rcpUtil.getPlayAlbumUrl(this.playerManager.cur_song_item.album_id).then(async (val) => {
            this.playerManager.cur_song_item.cover_img_url = val;
            // 3. 数据准备完毕，设置给播放管理器并跳转
            await this.playerManager.playSelected(this.playerManager.cur_song_item).then(() => {
              this.playerManager.isShowPlayPage = true;
              rcpUtil.destroySession();
            })
          })
        });
      }
      // await this.database.query_song_mid(this.playerManager.cur_song_item.song_mid).then((val) => {
      //   if (val.length > 0) {
      //     let res: SongItem;
      //     res = val[0];
      //     this.isSongLike = res.liked === '1' ? true : false;
      //   }
      // })
    })
    .onReady((ctx) => {
      this.isRefresh = ctx.pathInfo.param as boolean;
    })
  }
}