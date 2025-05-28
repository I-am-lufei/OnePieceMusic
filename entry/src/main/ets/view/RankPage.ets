import { avPlayerManager } from "../common/avPlayerManager"
import { RankList, song } from "../viewModel/RankList"

@Builder
export function RankPageBuilder() {
  RankPage()
}

@Component
struct RankPage {
  @Builder
  Rank(rank_list: RankList) {
    Row() {
      Column({ space: '5vp' }) {
        Text(rank_list.topTitle)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        List() {
          ForEach(rank_list.songList, (item: song, index: number) => {
            ListItem() {
              Row() {
                Text((index + 1).toString() + '.')
                Text(item.song_name + ' - ' + item.singer_name)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .maxLines(1)
              }
              .margin({ bottom: '5vp' })
            }
          })
        }
      }
      .width('60%')
      .height('100vp')
      .alignItems(HorizontalAlign.Start)

      Image(rank_list.picUrl)
        .alt($r('app.media.pre_load'))
        .width('40%')
        .height('100vp')
        .objectFit(ImageFit.ScaleDown)
    }
    .width('100%')
    .padding({ left: '20vp' })
    .backgroundColor('white')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  // @Builder
  // title() {
  //   Text('QQ音乐排行榜')
  //     .fontSize(22)
  //     .fontWeight(FontWeight.Bold)
  // }

  @LocalStorageLink('playerManager') playerManager: avPlayerManager = new avPlayerManager();

  build() {
    NavDestination() {
      List() {
        ForEach(this.playerManager.cur_play_song.RankList, (item: RankList) => {
          ListItem() {
            this.Rank(item)
          }.width('100%')
          .margin({ bottom: '10vp' })
        }, (item: RankList) => JSON.stringify(item))
      }
      .width('100%')
      .height('100%')
    }
    .height('100%')
    .backgroundColor('#F3F5F7')
    .hideTitleBar(true)
  }
}
