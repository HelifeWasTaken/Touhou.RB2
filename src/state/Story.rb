def text_introduction
  DialogList.new
    .add_dialog(
      TextBoxHandler.new
        .set_left_character($textures["marisa"], false)
        .add_text("It's bad of me to keep borrowing books,", true)
        .add_dialog_music($musics["simple_dialog"])
        .add_text("I don't even know where I am", true)
        .add_text("...", true)
    ).add_dialog(
      TextBoxHandler.new
        .set_right_character($textures["t1"], false)
        .set_left_character($textures["marisa"], false)
        .add_text("Who are you..?", true)
        .add_dialog_music($musics["pocket_watch"])
        .add_text("I am Sonia, a lost Youkai", false)
        .add_text("Descendant of the Rinnosuke family", false)
        .add_text("Now DIE!", false)
        .add_text("!!", true)
    )
end

def text_after_first_fight
  DialogList.new
    .add_dialog(
      TextBoxHandler.new
        .set_left_character($textures["marisa"], false)
        .set_right_character($textures["t1"], false)
        .add_text("Wow you sure are not like thoses other yokais", true)
        .add_dialog_music($musics["confrontation"])
        .add_text("And you sure do not know when to shut the hell up", false)
    )
end

def text_after_second_fight
  DialogList.new
    .add_dialog(
      TextBoxHandler.new
        .set_left_character($textures["marisa"], false)
        .set_right_character($textures["t1"], false)
        .add_text("You are starting to annoy me!!", false)
        .add_dialog_music($musics["necrofantasia"])
        .add_text("Can you just die?!!", false)
        .add_text("Welp no I still have books to read", true)
        .add_text("Wait what are you doing???!", true)
        .add_text("Gensokyo power...", false)
        .add_text("NO DO NOT USE THAT POWER", true)
        .add_text("Kongen kara kamigami e no gensō gō ga kite,-ryoku o ataemasu", false)
        .add_text("You leave me no choice", true)
        .add_text("Gensō gō no hai! Kodai no kami no chikara ga watashi ni yattekuru", true)
    )
end

def get_story_array
    [
      [text_introduction, $musics["flandre"]],
      [text_after_first_fight, $musics["faith"]],
      [text_after_second_fight, $musics["mokou"]]
    ]
end

def get_story_element(index)
  s = get_story_array()[index]
  if s
    return s[0].start
  end
  return nil
end

def story_size
  get_story_array.size
end

def get_fight_music_element(index)
  m = [$musics["mokou"]][index]
  if m
    return m[1]
  end
  return nil
end
