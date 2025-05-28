@Builder
export function StartPageBuilder() {
  StartPage()
}


@Component
struct StartPage {
  build() {
    Column() {
      Image($r('app.media.player_cover'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Fill)
    }
    .width('100%')
    .height('100%')
  }
}