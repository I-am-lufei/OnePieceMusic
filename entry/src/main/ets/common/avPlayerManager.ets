import { media } from '@kit.MediaKit'
import { LyricLine } from '../common/LyricLine'
import { promptAction } from '@kit.ArkUI';
import { LrcParser } from '../common/LyricParser';
import curPlaySong from '../viewModel/curPlaySong';
import SongInfo from '../viewModel/SongInfo';
import DataBase, { PlayListItem } from './Database';
import Album from '../viewModel/Album';
import Singer from '../viewModel/Singer';
import PlayList from '../viewModel/PlayList';
import { RankDetail } from '../viewModel/RankDetail';

export class avPlayerManager {
  player: media.AVPlayer | null = null;
  isFirst: boolean = true;
  total_time: number = 0;
  lyrics: LyricLine[] = [{ time: 0, text: '歌词未加载' }];
  parser: LrcParser = new LrcParser();
  currentLyricIndex: number = 0;
  currentTimeMs: number = 0; // 当前播放时间 (毫秒)
  isPlaying: boolean = false;
  isPrepared: boolean = false;
  isCompleted: boolean = false;
  isShowPlayPage: boolean = false;
  search_tags_list: string[] = [];
  Rank_Detail: RankDetail = new RankDetail('', '', [])
  play_mode = 0;
  database: DataBase = new DataBase();
  cur_play_song: curPlaySong = new curPlaySong();
  self_create_playlist: PlayListItem[] = [];
  liked_playlist: PlayListItem[] = [];
  scroller: Scroller = new Scroller();
  cur_song_item: SongInfo = new SongInfo(0, '', '', '', '', '', '', '', '');
  cur_singer_item: Singer = new Singer();
  cur_album_item: Album = new Album();
  cur_playlist_item: PlayList = new PlayList('', '', '', '', '');

  async init() {
    this.player = await media.createAVPlayer();
    this.player.on('stateChange', async (state) => {
      if (state === 'initialized') {
        this.player?.prepare();
      } else if (state === 'prepared') {
        this.isPlaying = false;
        this.isPrepared = true;
        this.isCompleted = false;
        this.currentLyricIndex = 0;
        if (!this.isFirst) {
          this.player?.play();
        }
        promptAction.showToast({
          message: 'prepared'
        })
      } else if (state === 'playing') {
        promptAction.showToast({
          message: 'playing'
        })
        this.isPlaying = true;
        this.isPrepared = false;
        this.isCompleted = false;
        this.isFirst = false;
        await this.database.query_song_mid(this.cur_song_item.song_mid)
          .then((val) => {
            if (val.length > 0) {
              this.database.update_recently_time(0, this.cur_song_item.song_mid)
            } else {
              this.database.insert_song(this.cur_song_item, '0', '1')
            }
          })
      } else if (state === 'paused') {
        this.isPlaying = false;
        this.isPrepared = false;
        this.isCompleted = false;
      } else if (state === 'completed') {
        this.isPlaying = false;
        this.isPrepared = false;
        this.isCompleted = true;
        promptAction.showToast({
          message: 'completed'
        })
        this.isShowPlayPage = false;
        await this.calCurModeNextIndex().then(() => {
          this.isShowPlayPage = true;
        });
      }
    })
    this.player.on('durationUpdate', (duration) => {
      this.total_time = duration;
      promptAction.showToast({
        message: this.total_time.toString()
      })
    })
    this.player.on('timeUpdate', (time) => { // time 单位是毫秒
      this.currentTimeMs = time;
      this.updateCurrentLyric(time);
    });
  }

  ToLyric(lyric: string) {
    let newIndex: number = 0;
    // 倒序查找，效率更高，找到第一个小于等于当前时间的歌词
    for (let i = this.lyrics.length - 1; i >= 0; i--) {
      if (lyric === this.lyrics[i].text) {
        newIndex = i;
        break;
      }
    }
    this.SongSeek(this.lyrics[newIndex].time);
  }

  updateCurrentLyric(timeMs: number) {
    // console.log('index----' + this.lyrics[0].text)
    if (!this.lyrics || this.lyrics.length === 0) {
      return;
    }

    let newIndex = 0;
    // 倒序查找，效率更高，找到第一个小于等于当前时间的歌词
    for (let i = this.lyrics.length - 1; i >= 0; i--) {
      if (timeMs >= this.lyrics[i].time) {
        newIndex = i;
        break;
      }
    }

    // 如果是播放开始前（还没到第一句歌词时间），可以保持-1或设为0
    if (newIndex === -1 && this.lyrics.length > 0 && timeMs < this.lyrics[0].time) {
      this.currentLyricIndex = 0;
    }

    if (newIndex !== this.currentLyricIndex) {
      if (newIndex >= 0) {
        this.currentLyricIndex = newIndex;
      }
      if (this.currentLyricIndex >= 0) {
        // 滚动到视图中央
        this.scroller.scrollToIndex(this.currentLyricIndex, true, ScrollAlign.CENTER);
      }
    }
  }

  async songPlay() {
    if (this.isFirst) {
      this.isFirst = false;
    }
    console.log('play---' + this.lyrics[0].text + '++++' + this.currentLyricIndex)
    await this.player?.play();
  }

  async songPause() {
    await this.player?.pause();
  }

  async SongSeek(time: number) {
    this.player?.seek(time);
    console.log('play---seek---' + this.lyrics[0].text + '++++' + this.currentLyricIndex)
  }

  async SongStop() {
    await this.player?.stop();
  }

  async songReset(url: string) {
    await this.player?.reset().then(() => {
      this.player!.url = url;
    });
  }

  async changeSong() {
    this.isFirst = false;
    this.currentLyricIndex = 0;
    this.cur_song_item = this.cur_play_song.songList[this.cur_play_song.curPlayIndex];
    this.lyrics = this.parser.parse_str(this.cur_song_item.lyric);//赋值1
    await this.songReset(this.cur_song_item.mp3_url);
  }

  async calCurModeNextIndex() {
    if (this.play_mode === 0) {
      this.cur_play_song.curPlayIndex = this.cur_play_song.curPlayIndex;
    } else if (this.play_mode === 1) {
      this.cur_play_song.curPlayIndex++;
      if (this.cur_play_song.curPlayIndex >= this.cur_play_song.songList.length) {
        this.cur_play_song.curPlayIndex = 0;
      }
    } else {
      let tmp: number = this.cur_play_song.curPlayIndex;
      while (tmp === this.cur_play_song.curPlayIndex) {
        this.cur_play_song.curPlayIndex = Math.floor(Math.random() * this.cur_play_song.songList.length);
      }
    }
    await this.changeSong();
  }


  async playPre() {
    this.cur_play_song.curPlayIndex--;
    if (this.cur_play_song.curPlayIndex < 0) {
      this.cur_play_song.curPlayIndex = this.cur_play_song.songList.length - 1;
    }
    await this.changeSong();
  }

  async playSelected(song: SongInfo) {
    let index: number = this.cur_play_song.songList.findIndex(item => item === song);
    if (index === -1) {
      this.cur_play_song.songList.push(song);
      this.cur_play_song.curPlayIndex = this.cur_play_song.songList.length - 1;
    } else {
      this.cur_play_song.curPlayIndex = index;
    }
    await this.changeSong();
  }

  async playNext() {
    this.cur_play_song.curPlayIndex++;
    if (this.cur_play_song.curPlayIndex >= this.cur_play_song.songList.length) {
      this.cur_play_song.curPlayIndex = 0;
    }
    this.isShowPlayPage = false;
    await this.changeSong().then(() => {
      this.isShowPlayPage = true;
    });
  }
}
