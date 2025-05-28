/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { rcp } from '@kit.RemoteCommunicationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import hot_return from '../viewModel/hotReturn'
import SongInfo from '../viewModel/SongInfo'
import { RankList, song } from '../viewModel/RankList';
import CategoryList, { item } from '../viewModel/CategoryList';
import PlayList from '../viewModel/PlayList';
import Singer from '../viewModel/Singer';
import Album from '../viewModel/Album';
import { RankDetail, songs } from '../viewModel/RankDetail';

const limit_min = 5;

const ip = "" //本地ipv4
const qq = '' //你的qq号
const request_cur_song_url_api: string = 'http://' + ip + ':3200/getMusicPlay?songmid=';
const request_cur_song_info_api: string = 'http://' + ip + ':3200/getSongInfo?songmid=';
const request_cur_album_img_api: string = 'http://' + ip + ':3200/getImageUrl?id=';
const request_cur_song_lyric_api: string = 'http://' + ip + ':3200/getLyric?songmid=';
const request_singer_hot_api: string = 'http://' + ip + ':3200/getSingerHotsong?singermid=';
const request_search_result_api: string = 'http://' + ip + ':3200/getSearchByKey?key=';
const request_user_info_api: string = 'http://' + ip + ':3300/user/detail?id=' + qq;
const request_rank_list_api: string = 'http://' + ip + ':3200/getTopLists';
const request_category_list_api: string = 'http://' + ip + ':3200/getSongListCategories';
const request_play_list_api: string = 'http://' + ip + ':3200/getSongLists?categoryId=';
const request_play_detail_api: string = 'http://' + ip + ':3200/getSongListDetail?disstid=';
const request_singer_list_api: string = 'http://' + ip + ':3200/getSingerList?';
const request_album_info_api: string = 'http://' + ip + ':3200/getAlbumInfo?albummid=';
const request_singer_album_api: string = 'http://' + ip + ':3200/getSingerAlbum?singermid=';
const request_rank_api: string = 'http://' + ip + ':3200/getRanks';

/**
 * The RCPUtils provides the capability of accessing the network through RCP.
 */
export class RCPUtils {
  rcpSession: rcp.Session;

  constructor() {
    this.rcpSession = rcp.createSession();
  }

  /**
   * The method of initiating a GET request through RCP.
   */
  async getPlaySongUrl(id: string): Promise<string> {
    let play_url: string = '';
    let data: string = ''
    await this.rcpSession.get(request_cur_song_url_api + id)
      .then((response) => {
        data = JSON.parse(JSON.stringify(response))
        play_url = data["data"]["playUrl"][id]["url"]
        console.log("test---------url" + data["data"]["playUrl"][id]["url"]);
      }).catch((err: BusinessError) => {
      });
    return play_url;
  }

  async getPlaySongInfo(id: string): Promise<SongInfo> {
    let data: string = ''
    let songInfo: SongInfo = new SongInfo(0, '', '', '', '', '', '', '', '');
    await this.rcpSession.get(request_cur_song_info_api + id)
      .then((response) => {
        data = JSON.parse(JSON.stringify(response))
        songInfo.name = data['response']['songinfo']['data']['track_info']['name'];
        songInfo.singer = data['response']['songinfo']['data']['track_info']['singer'][0]['name'];
        songInfo.singer_id = data['response']['songinfo']['data']['track_info']['singer'][0]['mid'];
        console.log("testinfo---------" + data['response']['songinfo']['data']['track_info']['singer'][0]['name']);
      }).catch((err: BusinessError) => {
      });
    return songInfo;
  }

  async getPlayAlbumUrl(id: string): Promise<string> {
    let data: string = ''
    let imgUrl: string = '';
    await this.rcpSession.get(request_cur_album_img_api + id)
      .then((response) => {
        data = JSON.parse(JSON.stringify(response))
        imgUrl = data['response']['data']['imageUrl'];
        console.log("test---album" + data['response']['data']['imageUrl']);
      }).catch((err: BusinessError) => {
      });
    return imgUrl;
  }

  async getPlaySongLyric(id: string): Promise<string> {
    let data: string = ''
    let lyric: string = '';
    await this.rcpSession.get(request_cur_song_lyric_api + id)
      .then((response) => {
        data = JSON.parse(JSON.stringify(response))
        lyric = data['response']['lyric'];
        console.log("test---------" + data['response']['lyric']);
      }).catch((err: BusinessError) => {
      });
    return lyric;
  }

  async getSingerHotId(id: string, page?: string, limit?: string): Promise<hot_return[]> {
    let data: string = '';
    let hot_mid_list: hot_return[] = [];
    let request_url: string = request_singer_hot_api + id;
    if (page) {
      request_url = request_url + '&page=' + page;
    }
    if (limit) {
      request_url = request_url + '&limit=' + limit;
    }
    await this.rcpSession.get(request_url)
      .then((response) => {
        data = JSON.parse(JSON.stringify(response));
        data = data['response']['singer']['data']['songlist'];
        for (let index = 0; index < data.length; index++) {
          console.log("test---------" + data[index]['mid'].toString());
          hot_mid_list.push(new hot_return(data[index]['mid'], data[index]['album']['mid']));
        }
      }).catch((err: BusinessError) => {
        console.log("hot_error---------" + err.message)
      });
    return hot_mid_list;
  }

  async getSearchResult(keyword: string, page?: number, limit?: number): Promise<SongInfo[]> {
    //解决中文乱码问题
    keyword = encodeURIComponent(keyword);
    let data: string = '';
    let search_result: SongInfo[] = [];
    let request_url: string = request_search_result_api + keyword;
    if (page) {
      request_url = request_url + '&page=' + page;
    }
    if (limit) {
      request_url = request_url + '&limit=' + limit;
    }
    await this.rcpSession.get(request_url)
      .then((response) => {
        data = JSON.parse(JSON.stringify(response));
        data = data['response']['data']['song']['list'];
        for (let index = 0; index < data.length; index++) {
          console.log("test_data---------" + data[index]['singer'][0]['name'].toString())
          let song_mid: string = data[index]['songmid'];
          let name: string = data[index]['songname'];
          let album_id: string = data[index]['albummid'];
          let singer: string = data[index]['singer'][0]['name'];
          let singer_id: string = data[index]['singer'][0]['mid'];
          search_result.push(new SongInfo(0, song_mid, name, album_id, '', '', '', singer, singer_id));
        }
      }).catch((err: BusinessError) => {
      });
    return search_result;
  }

  async getRankList(): Promise<RankList[]> {
    let rank_list: RankList[] = [];
    await this.rcpSession.get(request_rank_list_api).then((response) => {
      let data: string = JSON.parse(JSON.stringify(response));
      data = data['response']['data']['topList'];
      for (let index = 0; index < data.length; index++) {
        let songlist: song[] = [];
        for (let i = 0; i < data[index]['songList'].length; i++) {
          songlist.push(new song(data[index]['songList'][i]['singername'], data[index]['songList'][i]['songname']))
        }
        rank_list.push(new RankList(data[index]['topTitle'], data[index]['listenCount'], data[index]['picUrl'],
          songlist))
      }
    })
    return rank_list;
  }

  async getRankDetail(): Promise<RankDetail> {
    let song_list: songs[] = [];
    let rank: RankDetail = new RankDetail('', '', song_list);
    await this.rcpSession.get(request_rank_api).then((response) => {
      let data: string = JSON.parse(JSON.stringify(response));
      let title: string = '';
      let num: string = '';
      let data1: string = '';
      data1 = data['response']['req_1']['data']['data']['song'];
      title = data['response']['req_1']['data']['data']['title']
      num = data['response']['req_1']['data']['data']['listenNum']
      for (let index = 0; index < 3; index++) {
        song_list.push(new songs(data1[index]['singerName'], data1[index]['title'], data1[index]['singerMid'],
          data1[index]['cover']))
      }
      rank = new RankDetail(title, num, song_list);
    })
    return rank;
  }

  async getCategoryList(): Promise<CategoryList[]> {
    let category_list: CategoryList[] = [];
    await this.rcpSession.get(request_category_list_api).then((response) => {
      let data: string = JSON.parse(JSON.stringify(response));
      data = data['response']['data']['categories'];
      for (let index = 0; index < data.length; index++) {
        let items: item[] = [];
        for (let i = 0; i < data[index]['items'].length; i++) {
          items.push(new item(data[index]['items'][i]['categoryId'], data[index]['items'][i]['categoryName']));
          console.log("cate_data---------" + data[index]['items'][i]['categoryName'].toString())
        }
        category_list.push(new CategoryList(data[index]['categoryGroupName'], items));
      }
    })
    return category_list;
  }

  async getPlayList(id: string): Promise<PlayList[]> {
    let play_list: PlayList[] = [];
    await this.rcpSession.get(request_play_list_api + id).then((response) => {
      let data: string = JSON.parse(JSON.stringify(response));
      data = data['response']['data']['list'];
      for (let index = 0; index < data.length; index++) {
        play_list.push(new PlayList(data[index]['dissid'], data[index]['imgurl'], data[index]['dissname'],
          data[index]['listennum'], data[index]['creator']['name']));
      }
    })
    return play_list;
  }

  async getPlayDetail(id: string): Promise<PlayList> {
    let play_list: PlayList | null = null;
    await this.rcpSession.get(request_play_detail_api + id).then((response) => {
      let data: string = JSON.parse(JSON.stringify(response));
      data = data['response']['cdlist'][0];
      play_list! = new PlayList('', '', '', '', '');
      play_list.headpic = data['headurl'];
      play_list!.desc = data['desc'];
      let limit: number = Math.min(data['songlist'].length, limit_min);
      for (let index = 0; index < limit; index++) {
        console.log('detail---' + data['songlist'][index]['singer'][0]['name'].toString())
        play_list.song_list.push(new SongInfo(index, data['songlist'][index]['mid'], data['songlist'][index]['name'],
          data['songlist'][index]['album']['mid'], '', '', '', data['songlist'][index]['singer'][0]['name'],
          data['songlist'][index]['singer'][0]['mid']));
      }
    })
    return play_list!;
  }


  async getSingerList(area: string = '-100', genre: string = '-100', index: string = '-100',
    sex: string = '-100'): Promise<Singer[]> {
    let singer_list: Singer[] = [];
    await this.rcpSession.get(request_singer_list_api + 'area=' + area + '&genre=' + genre + '&index=' + index +
      '&sex=' + sex).then((response) => {
      let data: string = JSON.parse(JSON.stringify(response));
      data = data['response']['singerList']['data']['singerlist'];
      let min: number = Math.min(data.length, 8)
      for (let index = 0; index < min; index++) {
        let singer: Singer = new Singer();
        singer.name = data[index]['singer_name'];
        singer.mid = data[index]['singer_mid'];
        singer.pic_url = data[index]['singer_pic'];
        console.log('singer:' + data[index]['singer_name'].toString());
        singer_list.push(singer);
      }
    })
    return singer_list!;
  }

  async getSingerHotList(id: string, page: string = '0', limit: string = '5'): Promise<Singer> {
    let data: string = '';
    let singer: Singer = new Singer();
    await this.rcpSession.get(request_singer_hot_api + id + '&page=' + page + '&limit=' + limit)
      .then((response) => {
        data = JSON.parse(JSON.stringify(response));
        data = data['response']['singer']['data']['songlist'];
        for (let index = 0; index < data.length; index++) {
          console.log("singer_hot--" + data[index]['mid'].toString());
          singer.hot_list.push(new SongInfo(index, data[index]['mid'], data[index]['name'],
            data[index]['album']['mid'], '', '', '', data[index]['singer'][0]['name'],
            data[index]['singer'][0]['mid']));
        }
      }).catch((err: BusinessError) => {
        console.log("hot_error---------" + err.message)
      });
    return singer;
  }

  async getSingerAlbumList(id: string, page: string = '1', limit: string = '5'): Promise<Singer> {
    let data: string = '';
    let singer: Singer = new Singer();
    await this.rcpSession.get(request_singer_album_api + id + '&page=' + page + '&limit=' + limit)
      .then((response) => {
        data = JSON.parse(JSON.stringify(response));
        data = data['response']['singer']['data']['albumList'];
        for (let index = 0; index < data.length; index++) {
          let album: Album = new Album();
          album.name = data[index]['albumName'];
          album.mid = data[index]['albumMid'];
          album.time = data[index]['publishDate'];
          console.log("singer_hot--" + data.toString());
          singer.album.push(album);
        }
      }).catch((err: BusinessError) => {
        console.log("hot_error---------" + err.message)
      });
    return singer;
  }

  async getAlbumInfo(id: string): Promise<Album> {
    let data: string = '';
    let album: Album = new Album();
    await this.rcpSession.get(request_album_info_api + id)
      .then((response) => {
        data = JSON.parse(JSON.stringify(response));
        data = data['response']['data'];
        album.desc = data['desc']
        let length: number = Math.min(data['list'].length, limit_min)
        for (let index = 0; index < length; index++) {
          album.song_list.push(new SongInfo(index, data['list'][index]['songmid'], data['list'][index]['songname'],
            data['list'][index]['albummid'],
            '', '', '', data['singername'], data['singermid']))
        }
        for (let index = 0; index < data['list'][0]['singer'].length; index++) {
          let singer: Singer = new Singer();
          singer.name = data['list'][0]['singer'][index]['name'];
          singer.mid = data['list'][0]['singer'][index]['mid'];
          album.singer.push(singer)
        }
        console.log('album-song---' + album.desc.toString());
      }).catch((err: BusinessError) => {
        console.log("hot_error---------" + err.message)
      });
    return album;
  }

  async getCookie(): Promise<void> {
    await this.rcpSession.get('http://' + ip + ':3300/user/cookie').then((response) => {
      console.log('log1:' + response.toString());
    })
    return;
  }

  // async getUserInfo(): Promise<UserInfo> {
  //   let data: string = ''
  //   let user_info: UserInfo | null = null;
  //   await this.rcpSession.get(request_user_info_api)
  //     .then((response) => {
  //       console.log("test--2323" + response.toString());
  //       data = JSON.parse(JSON.stringify(response))
  //       user_info!.name = data['data']['creator']['nick'];
  //       user_info!.headpic = data['data']['creator']['headpic'];
  //       let music: string = data['data']['mymusic'][0];
  //       user_info!.my_music = new Mydiss(music['id'], music['picurl'], music['title'], music['subtitle'])
  //       let list: string = data['data']['mydiss']['list'];
  //       for (let index = 0; index < list.length; index++) {
  //         user_info!.my_create?.push(new Mydiss(list[index]['dissid'], list[index]['picurl'],
  //           list[index]['title'], list[index]['subtitle']))
  //       }
  //
  //     }).catch((err: BusinessError) => {
  //     });
  //   return user_info!;
  // }


  /**
   * The method of initiating a POST request through RCP.
   */

  /**
   * The method of closing a RCP Session.
   */
  destroySession() {
    this.rcpSession.close();
  }
}