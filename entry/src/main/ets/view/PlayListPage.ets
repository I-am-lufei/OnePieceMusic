import { avPlayerManager } from "../common/avPlayerManager";
import { RCPUtils } from "../common/RCPUtils";
import PlayList from "../viewModel/PlayList";
import { promptAction } from "@kit.ArkUI";
import DataBase, { PlayListItem, SongItem } from "../common/Database";

export class Item {
  index: number = 0;
  isPlayLiked: boolean = false;
  isSongListLiked: boolean[] = [];
  isLoading: boolean = true
}


@Builder
export function PlayListPageBuilder() {
  PlayListPage()
}

@Component
struct PlayListPage {
  @State isGoingToPlay: boolean = false;
  @LocalStorageLink('database') database: DataBase = new DataBase();
  @LocalStorageLink('playerManager') playerManager: avPlayerManager = new avPlayerManager();
  @LocalStorageLink('pathStack') pathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Grid() {
        ForEach(this.playerManager.cur_play_song.playList, (item: PlayList, index: number) => {
          GridItem() {
            Column({ space: '5vp' }) {
              Image(item.picurl)
                .alt($r('app.media.pre_load'))
                .width('100%')
                .height('100vp')
                .onClick(() => {
                  this.playerManager.cur_playlist_item = item;
                  this.pathStack.pushPathByName('PlayDetailPage', null, false)
                })
              Text(item.name)
                .textAlign(TextAlign.Center)
              Text(item.creator_name)
                .textAlign(TextAlign.Center)
                .fontSize(16)
                .fontColor('gray')
            }.width('100%')
            .justifyContent(FlexAlign.Start)
          }
          .width('100%') // GridItem 宽度默认会适应Grid的列宽
          .padding($r('sys.float.corner_radius_level5'))
        }, (item: PlayList) => JSON.stringify(item))
      }
      .columnsTemplate('1fr 1fr')
      .width('100%')
    }
  }
}