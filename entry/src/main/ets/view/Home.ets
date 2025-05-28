import { avPlayerManager } from "../common/avPlayerManager";
import { RCPUtils } from "../common/RCPUtils";
import { RankList, song } from "../viewModel/RankList";
import SongInfo from "../viewModel/SongInfo";
import { promptAction } from "@kit.ArkUI";
import { RankDetail, songs } from "../viewModel/RankDetail";

class category {
  id: number;
  img: Resource;
  title: string;

  constructor(id: number, img: Resource, title: string) {
    this.id = id;
    this.img = img;
    this.title = title;
  }
}

class listening_song {
  id: number;
  img: Resource;
  title: string;
  record_name: string;

  constructor(id: number, img: Resource, title: string, record_name: string) {
    this.id = id;
    this.img = img;
    this.title = title;
    this.record_name = record_name;
  }
}


@Component
export default struct Home {
  category_list: category[] = [
    new category(0, $r('app.media.rank'), '排行榜'),
    new category(1, $r('app.media.singer'), '歌手'),
    new category(2, $r('app.media.category_list'), '分类歌单')
  ]
  listening_list: listening_song[] = [
    new listening_song(0, $r('app.media.startIcon'), '黑色毛衣', '周杰伦-十一月的肖邦'),
    new listening_song(1, $r('app.media.startIcon'), '不将就', '李荣浩-上一首情歌（国语精选）'),
    new listening_song(2, $r('app.media.startIcon'), '南山忆', '许嵩-半城烟沙'),
  ]

  @Builder
  Icon_Text(img: Resource, title: string, index: number) {
    Column() {
      Image(img)
        .width('40vp')
        .height('40vp')
        .fillColor('#D73533')
        .margin({ bottom: '10vp' })
      Text(title)
    }
    .onClick(async () => {
      if (index === 0) {
        this.pathStack.pushPathByName('RankPage', null, false)
      }
      if (index === 1) {
        let rcpUtil: RCPUtils = new RCPUtils();
        await rcpUtil.getSingerList().then((value) => {
          this.playerManager.cur_play_song.singerList = value;
          rcpUtil.destroySession();
          this.pathStack.pushPathByName('SingerListPage', null, false)
        });
      }
      if (index === 2) {
        this.pathStack.pushPathByName('CategoryPage', null, false)
      }
    })
  }

  @Builder
  rank_detail(item: RankDetail) {
    Column() {
      Row() {
        Text(item.topTitle)
          .fontSize(20)
      }.width('100%')
      .margin({ bottom: '10vp' })
      .justifyContent(FlexAlign.Start)

      Column() {
        Text(item.listenCount)
          .fontSize(18)
          .fontColor('gray')
      }.width('100%')

      ForEach(item.songList, (item: songs, index: number) => {
        Row({ space: '10vp' }) {
          Text((index + 1).toString())
          Image(item.cover)
            .alt($r('app.media.pre_load'))
            .width('50vp')
            .height('50vp')
          Column() {
            Text(item.song_name)
            Text(item.singer_name)
              .fontColor('gray')
              .fontSize('14fp')
          }.width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .margin({ bottom: '10vp' })
      }, (item: songs) => JSON.stringify(item))
    }.width('100%')
  }

  @Builder
  rank_example(img: Resource, song_name: string, singer_name: string) {
    Row() {
      Row({ space: '15vp' }) {
        // Image(img)
        //   .width('60vp')
        //   .height('60vp')
        Column() {
          Text(song_name)
            .fontSize('18fp')
          Text(singer_name)
            .fontColor('gray')
        }.alignItems(HorizontalAlign.Start)
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  Rank(name: string, num: string, song_list: song[]) {
    Column() {
      Row() {
        Column() {
          Row() {
            Text(name)
              .fontSize('16fp')
            Image($r("app.media.arrow_right"))
              .width('10vp')
              .height('10vp')
          }

          Text('播放量' + num)
            .fontColor('gray')
        }

        Image($r('app.media.startIcon'))
          .width('30vp')
          .height('30vp')
          .borderRadius('15vp')
      }.width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      ForEach(song_list, (item: song, index: number) => {
        Row() {
          Text((index + 1).toString())
          this.rank_example($r('app.media.startIcon'), item.song_name, item.singer_name)
        }
        .alignItems(VerticalAlign.Center)
      }, (item: listening_song) => JSON.stringify(item))
    }
    .width('60%')
  }

  @State isLoadingDetails: boolean = false; // 用于显示加载指示
  @State swiper_index: number = 0;
  private swiperController: SwiperController = new SwiperController();
  @LocalStorageLink('pathStack') pathStack: NavPathStack = new NavPathStack();
  @LocalStorageLink('playerManager') playerManager: avPlayerManager = new avPlayerManager();

  build() {
    Column({ space: '20vp' }) {
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
        .margin({ top: '30vp' })
      Column() {
        Swiper(this.swiperController) {
          ForEach(this.playerManager.cur_play_song.songList, (item: SongInfo) => {
            Image(item.cover_img_url)
              .alt($r('app.media.pre_load'))
              .height('30%')
              .width('100%')
              .objectFit(ImageFit.Cover)
              .onClick(() => {
                let isRefresh: boolean = true;
                this.playerManager.cur_song_item = item;
                this.pathStack.replacePathByName("PlayPage", isRefresh, false);
              })
          }, (item: SongInfo) => JSON.stringify(item))
        }
        .onChange((index) => {
          this.swiper_index = index;
        })
        .autoPlay(true)
        .loop(true)
        .indicator( // 设置圆点导航点样式
          new DotIndicator()
            .itemWidth(8)
            .itemHeight(8)
            .selectedItemWidth(8)
            .selectedItemHeight(8)
            .color(Color.White)
            .selectedColor('#D73533'))

        Text(this.playerManager.cur_play_song.songList[this.swiper_index].name + '-' +
        this.playerManager.cur_play_song.songList[this.swiper_index].singer)
          .fontColor('#D73533')
          .fontWeight(FontWeight.Bold)
      }.width('100%')

      Row({ space: '100vp' }) {
        ForEach(this.category_list, (item: category, index: number) => {
          this.Icon_Text(item.img, item.title, index)
        }, (item: category) => JSON.stringify(item))
      }.width('100%')
      .height('10%')
      .justifyContent(FlexAlign.Center)

      this.rank_detail(this.playerManager.Rank_Detail)
    }
    .width('100%')
    .height('100%')
    .padding({ left: '10vp', right: '10vp' })
  }
}