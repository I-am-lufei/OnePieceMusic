import { avPlayerManager } from "../common/avPlayerManager";
import { RCPUtils } from "../common/RCPUtils";
import CategoryList, { item } from "../viewModel/CategoryList";
import PlayList from "../viewModel/PlayList";

@Builder
export function CategoryPageBuilder() {
  CategoryPage()
}

@Component
struct CategoryPage {
  @LocalStorageLink('playerManager') playerManager: avPlayerManager = new avPlayerManager();
  @LocalStorageLink('pathStack') pathStack: NavPathStack = new NavPathStack();

  // async aboutToAppear(): Promise<void> {
  //   // let rcpUtil: RCPUtils = new RCPUtils();
  //   // await rcpUtil.getCategoryList().then((value: CategoryList[]) => {
  //   //   this.playerManager.cur_play_song.CategoryList = value;
  //   // });
  // }

  build() {
    NavDestination() {
      Column() {
        List() {
          ForEach(this.playerManager.cur_play_song.CategoryList, (item: CategoryList) => {
            ListItem() {
              Column() {
                Text(item.name)
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                Grid() {
                  ForEach(item.tags, (tags: item) => {
                    GridItem() {
                      Text(tags.name)
                        .fontSize(16)
                        .fontColor('white')
                        .backgroundColor('gray')
                        .width('80%')
                        .borderRadius($r('sys.float.corner_radius_level1'))
                    }
                    .width('100%') // GridItem 宽度默认会适应Grid的列宽
                    .padding($r('sys.float.corner_radius_level5'))
                    .onClick(async () => {
                      let rcpUtil: RCPUtils = new RCPUtils();
                      await rcpUtil.getPlayList(tags.id).then((value: PlayList[]) => {
                        this.playerManager.cur_play_song.playList = value;
                        rcpUtil.destroySession();
                        this.pathStack.pushPathByName('PlayListPage', null, false);
                      });
                    })
                  }, (tags: item) => JSON.stringify(tags))
                }
                .columnsTemplate('1fr 1fr 1fr 1fr')
                .width('100%')
                .backgroundColor(0xFAEEE0)
              }

            }.width('100%')
          }, (item: CategoryList) => JSON.stringify(item))
        }.width('100%')
      }.width('100%')
      .height('100%')
    }.width('100%')
    .height('100%')
  }
}