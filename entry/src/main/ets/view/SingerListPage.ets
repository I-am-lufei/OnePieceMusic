import { avPlayerManager } from "../common/avPlayerManager";
import { RCPUtils } from "../common/RCPUtils";
import PlayList from "../viewModel/PlayList";
import { promptAction } from "@kit.ArkUI";
import Singer from "../viewModel/Singer";
import rcp from "@hms.collaboration.rcp";
import DataBase, { SingerItem, SongItem } from "../common/Database";


interface item {
  id: number;
  name: string;
}


@Builder
export function SingerListPageBuilder() {
  SingerListPage()
}

@Component
struct SingerListPage {
  @State isLoading: boolean = false;
  @State type_id: string[] = ['-100', '-100', '-100', '-100']
  @LocalStorageLink('database') database: DataBase = new DataBase();
  @LocalStorageLink('playerManager') playerManager: avPlayerManager = new avPlayerManager();
  @LocalStorageLink('pathStack') pathStack: NavPathStack = new NavPathStack();
  area_list: item[] = [{ "id": -100, "name": "全部" }, { "id": 200, "name": "内地" }, { "id": 2, "name": "港台" },
    { "id": 5, "name": "欧美" }, { "id": 4, "name": "日本" }, { "id": 3, "name": "韩国" }, { "id": 6, "name": "其他" }];
  index_list: item[] = [
    { "id": -100, "name": "热门" },
    { "id": 1, "name": "A" },
    { "id": 2, "name": "B" },
    { "id": 3, "name": "C" },
    { "id": 4, "name": "D" },
    { "id": 5, "name": "E" },
    { "id": 6, "name": "F" },
    { "id": 7, "name": "G" },
    { "id": 8, "name": "H" },
    { "id": 9, "name": "I" },
    { "id": 10, "name": "J" },
    { "id": 11, "name": "K" },
    { "id": 12, "name": "L" },
    { "id": 13, "name": "M" },
    { "id": 14, "name": "N" },
    { "id": 15, "name": "O" },
    { "id": 16, "name": "P" },
    { "id": 17, "name": "Q" },
    { "id": 18, "name": "R" },
    { "id": 19, "name": "S" },
    { "id": 20, "name": "T" },
    { "id": 21, "name": "U" },
    { "id": 22, "name": "V" },
    { "id": 23, "name": "W" },
    { "id": 24, "name": "X" },
    { "id": 25, "name": "Y" },
    { "id": 26, "name": "Z" },
    { "id": 27, "name": "#" }
  ];
  genre_list: item[] = [
    { "id": -100, "name": "全部" },
    { "id": 1, "name": "流行" },
    { "id": 6, "name": "嘻哈" },
    { "id": 2, "name": "摇滚" },
    { "id": 4, "name": "电子" },
    { "id": 3, "name": "民谣" },
    { "id": 8, "name": "R&B" },
    { "id": 10, "name": "民歌" },
    { "id": 9, "name": "轻音乐" },
    { "id": 5, "name": "爵士" },
    { "id": 14, "name": "古典" },
    { "id": 25, "name": "乡村" },
    { "id": 20, "name": "蓝调" }
  ];
  sex_list: item[] =
    [{ "id": -100, "name": "全部" }, { "id": 0, "name": "男" }, { "id": 1, "name": "女" }, { "id": 2, "name": "组合" }];
  total: Array<item[]> = [this.area_list, this.genre_list, this.index_list, this.sex_list];
  type: string[] = ['地区', '类型', '姓氏首字母', '性别'];
  @State tag_color: Array<string[]> = [];

  async aboutToAppear(): Promise<void> {
    for (let index = 0; index < this.total.length; index++) {
      let str: string[] = [];
      for (let j = 0; j < this.total[index].length; j++) {
        str.push('black');
      }
      this.tag_color.push(str);
    }
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          ForEach(this.total, (i: item[], index: number) => {
            Row() {
              Text(this.type[index] + ':')
                .padding({ bottom: '10vp' })
                .height('100%')
              List() {
                ForEach(i, (j: item, jindex: number) => {
                  ListItem() {
                    Text(j.name)
                      .fontColor(this.tag_color[index][jindex])
                  }.onClick(async () => {
                    promptAction.showToast({
                      message: j.id.toString()
                    })
                    this.isLoading = true;
                    this.type_id[index] = j.id.toString();
                    let rcpUtil: RCPUtils = new RCPUtils();
                    await rcpUtil.getSingerList(this.type_id[0], this.type_id[1], this.type_id[2], this.type_id[3])
                      .then((value) => {
                        rcpUtil.destroySession();
                        this.playerManager.cur_play_song.singerList = value;
                        this.isLoading = false;
                      });
                  })
                  .margin({ right: '10vp' })
                })
              }
              .height('100%')
              .scrollBar(BarState.Off)
              .listDirection(Axis.Horizontal)
            }
            .width('100%')
            .height('30vp')
            .margin({ bottom: '10vp' })
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
          }, (item: item[]) => JSON.stringify(item))
          if (this.isLoading) {
            LoadingProgress()
              .color('#D73533')
              .width('50vp')
              .height('50vp')
              .layoutWeight(1)
          } else {
            Grid() {
              ForEach(this.playerManager.cur_play_song.singerList, (item: Singer, index: number) => {
                GridItem() {
                  Column({ space: '5vp' }) {
                    Image(item.pic_url)
                      .alt($r('app.media.pre_load'))
                      .width('100%')
                      .height('100vp')
                      .onClick(() => {
                        this.playerManager.cur_singer_item = item;
                        this.pathStack.pushPathByName('SingerPage', null, false);
                      })
                    Text(item.name)
                      .textAlign(TextAlign.Center)
                  }.width('100%')
                  .justifyContent(FlexAlign.Start)
                }
                .width('100%') // GridItem 宽度默认会适应Grid的列宽
                .padding($r('sys.float.corner_radius_level5'))
              }, (item: Singer) => JSON.stringify(item))
            }
            .scrollBar(BarState.Off)
            .columnsTemplate('1fr 1fr')
            .width('100%')
          }
        }
        .width('100%')
        .height('100%')
      }.width('100%')
      .height('100%')

      // Grid() {
      //   ForEach(this.playerManager.cur_play_song.playList, (item: PlayList, index: number) => {
      //     GridItem() {
      //       Column({ space: '5vp' }) {
      //         Image(item.picurl)
      //           .alt($r('app.media.startIcon'))
      //           .width('100%')
      //           .height('100vp')
      //           .onClick(async () => {
      //             promptAction.showToast({
      //               message: "click"
      //             })
      //             let rcpUtil: RCPUtils = new RCPUtils();
      //             await rcpUtil.getPlayDetail(item.id!).then((value: PlayList) => {
      //               this.playerManager.cur_play_song.playList[index].headpic = value.headpic;
      //               this.playerManager.cur_play_song.playList[index].desc = value.desc;
      //               this.playerManager.cur_play_song.playList[index].song_list = value.song_list;
      //             });
      //             this.pathStack.pushPathByName('PlayDetailPage', index, false);
      //           })
      //         Text(item.name)
      //           .textAlign(TextAlign.Center)
      //         Text(item.creator_name)
      //           .textAlign(TextAlign.Center)
      //           .fontSize(16)
      //           .fontColor('gray')
      //       }.width('100%')
      //       .justifyContent(FlexAlign.Start)
      //     }
      //     .width('100%') // GridItem 宽度默认会适应Grid的列宽
      //     .padding($r('sys.float.corner_radius_level5'))
      //   }, (item: PlayList) => JSON.stringify(item))
      // }
      // .columnsTemplate('1fr 1fr')
      // .width('100%')
    }.width('100%')
    .onShown(() => {
      for (let index = 0; index < this.total.length; index++) {
        let str: string[] = [];
        for (let j = 0; j < this.total[index].length; j++) {
          str.push('black');
        }
        this.tag_color.push(str);
      }
    })
  }
}