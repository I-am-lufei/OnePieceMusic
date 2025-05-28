import { avPlayerManager } from '../common/avPlayerManager';
import DataBase, { PlayListItem } from '../common/Database';
import ItemData from '../viewModel/ItemData';
import PlayList from '../viewModel/PlayList';
import { promptAction } from '@kit.ArkUI';

@CustomDialog
struct CreatePlayList {
  @Link value: string;
  @Link isLoading: boolean;
  controllerTwo?: CustomDialogController;
  controller: TextInputController = new TextInputController();
  @LocalStorageLink('database') database: DataBase = new DataBase();
  @LocalStorageLink('playerManager') playerManager: avPlayerManager = new avPlayerManager();
  chars: string[] = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
    'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
  ];

  generateRandomStr(length: number = 8): string {
    let result = '';
    for (let i = 0; i < length; i++) {
      const randomIndex = Math.floor(Math.random() * this.chars.length);
      result += this.chars[randomIndex];
    }
    return result;
  }

  // 生成时间戳+随机字符串的ID
  generateTimestampId(): string {
    const timestamp = Date.now().toString(36); // 转换为36进制时间戳
    const randomStr = this.generateRandomStr(4); // 4位随机字符串
    return `${timestamp}${randomStr}`;
  }

  build() {
    Column() {
      Text('新建歌单')
        .fontSize(24)
        .height('35%')
      TextInput({ text: "新建歌单1", controller: this.controller })
        .showCounter(true,
          { thresholdPercentage: 20, highlightBorder: true })
        .maxLength(20)
        .onChange((val) => {
          this.value = val;
        })
      //计数器显示效果为用户当前输入字符数/最大字符限制数。最大字符限制数通过maxLength()接口设置。
      //如果用户当前输入字符数达到最大字符限制乘50%（thresholdPercentage）。字符计数器显示。
      //用户设置highlightBorder为false时，配置取消红色边框。不设置此参数时，默认为true。
      Row() {
        Button('取消')
          .onClick(() => {
            if (this.controllerTwo != undefined) {
              this.controllerTwo.close();
            }
          })
          .width('40%')
          .type(ButtonType.Normal)
          .height('50vp')
          .fontColor('white')
          .backgroundColor('#D73533')
        Button('确定')
          .onClick(async () => {
            this.isLoading = true;
            if (this.controllerTwo != undefined) {
              let playlist: PlayList = new PlayList('0', '', this.value, '0', '海贼王');
              playlist.id = this.generateTimestampId();
              playlist.desc = '';
              playlist.headpic =
                'https://ts1.tc.mm.bing.net/th/id/OIP-C.8IGD4BddWPNTOHRZCq3WYAHaHa?w=198&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2';
              //修改完立即同步数据
              await this.database.insert_playlist(playlist, '1');
              await this.database.query_playlist_self_create().then((val) => {
                this.playerManager.self_create_playlist = val;
                this.isLoading = false;
              })
              this.controllerTwo.close();
            }
          })
          .width('40%')
          .type(ButtonType.Normal)
          .height('50vp')
          .fontColor('white')
          .backgroundColor('#D73533')
      }.width('100%')
      .height('30%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .height('200vp')
  }
}

@Component
export default struct MyInfo {
  @State value: string = '';
  @State isChecked: boolean[] = [];
  @State isRadioShow: boolean = false;
  @State buttonChange: boolean = false;
  @State count: number = 0;
  @State @Watch('isShowUpdated') isShow: boolean = true;
  @State isLoading: boolean = true; // 用于显示加载指示
  Controller: CustomDialogController | null = new CustomDialogController({
    builder: CreatePlayList({ value: this.value, isLoading: this.isLoading }),
    alignment: DialogAlignment.Center,
  });
  @LocalStorageLink('database') database: DataBase = new DataBase();
  @LocalStorageLink('playerManager') playerManager: avPlayerManager = new avPlayerManager();
  @LocalStorageLink('pathStack') pathStack: NavPathStack = new NavPathStack();

  async aboutToAppear(): Promise<void> {
    await Promise.all([this.database.query_playlist_self_create(),
      this.database.query_playlist_liked()
    ]).then((val: [PlayListItem[], PlayListItem[]]) => {
      this.playerManager.self_create_playlist = val[0];
      this.playerManager.liked_playlist = val[1];
      this.isLoading = false;
    })
    promptAction.showToast({
      message: 'appear'
    })
  }

  // 转换为万单位的字符串
  convertToWanUnit(playCountStr: string): string {
    // 去除非数字字符（可选，处理含逗号等格式的字符串）
    const cleanNum = playCountStr.replace(/[^0-9]/g, '');
    if (!cleanNum) {
      return "0万";
    } // 空值处理

    const num = parseFloat(cleanNum);
    if (num < 10000) {
      return `${num}`; // 小于1万显示原始值+单位
    }

    // 转换为万单位，保留1位小数
    const wanNum = num / 10000;
    // 四舍五入处理（如需要保留整数可改为Math.round(wanNum)）
    return `${wanNum.toFixed(1)}万`;
  }

  async isShowUpdated() {
    if (this.isShow) {
      this.isLoading = true;
      await Promise.all([this.database.query_playlist_self_create(),
        this.database.query_playlist_liked()
      ]).then((val: [PlayListItem[], PlayListItem[]]) => {
        this.playerManager.self_create_playlist = val[0];
        this.playerManager.liked_playlist = val[1];
        this.isLoading = false;
      })
    }
  }

  @Builder
  itemEnd(index: number) {
    // 构建尾端滑出组件
    Image($r('app.media.delete_1'))
      .fillColor('#D73533')
      .width('30vp')
      .height('30vp')
      .onClick(async () => {
        // this.messages为列表数据源，可根据实际场景构造。点击后从数据源删除指定数据项。
        this.database.query_song_playlist(this.playerManager.self_create_playlist[index].id!.toString()).then((val) => {
          if (val.length > 0) {
            for (let i = 0; i < val.length; i++) {
              this.database.update_playlist('song', val[i].song_mid, '0');
            }
          }
          this.database.update_un_self_create(this.playerManager.self_create_playlist[index].play_mid);
        })
        this.playerManager.self_create_playlist.splice(index, 1);
      })
  }

  @Builder
  itemEnd2(index: number) {
    // 构建尾端滑出组件
    Image($r('app.media.delete_1'))
      .fillColor('#D73533')
      .width('30vp')
      .height('30vp')
      .onClick(async () => {
        // this.messages为列表数据源，可根据实际场景构造。点击后从数据源删除指定数据项。
        this.database.query_song_playlist(this.playerManager.liked_playlist[index].id!.toString()).then((val) => {
          if (val.length > 0) {
            for (let i = 0; i < val.length; i++) {
              this.database.update_playlist('song', val[i].song_mid, '0');
            }
          }
          this.database.update_unlike(3, this.playerManager.liked_playlist[index].play_mid);
        })
        this.playerManager.liked_playlist.splice(index, 1);
      })
  }

  build() {
    NavDestination() {
      Column({ space: '30vp' }) {
        Row() {
          Text('我的')
            .fontWeight(FontWeight.Bold)
            .fontSize('24vp')
          Image('https://ts1.tc.mm.bing.net/th/id/OIP-C.8IGD4BddWPNTOHRZCq3WYAHaHa?w=198&h=211&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2')
            .alt($r('app.media.pre_load'))
            .width('50vp')
            .height('50vp')
        }
        .width('100%')
        .height('10%')
        .padding({ left: '20vp', right: '20vp' })
        .justifyContent(FlexAlign.SpaceBetween)

        Column({ space: '30vp' }) {
          Search({ placeholder: '搜索你想找的音乐' })
            .searchButton('搜索', { fontColor: '#D73533' })
            .searchIcon({
              src: $r('sys.media.ohos_ic_public_search_filled')
            })
            .onFocus(() => {
              this.pathStack.replacePathByName("SearchPage", null, false);
              this.getUIContext().getFocusController().clearFocus()
            })
            .cancelButton({
              style: CancelButtonStyle.CONSTANT,
              icon: {
                src: $r('sys.media.ohos_ic_public_cancel_filled')
              }
            })
          Row({ space: '100vp' }) {
            Column() {
              Image($r('app.media.like'))
                .width('30vp')
                .height('30vp')
                .fillColor('#D73533')
              Text('喜欢')
            }
            .onClick(() => {
              this.pathStack.pushPathByName('LikePage', null, false)
            })

            Column() {
              Image($r('app.media.recently'))
                .width('30vp')
                .height('30vp')
                .fillColor('#D73533')
              Text('最近')
            }
            .onClick(() => {
              this.pathStack.pushPathByName('RecentPage', null, false)
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)

          Column() {
            if (this.isLoading) {
              LoadingProgress()
                .width('100vp')
                .height('100vp')
                .color('#D73533')
            } else {
              Row() {
                Row({ space: '5vp' }) {
                  Row({ space: '5vp' }) {
                    Text('自建歌单')
                      .fontColor(this.isShow ? '#D73533' : 'black')
                    Text(this.playerManager.self_create_playlist.length.toString())
                      .fontColor(this.isShow ? '#D73533' : 'black')
                  }
                  .onClick(() => {
                    this.isShow = true;
                  })

                  Text('|')
                  Row({ space: '5vp' }) {
                    Text('收藏歌单')
                      .fontColor(this.isShow ? 'black' : '#D73533')
                    Text(this.playerManager.liked_playlist.length.toString())
                      .fontColor(this.isShow ? 'black' : '#D73533')
                  }
                  .onClick(() => {
                    this.isShow = false;
                  })
                }

                Row({ space: '15vp' }) {
                  Image($r('app.media.create'))
                    .width('25vp')
                    .height('25vp')
                    .fillColor('#D73533')
                    .onClick(() => {
                      this.Controller?.open();
                    })
                  // Image($r('app.media.together'))
                  //   .width('25vp')
                  //   .height('25vp')
                  //   .fillColor('#D73533')
                  //   .onClick(() => {
                  //     for (let index = 0; index < this.playerManager.self_create_playlist.length; index++) {
                  //       this.isChecked.push(false);
                  //     }
                  //     this.isRadioShow = !this.isRadioShow;
                  //   })
                }
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)

              if (this.isShow) {
                if (this.playerManager.self_create_playlist.length > 0) {
                  List() {
                    ForEach(this.playerManager.self_create_playlist, (item: PlayListItem, index: number) => {
                      ListItem() {
                        Row() {
                          // if (this.isRadioShow) {
                          //   Toggle({ type: ToggleType.Checkbox, isOn: this.isChecked[index] })
                          //     .selectedColor('#D73533')// .onClick(() => {
                          //       //   this.buttonChange = false;
                          //       // })
                          //     .onChange((isOn: boolean) => {
                          //       this.isChecked[index] = isOn;
                          //       promptAction.showToast({
                          //         message: this.count.toString()
                          //       })
                          //       if (!this.buttonChange) {
                          //         if (isOn) {
                          //           this.count++;
                          //         } else {
                          //           this.count--;
                          //         }
                          //       }
                          //     })
                          // }
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
                            Text('共' + this.convertToWanUnit(item.listen_num) + '人在听')
                              .fontColor('gray')
                          }
                          .margin({ left: '10vp' })
                        }
                        .justifyContent(FlexAlign.Start)
                        .width('100%')
                      }
                      .width('100%')
                      .margin({ bottom: '20vp' })
                      .swipeAction({
                        end: {
                          // index为该ListItem在List中的索引值。
                          builder: () => {
                            this.itemEnd(index)
                          },
                        }
                      })
                      .onClick(() => {
                        this.playerManager.cur_playlist_item.id = item.play_mid;
                        this.playerManager.cur_playlist_item.picurl = item.pic_url
                        this.playerManager.cur_playlist_item.name = item.name;
                        this.playerManager.cur_playlist_item.creator_name = item.creator_name;
                        this.playerManager.cur_playlist_item.headpic = item.head_pic;
                        this.playerManager.cur_playlist_item.desc = item.desc;
                        this.playerManager.cur_playlist_item.listening_num = item.listen_num;
                        this.pathStack.pushPathByName('SelfCreatePlayPage', null, false)
                      })
                    }, (item: PlayListItem) => JSON.stringify(item))
                  }
                  .width('100%')
                  .height('50%')
                  .scrollBar(BarState.Off)
                  .margin({ top: '10vp' })
                }
                if (this.isRadioShow) {
                  Row() {
                    if (this.count === this.isChecked.length) {
                      Button('取消全选')
                        .backgroundColor('#D73533')
                        .onClick(() => {
                          this.count = 0;
                          this.buttonChange = true;
                          for (let index = 0; index < this.isChecked.length; index++) {
                            this.isChecked[index] = false;
                          }
                          this.buttonChange = false;
                        })
                        .type(ButtonType.Normal)
                    } else {
                      Button('全选')
                        .backgroundColor('#D73533')
                        .onClick(() => {
                          this.count = this.isChecked.length;
                          this.buttonChange = true;
                          for (let index = 0; index < this.isChecked.length; index++) {
                            this.isChecked[index] = true;
                          }
                          this.buttonChange = false;
                          promptAction.showToast({
                            message: this.count.toString()
                          })
                        })
                        .type(ButtonType.Normal)
                    }
                    Button('删除')
                      .backgroundColor('#D73533')
                      .type(ButtonType.Normal)
                      .onClick(() => {
                        promptAction.showToast({
                          message: '请先选择一个歌单！'
                        })
                      })
                  }.width('100%')
                  .padding({ left: '20vp', right: '20vp' })
                  .justifyContent(FlexAlign.SpaceBetween)
                }
              } else {
                List() {
                  ForEach(this.playerManager.liked_playlist, (item: PlayListItem, index: number) => {
                    ListItem() {
                      Row() {
                        if (item.pic_url === '') {
                          Image($r('app.media.pre_load'))
                            .width('50vp')
                            .height('50vp')
                        } else {
                          Image(item.pic_url)
                            .alt($r('app.media.pre_load'))
                            .width('50vp')
                            .height('50vp')
                        }
                        Column({ space: '10vp' }) {
                          Text(item.name)
                          Text('共' + this.convertToWanUnit(Math.floor(parseInt(item.listen_num)).toString()) +
                            '人在听')
                            .fontColor('gray')
                        }
                        .margin({ left: '10vp' })
                      }
                      .justifyContent(FlexAlign.Start)
                      .width('100%')
                    }
                    .swipeAction({
                      end: {
                        // index为该ListItem在List中的索引值。
                        builder: () => {
                          this.itemEnd2(index)
                        },
                      }
                    })
                    .onClick(() => {
                      this.playerManager.cur_playlist_item.id = item.play_mid;
                      this.playerManager.cur_playlist_item.picurl = item.pic_url
                      this.playerManager.cur_playlist_item.name = item.name;
                      this.playerManager.cur_playlist_item.creator_name = item.creator_name;
                      this.playerManager.cur_playlist_item.headpic = item.head_pic;
                      this.playerManager.cur_playlist_item.desc = item.desc;
                      this.playerManager.cur_playlist_item.listening_num = item.listen_num;
                      this.pathStack.pushPathByName('PlayDetailPage', null, false)
                    })
                    .width('100%')
                    .margin({ bottom: '20vp' })
                  }, (item: PlayListItem) => JSON.stringify(item))
                }
                .width('100%')
                .height('50%')
                .scrollBar(BarState.Off)
                .margin({ top: '10vp' })
              }
            }
          }
          .width('100%')
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .padding({ left: '20vp', right: '20vp' })
    }.hideTitleBar(true)

    // .onShown(async () => {
    //   this.isLoading = true;
    //   await Promise.all([this.database.query_playlist_self_create(),
    //     this.database.query_playlist_liked()
    //   ]).then((val: [PlayListItem[], PlayListItem[]]) => {
    //     this.playerManager.self_create_playlist = val[0];
    //     this.playerManager.liked_playlist = val[1];
    //     this.isLoading = false;
    //   })
    //   promptAction.showToast({
    //     message: 'shown'
    //   })
    // })
  }
}