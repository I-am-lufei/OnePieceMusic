import Mydiss from "./PlayList";

export default class UserInfo {
  name: string = '';
  headpic: string = '';
  my_music: Mydiss | null = null;
  my_create: Mydiss[] | null = null;
}