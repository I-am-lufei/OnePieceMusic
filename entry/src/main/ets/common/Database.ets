import { relationalStore, ValuesBucket } from "@kit.ArkData";
import { promptAction } from "@kit.ArkUI";
import Album from "../viewModel/Album";
import PlayList from "../viewModel/PlayList";
import Singer from "../viewModel/Singer";
import SongInfo from "../viewModel/SongInfo";
import { systemDateTime } from "@kit.BasicServicesKit";


// ValuesBucket 数据库支持的类型
export interface SingerItem extends ValuesBucket {
  id: number | null // 新增时设置 id 为空值 null，用于自增 id
  name: string
  singer_mid: string
  pic: string
  liked: string
  recently: string
  recent_play_time: number
}

export interface SongItem extends ValuesBucket {
  id: number | null // 新增时设置 id 为空值 null，用于自增 id
  song_mid: string
  name: string
  mp3_url: string
  lyric: string
  album_id: string
  singer_mid: string
  singer_name: string
  play_id: string
  liked: string
  recently: string
  recent_play_time: number
}

// ValuesBucket 数据库支持的类型
export interface AlbumItem extends ValuesBucket {
  id: number | null // 新增时设置 id 为空值 null，用于自增 id
  album_mid: string
  name: string
  desc: string
  time: string
  liked: string
  recently: string
  recent_play_time: number
}

// ValuesBucket 数据库支持的类型
export interface PlayListItem extends ValuesBucket {
  id: number | null // 新增时设置 id 为空值 null，用于自增 id
  play_mid: string
  name: string
  desc: string
  head_pic: string
  creator_name: string
  listen_num: string
  pic_url: string
  self_create: string
  liked: string
  recently: string
  recent_play_time: number
}


export default class DataBase {
  // 操作数据库的管理对象
  store: relationalStore.RdbStore | null = null;
  // 表名
  // SQL 语法：（SQL语法的数据类型关键词不一样，可通过AI生成SQL语句）
  // 解释说明：
  //   CREATE TABLE IF NOT EXISTS     如果表不存在才创建新的表
  //   INTEGER -> number              INTEGER 整数型   FLOAT 浮点数
  //   PRIMARY KEY                    主键(唯一标识)
  //   AUTOINCREMENT                  自增
  //   TEXT -> string                 字符串型
  //   NOT NULL                       不允许空
  create_song: string = `CREATE TABLE IF NOT EXISTS song (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        song_mid TEXT NOT NULL,
        name TEXT NOT NULL,
        mp3_url TEXT NOT NULL,
        lyric TEXT NOT NULL,
        album_id TEXT NOT NULL,
        singer_mid TEXT NOT NULL,
        singer_name TEXT NOT NULL,
        play_id TEXT NOT NULL,
        liked TEXT NOT NULL,
        recently TEXT NOT NULL,
        recent_play_time INTEGER NOT NULL
      )`
  create_singer: string = `CREATE TABLE IF NOT EXISTS singer (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        singer_mid TEXT NOT NULL,
        pic TEXT NOT NULL,
        liked TEXT NOT NULL,
        recently TEXT NOT NULL,
        recent_play_time INTEGER NOT NULL
      )`
  create_album: string = `CREATE TABLE IF NOT EXISTS album (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        album_mid TEXT NOT NULL,
        name TEXT NOT NULL,
        desc TEXT NOT NULL,
        time TEXT NOT NULL,
        liked TEXT NOT NULL,
        recently TEXT NOT NULL,
        recent_play_time INTEGER NOT NULL
      )`
  create_playlist: string = `CREATE TABLE IF NOT EXISTS playlist (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        play_mid TEXT NOT NULL,
        name TEXT NOT NULL,
        desc TEXT NOT NULL,
        head_pic TEXT NOT NULL,
        creator_name TEXT NOT NULL,
        listen_num TEXT NOT NULL,
        pic_url TEXT NOT NULL,
        self_create TEXT NOT NULL,
        liked TEXT NOT NULL,
        recently TEXT NOT NULL,
        recent_play_time INTEGER NOT NULL
      )`

  // 获取数据库管理对象
  async getStoreInstance() {
    // 如果已经存在，直接返回
    if (this.store) {
      return this.store
    }
    // 获取操作数据库的管理对象(如果数据库文件不存在，会自动创建数据库文件)
    this.store = await relationalStore.getRdbStore(getContext(), {
      name: 'RdbOnePiece.db', // 数据库文件名
      securityLevel: relationalStore.SecurityLevel.S1, // 数据库安全级别
    })
    // 执行创建表的语句 execute 执行
    this.store.executeSql(this.create_song)
    this.store.executeSql(this.create_singer)
    this.store.executeSql(this.create_album)
    this.store.executeSql(this.create_playlist)
    if (this.store.version === 0) {
      // 设置数据库的版本，入参为大于0的整数
      this.store.version = 1;
    }
    // 返回 store 对象
    return this.store
  }

  //插入数据
  async insert_singer(singer: Singer, like: string = '0', recent: string = '0') {
    let cur_time = systemDateTime.getTime();
    // 获取操作数据库的对象
    const store = await this.getStoreInstance()
    // 添加一条数据
    const id = await store.insert('singer', {
      id: null, // 新增时设置 id 为空值 null，用于自增 id
      name: singer.name,
      singer_mid: singer.mid,
      pic: singer.pic_url,
      liked: like,
      recently: recent,
      recent_play_time: cur_time
    } as SingerItem)
  }

  async insert_song(song_info: SongInfo, like: string = '0', recent: string = '0', playlist_id: string = '0') {
    let cur_time = systemDateTime.getTime();
    // 获取操作数据库的对象
    const store = await this.getStoreInstance()
    // 添加一条数据
    const id = await store.insert('song', {
      id: null, // 新增时设置 id 为空值 null，用于自增 id
      song_mid: song_info.song_mid,
      name: song_info.name,
      mp3_url: song_info.mp3_url,
      lyric: song_info.lyric,
      album_id: song_info.album_id,
      singer_mid: song_info.singer_id,
      singer_name: song_info.singer,
      play_id: playlist_id,
      liked: like,
      recently: recent,
      recent_play_time: cur_time
    } as SongItem)
  }

  async insert_album(album_info: Album, like: string = '0', recent: string = '0') {
    let cur_time = systemDateTime.getTime();
    // 获取操作数据库的对象
    const store = await this.getStoreInstance()
    // 添加一条数据
    const id = await store.insert('album', {
      id: null, // 新增时设置 id 为空值 null，用于自增 id
      album_mid: album_info.mid,
      name: album_info.name,
      desc: album_info.desc,
      time: album_info.time,
      liked: like,
      recently: recent,
      recent_play_time: cur_time
    } as AlbumItem)
  }

  async insert_playlist(playlist_info: PlayList, create: string = '0', like: string = '0', recent: string = '0') {
    let cur_time = systemDateTime.getTime();
    // 获取操作数据库的对象
    const store = await this.getStoreInstance()
    // 添加一条数据
    const id = await store.insert('playlist', {
      id: null, // 新增时设置 id 为空值 null，用于自增 id
      play_mid: playlist_info.id,
      name: playlist_info.name,
      desc: playlist_info.desc,
      head_pic: playlist_info.headpic,
      creator_name: playlist_info.creator_name,
      listen_num: playlist_info.listening_num,
      pic_url: playlist_info.picurl,
      self_create: create,
      liked: like,
      recently: recent,
      recent_play_time: cur_time
    } as PlayListItem)
  }

  //查询所有本地歌曲数据
  async query_song_all(): Promise<SongItem[]> {
    // 获取操作数据库的对象
    const store = await this.getStoreInstance()
    // 谓词（条件）
    const predicates = new relationalStore.RdbPredicates('song')
    predicates.orderByDesc('id') // 倒序(由大到小，常用于排序)
    // predicates.orderByAsc('id')   // 正序(小到大，常用于排序)
    // predicates.equalTo('id', 1)    // 等于(常用于详情页)
    // predicates.in('id', [1, 3, 5]) // 查找多项(常用批量删除)
    // predicates.like('title', '%哈%') //  模糊匹配(常用于搜索)
    // 还有很多...
    // predicates.greaterThan('id', 3)
    // resultSet 结果集
    const resultSet = await store.query(predicates)
    // 准备一个数组，用于存储数据库提取的数据
    const list: SongItem [] = []
    // resultSet.goToNextRow()   指针移动到下一行
    while (resultSet.goToNextRow()) {
      // 移动指针的时候提取数据，按列下标提取数据
      list.push({
        // resultSet.getColumnIndex()        根据列名称获取下标(索引)
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        song_mid: resultSet.getString(resultSet.getColumnIndex('song_mid')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        mp3_url: resultSet.getString(resultSet.getColumnIndex('mp3_url')),
        lyric: resultSet.getString(resultSet.getColumnIndex('lyric')),
        album_id: resultSet.getString(resultSet.getColumnIndex('album_id')),
        singer_mid: resultSet.getString(resultSet.getColumnIndex('singer_mid')),
        singer_name: resultSet.getString(resultSet.getColumnIndex('singer_name')),
        play_id: resultSet.getString(resultSet.getColumnIndex('play_id')),
        liked: resultSet.getString(resultSet.getColumnIndex('liked')),
        recently: resultSet.getString(resultSet.getColumnIndex('recently')),
        recent_play_time: resultSet.getLong(resultSet.getColumnIndex('recent_play_time'))
      })
    }
    return list;
  }

  async query_song_liked(): Promise<SongItem[]> {
    // 获取操作数据库的对象
    const store = await this.getStoreInstance()
    // 谓词（条件）
    const predicates = new relationalStore.RdbPredicates('song')
    predicates.equalTo('liked', '1') // 倒序(由大到小，常用于排序)
    // predicates.orderByAsc('id')   // 正序(小到大，常用于排序)
    // predicates.equalTo('id', 1)    // 等于(常用于详情页)
    // predicates.in('id', [1, 3, 5]) // 查找多项(常用批量删除)
    // predicates.like('title', '%哈%') //  模糊匹配(常用于搜索)
    // 还有很多...
    // predicates.greaterThan('id', 3)
    // resultSet 结果集
    const resultSet = await store.query(predicates)
    // 准备一个数组，用于存储数据库提取的数据
    const list: SongItem [] = []
    // resultSet.goToNextRow()   指针移动到下一行
    while (resultSet.goToNextRow()) {
      // 移动指针的时候提取数据，按列下标提取数据
      list.push({
        // resultSet.getColumnIndex()        根据列名称获取下标(索引)
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        song_mid: resultSet.getString(resultSet.getColumnIndex('song_mid')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        mp3_url: resultSet.getString(resultSet.getColumnIndex('mp3_url')),
        lyric: resultSet.getString(resultSet.getColumnIndex('lyric')),
        album_id: resultSet.getString(resultSet.getColumnIndex('album_id')),
        singer_mid: resultSet.getString(resultSet.getColumnIndex('singer_mid')),
        singer_name: resultSet.getString(resultSet.getColumnIndex('singer_name')),
        play_id: resultSet.getString(resultSet.getColumnIndex('play_id')),
        liked: resultSet.getString(resultSet.getColumnIndex('liked')),
        recently: resultSet.getString(resultSet.getColumnIndex('recently')),
        recent_play_time: resultSet.getLong(resultSet.getColumnIndex('recent_play_time'))
      })
    }
    return list;
  }

  async query_song_recent(): Promise<SongItem[]> {
    // 获取操作数据库的对象
    const store = await this.getStoreInstance()
    // 谓词（条件）
    const predicates = new relationalStore.RdbPredicates('song')
    predicates.equalTo('recently', '1')
    predicates.orderByDesc('recent_play_time') // 倒序(由大到小，常用于排序)
    // predicates.orderByAsc('id')   // 正序(小到大，常用于排序)
    // predicates.equalTo('id', 1)    // 等于(常用于详情页)
    // predicates.in('id', [1, 3, 5]) // 查找多项(常用批量删除)
    // predicates.like('title', '%哈%') //  模糊匹配(常用于搜索)
    // 还有很多...
    // predicates.greaterThan('id', 3)
    // resultSet 结果集
    const resultSet = await store.query(predicates)
    // 准备一个数组，用于存储数据库提取的数据
    const list: SongItem [] = []
    // resultSet.goToNextRow()   指针移动到下一行
    while (resultSet.goToNextRow()) {
      // 移动指针的时候提取数据，按列下标提取数据
      list.push({
        // resultSet.getColumnIndex()        根据列名称获取下标(索引)
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        song_mid: resultSet.getString(resultSet.getColumnIndex('song_mid')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        mp3_url: resultSet.getString(resultSet.getColumnIndex('mp3_url')),
        lyric: resultSet.getString(resultSet.getColumnIndex('lyric')),
        album_id: resultSet.getString(resultSet.getColumnIndex('album_id')),
        singer_mid: resultSet.getString(resultSet.getColumnIndex('singer_mid')),
        singer_name: resultSet.getString(resultSet.getColumnIndex('singer_name')),
        play_id: resultSet.getString(resultSet.getColumnIndex('play_id')),
        liked: resultSet.getString(resultSet.getColumnIndex('liked')),
        recently: resultSet.getString(resultSet.getColumnIndex('recently')),
        recent_play_time: resultSet.getLong(resultSet.getColumnIndex('recent_play_time'))
      })
    }
    return list;
  }

  async query_song_mid(id: string): Promise<SongItem[]> {
    // 获取操作数据库的对象
    const store = await this.getStoreInstance()
    // 谓词（条件）
    const predicates = new relationalStore.RdbPredicates('song')
    predicates.equalTo('song_mid', id) // 倒序(由大到小，常用于排序)
    // predicates.orderByAsc('id')   // 正序(小到大，常用于排序)
    // predicates.equalTo('id', 1)    // 等于(常用于详情页)
    // predicates.in('id', [1, 3, 5]) // 查找多项(常用批量删除)
    // predicates.like('title', '%哈%') //  模糊匹配(常用于搜索)
    // 还有很多...
    // predicates.greaterThan('id', 3)
    // resultSet 结果集
    const resultSet = await store.query(predicates)
    // 准备一个数组，用于存储数据库提取的数据
    const list: SongItem [] = []
    // resultSet.goToNextRow()   指针移动到下一行
    while (resultSet.goToNextRow()) {
      // 移动指针的时候提取数据，按列下标提取数据
      list.push({
        // resultSet.getColumnIndex()        根据列名称获取下标(索引)
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        song_mid: resultSet.getString(resultSet.getColumnIndex('song_mid')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        mp3_url: resultSet.getString(resultSet.getColumnIndex('mp3_url')),
        lyric: resultSet.getString(resultSet.getColumnIndex('lyric')),
        album_id: resultSet.getString(resultSet.getColumnIndex('album_id')),
        singer_mid: resultSet.getString(resultSet.getColumnIndex('singer_mid')),
        singer_name: resultSet.getString(resultSet.getColumnIndex('singer_name')),
        play_id: resultSet.getString(resultSet.getColumnIndex('play_id')),
        liked: resultSet.getString(resultSet.getColumnIndex('liked')),
        recently: resultSet.getString(resultSet.getColumnIndex('recently')),
        recent_play_time: resultSet.getLong(resultSet.getColumnIndex('recent_play_time'))
      })
    }
    return list;
  }

  async query_song_playlist(id: string): Promise<SongItem[]> {
    // 获取操作数据库的对象
    const store = await this.getStoreInstance()
    // 谓词（条件）
    const predicates = new relationalStore.RdbPredicates('song')
    predicates.equalTo('play_id', id) // 倒序(由大到小，常用于排序)
    // predicates.orderByAsc('id')   // 正序(小到大，常用于排序)
    // predicates.equalTo('id', 1)    // 等于(常用于详情页)
    // predicates.in('id', [1, 3, 5]) // 查找多项(常用批量删除)
    // predicates.like('title', '%哈%') //  模糊匹配(常用于搜索)
    // 还有很多...
    // predicates.greaterThan('id', 3)
    // resultSet 结果集
    const resultSet = await store.query(predicates)
    // 准备一个数组，用于存储数据库提取的数据
    const list: SongItem [] = []
    // resultSet.goToNextRow()   指针移动到下一行
    while (resultSet.goToNextRow()) {
      // 移动指针的时候提取数据，按列下标提取数据
      list.push({
        // resultSet.getColumnIndex()        根据列名称获取下标(索引)
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        song_mid: resultSet.getString(resultSet.getColumnIndex('song_mid')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        mp3_url: resultSet.getString(resultSet.getColumnIndex('mp3_url')),
        lyric: resultSet.getString(resultSet.getColumnIndex('lyric')),
        album_id: resultSet.getString(resultSet.getColumnIndex('album_id')),
        singer_mid: resultSet.getString(resultSet.getColumnIndex('singer_mid')),
        singer_name: resultSet.getString(resultSet.getColumnIndex('singer_name')),
        play_id: resultSet.getString(resultSet.getColumnIndex('play_id')),
        liked: resultSet.getString(resultSet.getColumnIndex('liked')),
        recently: resultSet.getString(resultSet.getColumnIndex('recently')),
        recent_play_time: resultSet.getLong(resultSet.getColumnIndex('recent_play_time'))
      })
    }
    return list;
  }

  //查询收藏歌手数据
  async query_singer_all() {
    // 获取操作数据库的对象
    const store = await this.getStoreInstance()
    // 谓词（条件）
    const predicates = new relationalStore.RdbPredicates('singer')
    predicates.orderByDesc('id') // 倒序(由大到小，常用于排序)
    const resultSet = await store.query(predicates)
    // 准备一个数组，用于存储数据库提取的数据
    const list: SingerItem [] = []
    // resultSet.goToNextRow()   指针移动到下一行
    while (resultSet.goToNextRow()) {
      // 移动指针的时候提取数据，按列下标提取数据
      list.push({
        // resultSet.getColumnIndex()        根据列名称获取下标(索引)
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        singer_mid: resultSet.getString(resultSet.getColumnIndex('singer_mid')),
        pic: resultSet.getString(resultSet.getColumnIndex('pic')),
        liked: resultSet.getString(resultSet.getColumnIndex('liked')),
        recently: resultSet.getString(resultSet.getColumnIndex('recently')),
        recent_play_time: resultSet.getLong(resultSet.getColumnIndex('recent_play_time'))
      })
    }
    promptAction.showToast({
      message: list[0].name
    })
  }

  async query_singer_mid(id: string): Promise<SingerItem[]> {
    // 获取操作数据库的对象
    const store = await this.getStoreInstance()
    // 谓词（条件）
    const predicates = new relationalStore.RdbPredicates('singer')
    predicates.equalTo('singer_mid', id) // 倒序(由大到小，常用于排序)
    const resultSet = await store.query(predicates)
    // 准备一个数组，用于存储数据库提取的数据
    const list: SingerItem [] = []
    // resultSet.goToNextRow()   指针移动到下一行
    while (resultSet.goToNextRow()) {
      // 移动指针的时候提取数据，按列下标提取数据
      list.push({
        // resultSet.getColumnIndex()        根据列名称获取下标(索引)
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        singer_mid: resultSet.getString(resultSet.getColumnIndex('singer_mid')),
        pic: resultSet.getString(resultSet.getColumnIndex('pic')),
        liked: resultSet.getString(resultSet.getColumnIndex('liked')),
        recently: resultSet.getString(resultSet.getColumnIndex('recently')),
        recent_play_time: resultSet.getLong(resultSet.getColumnIndex('recent_play_time'))
      })
    }
    return list;
  }

  async query_singer_liked(): Promise<SingerItem[]> {
    // 获取操作数据库的对象
    const store = await this.getStoreInstance()
    // 谓词（条件）
    const predicates = new relationalStore.RdbPredicates('singer')
    predicates.equalTo('liked', '1') // 倒序(由大到小，常用于排序)
    const resultSet = await store.query(predicates)
    // 准备一个数组，用于存储数据库提取的数据
    const list: SingerItem [] = []
    // resultSet.goToNextRow()   指针移动到下一行
    while (resultSet.goToNextRow()) {
      // 移动指针的时候提取数据，按列下标提取数据
      list.push({
        // resultSet.getColumnIndex()        根据列名称获取下标(索引)
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        singer_mid: resultSet.getString(resultSet.getColumnIndex('singer_mid')),
        pic: resultSet.getString(resultSet.getColumnIndex('pic')),
        liked: resultSet.getString(resultSet.getColumnIndex('liked')),
        recently: resultSet.getString(resultSet.getColumnIndex('recently')),
        recent_play_time: resultSet.getLong(resultSet.getColumnIndex('recent_play_time'))
      })
    }
    return list;
  }

  async query_singer_recent(): Promise<SingerItem[]> {
    // 获取操作数据库的对象
    const store = await this.getStoreInstance()
    // 谓词（条件）
    const predicates = new relationalStore.RdbPredicates('singer')
    predicates.equalTo('recently', '1') // 倒序(由大到小，常用于排序)
    const resultSet = await store.query(predicates)
    // 准备一个数组，用于存储数据库提取的数据
    const list: SingerItem [] = []
    // resultSet.goToNextRow()   指针移动到下一行
    while (resultSet.goToNextRow()) {
      // 移动指针的时候提取数据，按列下标提取数据
      list.push({
        // resultSet.getColumnIndex()        根据列名称获取下标(索引)
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        singer_mid: resultSet.getString(resultSet.getColumnIndex('singer_mid')),
        pic: resultSet.getString(resultSet.getColumnIndex('pic')),
        liked: resultSet.getString(resultSet.getColumnIndex('liked')),
        recently: resultSet.getString(resultSet.getColumnIndex('recently')),
        recent_play_time: resultSet.getLong(resultSet.getColumnIndex('recent_play_time'))
      })
    }
    return list;
  }

  //查询所有专辑数据
  async query_album_all() {
    // 获取操作数据库的对象
    const store = await this.getStoreInstance()
    // 谓词（条件）
    const predicates = new relationalStore.RdbPredicates('album')
    predicates.orderByDesc('id') // 倒序(由大到小，常用于排序)
    const resultSet = await store.query(predicates)
    // 准备一个数组，用于存储数据库提取的数据
    const list: AlbumItem [] = []
    // resultSet.goToNextRow()   指针移动到下一行
    while (resultSet.goToNextRow()) {
      // 移动指针的时候提取数据，按列下标提取数据
      list.push({
        // resultSet.getColumnIndex()        根据列名称获取下标(索引)
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        album_mid: resultSet.getString(resultSet.getColumnIndex('album_mid')),
        desc: resultSet.getString(resultSet.getColumnIndex('desc')),
        time: resultSet.getString(resultSet.getColumnIndex('desc')),
        liked: resultSet.getString(resultSet.getColumnIndex('liked')),
        recently: resultSet.getString(resultSet.getColumnIndex('recently')),
        recent_play_time: resultSet.getLong(resultSet.getColumnIndex('recent_play_time'))
      })
    }
    promptAction.showToast({
      message: list[0].name
    })
  }

  //查询某个id的专辑
  async query_album_mid(id: string): Promise<AlbumItem[]> {
    // 获取操作数据库的对象
    const store = await this.getStoreInstance()
    // 谓词（条件）
    const predicates = new relationalStore.RdbPredicates('album')
    predicates.equalTo('album_mid', id) // 倒序(由大到小，常用于排序)
    const resultSet = await store.query(predicates)
    // 准备一个数组，用于存储数据库提取的数据
    const list: AlbumItem [] = []
    // resultSet.goToNextRow()   指针移动到下一行
    while (resultSet.goToNextRow()) {
      // 移动指针的时候提取数据，按列下标提取数据
      list.push({
        // resultSet.getColumnIndex()        根据列名称获取下标(索引)
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        album_mid: resultSet.getString(resultSet.getColumnIndex('album_mid')),
        desc: resultSet.getString(resultSet.getColumnIndex('desc')),
        time: resultSet.getString(resultSet.getColumnIndex('time')),
        liked: resultSet.getString(resultSet.getColumnIndex('liked')),
        recently: resultSet.getString(resultSet.getColumnIndex('recently')),
        recent_play_time: resultSet.getLong(resultSet.getColumnIndex('recent_play_time'))
      })
    }
    return list;
  }

  async query_album_liked(): Promise<AlbumItem[]> {
    // 获取操作数据库的对象
    const store = await this.getStoreInstance()
    // 谓词（条件）
    const predicates = new relationalStore.RdbPredicates('album')
    predicates.equalTo('liked', '1') // 倒序(由大到小，常用于排序)
    const resultSet = await store.query(predicates)
    // 准备一个数组，用于存储数据库提取的数据
    const list: AlbumItem [] = []
    // resultSet.goToNextRow()   指针移动到下一行
    while (resultSet.goToNextRow()) {
      // 移动指针的时候提取数据，按列下标提取数据
      list.push({
        // resultSet.getColumnIndex()        根据列名称获取下标(索引)
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        album_mid: resultSet.getString(resultSet.getColumnIndex('album_mid')),
        desc: resultSet.getString(resultSet.getColumnIndex('desc')),
        time: resultSet.getString(resultSet.getColumnIndex('time')),
        liked: resultSet.getString(resultSet.getColumnIndex('liked')),
        recently: resultSet.getString(resultSet.getColumnIndex('recently')),
        recent_play_time: resultSet.getLong(resultSet.getColumnIndex('recent_play_time'))
      })
    }
    return list;
  }

  async query_album_recent(): Promise<AlbumItem[]> {
    // 获取操作数据库的对象
    const store = await this.getStoreInstance()
    // 谓词（条件）
    const predicates = new relationalStore.RdbPredicates('album')
    predicates.equalTo('recently', '1') // 倒序(由大到小，常用于排序)
    const resultSet = await store.query(predicates)
    // 准备一个数组，用于存储数据库提取的数据
    const list: AlbumItem [] = []
    // resultSet.goToNextRow()   指针移动到下一行
    while (resultSet.goToNextRow()) {
      // 移动指针的时候提取数据，按列下标提取数据
      list.push({
        // resultSet.getColumnIndex()        根据列名称获取下标(索引)
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        album_mid: resultSet.getString(resultSet.getColumnIndex('album_mid')),
        desc: resultSet.getString(resultSet.getColumnIndex('desc')),
        time: resultSet.getString(resultSet.getColumnIndex('time')),
        liked: resultSet.getString(resultSet.getColumnIndex('liked')),
        recently: resultSet.getString(resultSet.getColumnIndex('recently')),
        recent_play_time: resultSet.getLong(resultSet.getColumnIndex('recent_play_time'))
      })
    }
    return list;
  }

  //查询收藏歌单数据
  async query_playlist_all(): Promise<PlayListItem[]> {
    // 获取操作数据库的对象
    const store = await this.getStoreInstance()
    // 谓词（条件）
    const predicates = new relationalStore.RdbPredicates('playlist')
    predicates.orderByDesc('id') // 倒序(由大到小，常用于排序)
    const resultSet = await store.query(predicates)
    // 准备一个数组，用于存储数据库提取的数据
    const list: PlayListItem [] = []
    // resultSet.goToNextRow()   指针移动到下一行
    while (resultSet.goToNextRow()) {
      // 移动指针的时候提取数据，按列下标提取数据
      list.push({
        // resultSet.getColumnIndex()        根据列名称获取下标(索引)
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        play_mid: resultSet.getString(resultSet.getColumnIndex('play_mid')),
        desc: resultSet.getString(resultSet.getColumnIndex('desc')),
        head_pic: resultSet.getString(resultSet.getColumnIndex('head_pic')),
        creator_name: resultSet.getString(resultSet.getColumnIndex('creator_name')),
        listen_num: resultSet.getString(resultSet.getColumnIndex('listen_num')),
        pic_url: resultSet.getString(resultSet.getColumnIndex('pic_url')),
        self_create: resultSet.getString(resultSet.getColumnIndex('self_create')),
        liked: resultSet.getString(resultSet.getColumnIndex('liked')),
        recently: resultSet.getString(resultSet.getColumnIndex('recently')),
        recent_play_time: resultSet.getLong(resultSet.getColumnIndex('recent_play_time'))
      })
    }
    return list;
  }

  async query_playlist_liked(): Promise<PlayListItem[]> {
    // 获取操作数据库的对象
    const store = await this.getStoreInstance()
    // 谓词（条件）
    const predicates = new relationalStore.RdbPredicates('playlist')
    predicates.equalTo('liked', '1') // 倒序(由大到小，常用于排序)
    const resultSet = await store.query(predicates)
    // 准备一个数组，用于存储数据库提取的数据
    const list: PlayListItem [] = []
    // resultSet.goToNextRow()   指针移动到下一行
    while (resultSet.goToNextRow()) {
      // 移动指针的时候提取数据，按列下标提取数据
      list.push({
        // resultSet.getColumnIndex()        根据列名称获取下标(索引)
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        play_mid: resultSet.getString(resultSet.getColumnIndex('play_mid')),
        desc: resultSet.getString(resultSet.getColumnIndex('desc')),
        head_pic: resultSet.getString(resultSet.getColumnIndex('head_pic')),
        creator_name: resultSet.getString(resultSet.getColumnIndex('creator_name')),
        listen_num: resultSet.getString(resultSet.getColumnIndex('listen_num')),
        pic_url: resultSet.getString(resultSet.getColumnIndex('pic_url')),
        self_create: resultSet.getString(resultSet.getColumnIndex('self_create')),
        liked: resultSet.getString(resultSet.getColumnIndex('liked')),
        recently: resultSet.getString(resultSet.getColumnIndex('recently')),
        recent_play_time: resultSet.getLong(resultSet.getColumnIndex('recent_play_time'))
      })
    }
    return list;
  }

  async query_playlist_recent(): Promise<PlayListItem[]> {
    // 获取操作数据库的对象
    const store = await this.getStoreInstance()
    // 谓词（条件）
    const predicates = new relationalStore.RdbPredicates('playlist')
    predicates.equalTo('recently', '1') // 倒序(由大到小，常用于排序)
    const resultSet = await store.query(predicates)
    // 准备一个数组，用于存储数据库提取的数据
    const list: PlayListItem [] = []
    // resultSet.goToNextRow()   指针移动到下一行
    while (resultSet.goToNextRow()) {
      // 移动指针的时候提取数据，按列下标提取数据
      list.push({
        // resultSet.getColumnIndex()        根据列名称获取下标(索引)
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        play_mid: resultSet.getString(resultSet.getColumnIndex('play_mid')),
        desc: resultSet.getString(resultSet.getColumnIndex('desc')),
        head_pic: resultSet.getString(resultSet.getColumnIndex('head_pic')),
        creator_name: resultSet.getString(resultSet.getColumnIndex('creator_name')),
        listen_num: resultSet.getString(resultSet.getColumnIndex('listen_num')),
        pic_url: resultSet.getString(resultSet.getColumnIndex('pic_url')),
        self_create: resultSet.getString(resultSet.getColumnIndex('self_create')),
        liked: resultSet.getString(resultSet.getColumnIndex('liked')),
        recently: resultSet.getString(resultSet.getColumnIndex('recently')),
        recent_play_time: resultSet.getLong(resultSet.getColumnIndex('recent_play_time'))
      })
    }
    return list;
  }

  async query_playlist_self_create(): Promise<PlayListItem[]> {
    // 获取操作数据库的对象
    const store = await this.getStoreInstance()
    // 谓词（条件）
    const predicates = new relationalStore.RdbPredicates('playlist')
    predicates.equalTo('self_create', '1') // 倒序(由大到小，常用于排序)
    const resultSet = await store.query(predicates)
    // 准备一个数组，用于存储数据库提取的数据
    const list: PlayListItem [] = []
    // resultSet.goToNextRow()   指针移动到下一行
    while (resultSet.goToNextRow()) {
      // 移动指针的时候提取数据，按列下标提取数据
      list.push({
        // resultSet.getColumnIndex()        根据列名称获取下标(索引)
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        play_mid: resultSet.getString(resultSet.getColumnIndex('play_mid')),
        desc: resultSet.getString(resultSet.getColumnIndex('desc')),
        head_pic: resultSet.getString(resultSet.getColumnIndex('head_pic')),
        creator_name: resultSet.getString(resultSet.getColumnIndex('creator_name')),
        listen_num: resultSet.getString(resultSet.getColumnIndex('listen_num')),
        pic_url: resultSet.getString(resultSet.getColumnIndex('pic_url')),
        self_create: resultSet.getString(resultSet.getColumnIndex('self_create')),
        liked: resultSet.getString(resultSet.getColumnIndex('liked')),
        recently: resultSet.getString(resultSet.getColumnIndex('recently')),
        recent_play_time: resultSet.getLong(resultSet.getColumnIndex('recent_play_time'))
      })
    }
    return list;
  }

  //查询收藏歌单数据
  async query_playlist_mid(id: string): Promise<PlayListItem[]> {
    // 获取操作数据库的对象
    const store = await this.getStoreInstance()
    // 谓词（条件）
    const predicates = new relationalStore.RdbPredicates('playlist')
    predicates.equalTo('play_mid', id) // 倒序(由大到小，常用于排序)
    const resultSet = await store.query(predicates)
    // 准备一个数组，用于存储数据库提取的数据
    const list: PlayListItem [] = []
    // resultSet.goToNextRow()   指针移动到下一行
    while (resultSet.goToNextRow()) {
      // 移动指针的时候提取数据，按列下标提取数据
      list.push({
        // resultSet.getColumnIndex()        根据列名称获取下标(索引)
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        play_mid: resultSet.getString(resultSet.getColumnIndex('play_mid')),
        desc: resultSet.getString(resultSet.getColumnIndex('desc')),
        head_pic: resultSet.getString(resultSet.getColumnIndex('head_pic')),
        creator_name: resultSet.getString(resultSet.getColumnIndex('creator_name')),
        listen_num: resultSet.getString(resultSet.getColumnIndex('listen_num')),
        pic_url: resultSet.getString(resultSet.getColumnIndex('pic_url')),
        self_create: resultSet.getString(resultSet.getColumnIndex('self_create')),
        liked: resultSet.getString(resultSet.getColumnIndex('liked')),
        recently: resultSet.getString(resultSet.getColumnIndex('recently')),
        recent_play_time: resultSet.getLong(resultSet.getColumnIndex('recent_play_time'))
      })
    }
    return list;
  }


  async query_playlist_id(id: string): Promise<PlayListItem[]> {
    // 获取操作数据库的对象
    const store = await this.getStoreInstance()
    // 谓词（条件）
    const predicates = new relationalStore.RdbPredicates('playlist')
    predicates.equalTo('play_mid', id) // 倒序(由大到小，常用于排序)
    const resultSet = await store.query(predicates)
    // 准备一个数组，用于存储数据库提取的数据
    const list: PlayListItem [] = []
    // resultSet.goToNextRow()   指针移动到下一行
    while (resultSet.goToNextRow()) {
      // 移动指针的时候提取数据，按列下标提取数据
      list.push({
        // resultSet.getColumnIndex()        根据列名称获取下标(索引)
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        play_mid: resultSet.getString(resultSet.getColumnIndex('play_mid')),
        desc: resultSet.getString(resultSet.getColumnIndex('desc')),
        head_pic: resultSet.getString(resultSet.getColumnIndex('head_pic')),
        creator_name: resultSet.getString(resultSet.getColumnIndex('creator_name')),
        listen_num: resultSet.getString(resultSet.getColumnIndex('listen_num')),
        pic_url: resultSet.getString(resultSet.getColumnIndex('pic_url')),
        self_create: resultSet.getString(resultSet.getColumnIndex('self_create')),
        liked: resultSet.getString(resultSet.getColumnIndex('liked')),
        recently: resultSet.getString(resultSet.getColumnIndex('recently')),
        recent_play_time: resultSet.getLong(resultSet.getColumnIndex('recent_play_time'))
      })
    }
    return list;
  }

  //删除所有数据
  async delete(table_name: string) {
    // 获取操作数据库对象
    const store = await this.getStoreInstance()
    const predicates = new relationalStore.RdbPredicates(table_name)
    // 注意!!!：记得添加 predicates 限定条件，否者会删除所有数据
    // predicates.equalTo('id', 2)        // equalTo 删除一条
    // predicates.in(field_name, [1, 2, 3, 4, 5]) //  in      批量删除
    const affectedRows = await store.delete(predicates)
  }

  alter() {
    if (this.store!.version === 3) {
      // version = 1：表结构：EMPLOYEE (NAME, SALARY, CODES, ADDRESS) => version = 2：表结构：EMPLOYEE (NAME, AGE, SALARY, CODES, ADDRESS)
      // (this.store as relationalStore.RdbStore).executeSql('ALTER TABLE song ADD COLUMN recent_play_time INTEGER');
      (this.store as relationalStore.RdbStore).executeSql('ALTER TABLE singer ADD COLUMN recent_play_time INTEGER');
      (this.store as relationalStore.RdbStore).executeSql('ALTER TABLE album ADD COLUMN recent_play_time INTEGER');
      (this.store as relationalStore.RdbStore).executeSql('ALTER TABLE playlist ADD COLUMN recent_play_time INTEGER');
      this.store!.version = 4;
    }
  }

  //加入歌单,已经收藏过或者播放过
  async update_playlist(table_name: string = 'song', song_mid: string = '', play_mid: string) {
    // 获取操作数据库对象
    const store = await this.getStoreInstance()
    // 谓词(条件)
    const predicates = new relationalStore.RdbPredicates(table_name)
    // 注意!!!：记得添加 predicates 限定条件，否者修改全部
    predicates.equalTo('song_mid', song_mid)
    // 待更新数据
    const value = { play_id: play_mid } as SongItem
    const affectedRows = await store.update(value, predicates)
  }

  //添加到喜欢
  async update_like(type: number = 0, mid: string = '') {
    let table_name_list: string[] = ['song', 'singer', 'album', 'playlist'];
    let id_list: string[] = ['song_mid', 'singer_mid', 'album_mid', 'play_mid'];
    // 获取操作数据库对象
    const store = await this.getStoreInstance()
    // 谓词(条件)
    const predicates = new relationalStore.RdbPredicates(table_name_list[type])
    // 注意!!!：记得添加 predicates 限定条件，否者修改全部
    predicates.equalTo(id_list[type], mid)
    // 待更新数据
    const value = { liked: '1' } as SongItem
    const affectedRows = await store.update(value, predicates)
  }

  async update_unlike(type: number = 0, mid: string = '') {
    let table_name_list: string[] = ['song', 'singer', 'album', 'playlist'];
    let id_list: string[] = ['song_mid', 'singer_mid', 'album_mid', 'play_mid'];
    // 获取操作数据库对象
    const store = await this.getStoreInstance()
    // 谓词(条件)
    const predicates = new relationalStore.RdbPredicates(table_name_list[type])
    // 注意!!!：记得添加 predicates 限定条件，否者修改全部
    predicates.equalTo(id_list[type], mid)
    // 待更新数据
    const value = { liked: '0' } as SongItem
    const affectedRows = await store.update(value, predicates)
  }

  async update_un_self_create(mid: string = '') {
    // 获取操作数据库对象
    const store = await this.getStoreInstance()
    // 谓词(条件)
    const predicates = new relationalStore.RdbPredicates('playlist')
    // 注意!!!：记得添加 predicates 限定条件，否者修改全部
    predicates.equalTo('play_mid', mid)
    // 待更新数据
    const value = { self_create: '0' } as PlayListItem
    const affectedRows = await store.update(value, predicates)
  }

  //添加到最近播放列表，已经在收藏或者播放过
  async update_recently_time(type: number = 0, mid: string = '') {
    let table_name_list: string[] = ['song', 'singer', 'album', 'playlist'];
    let id_list: string[] = ['song_mid', 'singer_mid', 'album_mid', 'play_mid'];
    let cur_time = systemDateTime.getTime();
    // 获取操作数据库对象
    const store = await this.getStoreInstance()
    // 谓词(条件)
    const predicates = new relationalStore.RdbPredicates(table_name_list[type])
    // 注意!!!：记得添加 predicates 限定条件，否者修改全部
    predicates.equalTo(id_list[type], mid)
    // 待更新数据
    const value = { recently: '1', recent_play_time: cur_time } as SongItem
    const affectedRows = await store.update(value, predicates)
  }

  async update_un_recent(type: number = 0, mid: string = '') {
    let table_name_list: string[] = ['song', 'singer', 'album', 'playlist'];
    let id_list: string[] = ['song_mid', 'singer_mid', 'album_mid', 'play_mid'];
    let cur_time = systemDateTime.getTime();
    // 获取操作数据库对象
    const store = await this.getStoreInstance()
    // 谓词(条件)
    const predicates = new relationalStore.RdbPredicates(table_name_list[type])
    // 注意!!!：记得添加 predicates 限定条件，否者修改全部
    predicates.equalTo(id_list[type], mid)
    // 待更新数据
    const value = { recently: '0', recent_play_time: cur_time } as SongItem
    const affectedRows = await store.update(value, predicates)
  }

  async update_playlist_pic_url(id: string, pic_url: string) {
    // 获取操作数据库对象
    const store = await this.getStoreInstance()
    // 谓词(条件)
    const predicates = new relationalStore.RdbPredicates('playlist')
    // 注意!!!：记得添加 predicates 限定条件，否者修改全部
    predicates.equalTo('play_mid', id)
    // 待更新数据
    const value = { pic_url: pic_url } as PlayListItem
    const affectedRows = await store.update(value, predicates)
  }
}