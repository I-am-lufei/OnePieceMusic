export class item {
  id: string = '';
  name: string = '';

  constructor(id: string, name: string) {
    this.id = id;
    this.name = name;
  }
}

export default class CategoryList {
  name: string = '';
  tags: item[] = [];

  constructor(name: string, tags: item[]) {
    this.name = name;
    this.tags = tags;
  }
}