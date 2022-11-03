class GameOverState < Omega::State

    TARGET_LOGO_SCALE = 2.5
    DEFAULT_TEXT_SCALE = 3.5
    FINAL_GLOBAL_SCALE = 4.0

    def load
        # Spell thingy
        @spell_logo = Omega::Sprite.new("assets/textures/misc/main_spell.png")
        @spell_logo.set_origin(0.5)
        @spell_logo.set_scale(20)
        @spell_logo.alpha = 0
        @spell_logo.position = Omega::Vector3.new((Omega.width / 2), (Omega.height / 2), 0)

        # Filter colors
        @color = Omega::Color.new(0, 255, 32, 32)
        @quit_color = Omega::Color.new(0, 0, 0, 0)

        # Texts
        @gameover_text = Omega::Text.new("Game Over", $font)
        @gameover_text.set_scale(3.5)
        @gameover_text.position = Omega::Vector3.new((Omega.width - @gameover_text.width) / 2,
                                                    (Omega.height - @gameover_text.height) / 2 - 2, 0)

        @choices_text = Omega::Text.new("What will you do?", $font)
        @choices_text.set_scale(1.1)
        @choices_text.alpha = 0

        # Useful variables
        @global_scale = 1.0
        @phase = 0
        @gameover_text_offset = 0
        @choices = ["Try again", "Quit"]
        @choice_index = 0
        @channel = nil

        # Swoosh!
        $sounds["swoosh"].play()
    end

    def update_spell_logo
        @spell_logo.position.x -= @spell_logo.position.x * (@spell_logo.scale.x * 0.01) if @phase == 1
        @spell_logo.alpha += 5 if @spell_logo.alpha < 255
        @spell_logo.scale.x -= (@spell_logo.scale.x - TARGET_LOGO_SCALE * @global_scale) * 0.1
        @spell_logo.scale.y -= (@spell_logo.scale.y - TARGET_LOGO_SCALE * @global_scale) * 0.1
        @spell_logo.angle += 1
    end

    def update_filter_color
        @color.alpha = (@color.alpha + 3).clamp(0, 128)
    end

    def update
        case @phase
        when 0
            if Omega::just_pressed(Gosu::KB_RETURN) and @gameover_text_offset >= @gameover_text.height
                @phase = 1
                $sounds["swoosh_1"].play()
            end
        when 1
            @global_scale -= (@global_scale - FINAL_GLOBAL_SCALE) * 0.16
            if Omega::just_pressed(Gosu::KB_RETURN)
                @phase = (@choice_index == 0) ? 2 : 3
                @channel = $sounds["swoosh_2"].play()
                $sounds["accept"].play()
            elsif Omega::just_pressed(Gosu::KB_W)
                @choice_index = (@choice_index + 1) % @choices.size
                $sounds["click"].play()
            elsif Omega::just_pressed(Gosu::KB_S)
                @choice_index = (@choice_index - 1) % @choices.size
                $sounds["click"].play()
            end
        when 2, 3
            @global_scale *= 1.03
            @choices_text.alpha = (@choices_text.alpha - 10).clamp(0, 255)
            @spell_logo.alpha = (@spell_logo.alpha - 10).clamp(0, 255)
            @color.alpha = (@color.alpha - 10).clamp(0, 255)
            if @phase == 3
                if @quit_color.alpha == 255 and (not @channel or not @channel.playing?)
                    Omega.close
                end
                @quit_color.alpha = (@quit_color.alpha + 10).clamp(0, 255)
            end
        end
        
        update_spell_logo()
        update_filter_color()
    end

    def draw_gameover_text
        @gameover_text.alpha = (@gameover_text.alpha - 10).clamp(0, 255) if @phase > 0
        Gosu.clip_to(0, (@phase > 0) ? 0 : @gameover_text.position.y, Omega.width, (@phase > 0) ? Omega.height : @gameover_text_offset) do
            @gameover_text.draw()
        end
        @gameover_text.scale.x -= (@gameover_text.scale.x - DEFAULT_TEXT_SCALE * @global_scale) * 0.1
        @gameover_text.scale.y -= (@gameover_text.scale.y - DEFAULT_TEXT_SCALE * @global_scale) * 0.1
        
        @gameover_text.position = Omega::Vector3.new((Omega.width - @gameover_text.width) / 2,
                                            (Omega.height - @gameover_text.height) / 2, 0)
        @gameover_text_offset += @gameover_text.scale.x if @gameover_text_offset < @gameover_text.height and Omega.frame_count % 2 == 1
    end

    def draw_choices
        if @global_scale.round == FINAL_GLOBAL_SCALE
            @choices_text.color = Gosu::Color::WHITE
            @choices_text.text = "What will you do?"
            @choices_text.alpha = (@choices_text.alpha + 10).clamp(0, 255)
            @choices_text.position = Omega::Vector3.new((Omega.width - @choices_text.width) / 2 + 300,
                                                        (Omega.height - @choices_text.height) / 2 - 100, 0)
            @choices_text.draw()

            @choices_text.position.y += @choices_text.height + 20
            @choices.each_with_index do |choice, i|
                choice_open = "  "
                choice_open[0] = ">" if i == @choice_index
                @choices_text.color = Gosu::Color::WHITE
                @choices_text.color = Gosu::Color::YELLOW if i == @choice_index
                @choices_text.text = choice_open + choice
                @choices_text.set_scale(1.1)
                @choices_text.position.y += @choices_text.height + 20
                @choices_text.draw()
            end
        end
    end

    def draw
        Gosu.draw_rect(0, 0, Omega.width, Omega.height, @color, 0)
        @spell_logo.draw
        draw_gameover_text()
        draw_choices()
        Gosu.draw_rect(0, 0, Omega.width, Omega.height, @quit_color, 0) if @quit_color.alpha
    end

end
