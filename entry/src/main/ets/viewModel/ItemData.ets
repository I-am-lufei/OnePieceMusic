export default class ItemData {
  id: number;
  singer: ResourceStr;
  num: number;
  img: Resource;

  constructor(id: number, singer: ResourceStr, num: number, img: Resource) {
    this.id = id;
    this.singer = singer;
    this.num = num;
    this.img = img;
  }
}