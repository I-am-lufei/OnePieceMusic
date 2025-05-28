import { LyricLine } from '../common/LyricLine'

export class LrcParser {
  parse_str(lrcContent: string): LyricLine[] {
    const lines = lrcContent.split('\n');
    const lyrics: LyricLine[] = [];

    const timeRegex = /\[(\d{2}):(\d{2})\.(\d{2,3})\]/; // 匹配 [mm:ss.xx] 或 [mm:ss.xxx]

    for (const line of lines) {
      const match = timeRegex.exec(line);
      if (match) {
        const minutes = parseInt(match[1]);
        const seconds = parseInt(match[2]);
        const milliseconds = parseInt(match[3].padEnd(3, '0')); // .xx 补齐为 .xx0
        const time = minutes * 60 * 1000 + seconds * 1000 + milliseconds;
        const text = line.substring(match[0].length).trim();
        if (text) { // 忽略空歌词行
          lyrics.push({ time, text });
        }
      }
    }
    // 按时间排序
    return lyrics.sort((a, b) => a.time - b.time);
  }
}