import { promptAction } from "@kit.ArkUI";
import { avPlayerManager } from "../common/avPlayerManager";
import { RCPUtils } from "../common/RCPUtils";
import SongInfo from "../viewModel/SongInfo";
import { faceDetector } from "@kit.CoreVisionKit";
import { item } from "../viewModel/CategoryList";

@Builder
export function searchResultPageBuilder() {
  searchResultPage();
}

@Component
struct searchResultPage {
  @State isLoading: boolean = false; // 用于显示加载指示
  @State isShow: boolean = false;
  @LocalStorageLink('pathStack') pathStack: NavPathStack = new NavPathStack();
  @LocalStorageLink('playerManager') playerManager: avPlayerManager = new avPlayerManager();

  @Builder
  Tags() {
    Grid() {
      ForEach(this.playerManager.search_tags_list, (item: string) => {
        GridItem() {
          Button(item)
            .backgroundColor('gray')
            .onClick(() => {
              promptAction.showToast({
                message: item
              })
            })
        }
      }, (item: string) => item)
    }
    .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
    .width('100%')
  }

  build() {
    NavDestination() {
      Column() {
        Search({ placeholder: '搜索你想找的音乐', value: this.playerManager.cur_play_song.keyword })
          .defaultFocus(true)
          .enableKeyboardOnFocus(true)
          .searchButton('搜索', { fontColor: '#D73533' })
          .searchIcon({
            src: $r('sys.media.ohos_ic_public_search_filled')
          })
          .onChange((val) => {
            this.playerManager.cur_play_song.keyword = val;
          })
          .cancelButton({
            style: CancelButtonStyle.CONSTANT,
            icon: {
              src: $r('sys.media.ohos_ic_public_cancel_filled')
            }
          })
          .onSubmit(async (value) => {
            this.isShow = true;
            this.isLoading = true;
            this.playerManager.cur_play_song.keyword = value;
            this.playerManager.search_tags_list.push(value);
            let rcpUtil: RCPUtils = new RCPUtils();
            await rcpUtil.getSearchResult(value).then((list: SongInfo[]) => {
              this.playerManager.cur_play_song.search_list = list;
              this.isLoading = false;
              rcpUtil.destroySession();
            });
          })
        if (this.isShow) {
          if (this.isLoading) {
            LoadingProgress()
              .color('#D73533')
              .width('50vp')
              .height('50vp')
              .layoutWeight(1)
          } else {
            List() {
              ForEach(this.playerManager.cur_play_song.search_list, (item: SongInfo, index: number) => {
                ListItem() {
                  Row() {
                    Row() {
                      Text(item.name)
                      Text('-')
                      Text(item.singer)
                    }
                  }
                  .width('100%')
                  .padding({
                    top: '10vp',
                    bottom: '10vp',
                    left: '10vp',
                    right: '10vp'
                  })
                  .onClick(async () => {
                    let isRefresh: boolean = true;
                    this.playerManager.cur_song_item = item;
                    this.pathStack.replacePathByName("PlayPage", isRefresh, false);
                  })
                  .justifyContent(FlexAlign.SpaceBetween)
                }
              }, (item: SongInfo) => JSON.stringify(item))
            }
            .width('100%')
            .height('52%')
            .divider({
              strokeWidth: '1vp',
              color: 'gray',
              startMargin: '10vp',
              endMargin: '20vp'
            })
          }
          Text('加载更多相关歌曲')
            .fontColor('#D73533')
            .onClick(async () => {
              this.isLoading = true;
              let rcpUtil: RCPUtils = new RCPUtils();
              this.playerManager.cur_play_song.search_page++;
              this.playerManager.cur_play_song.search_limit =
                this.playerManager.cur_play_song.search_page * this.playerManager.cur_play_song.search_limit;
              await rcpUtil.getSearchResult(this.playerManager.cur_play_song.keyword,
                this.playerManager.cur_play_song.search_page, this.playerManager.cur_play_song.search_limit)
                .then((value: SongInfo[]) => {
                  // this.playerManager.cur_play_song.search_list = value;
                  for (let index = 0; index < value.length; index++) {
                    this.playerManager.cur_play_song.search_list.push(value[index])
                  }
                  this.isLoading = false;
                  rcpUtil.destroySession();
                });
            })
        }
      }
    }
    .height('100%')
    .hideTitleBar(true)
    .onShown(() => {
      this.playerManager.cur_play_song.keyword = '';
    })
  }
}