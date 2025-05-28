@Entry({ storage: LocalStorage.getShared() })
@Component
struct Index {
  @LocalStorageLink('pathStack') pathStack: NavPathStack = new NavPathStack();

  build() {
    Navigation(this.pathStack) {
    }
    .onAppear(() => {
      this.pathStack.pushPathByName('StartPage', null, false)
    })
    .hideNavBar(true)
  }
}