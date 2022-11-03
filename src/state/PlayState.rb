class PlayState < Omega::State

    def load
        @player = Player.new(Joystick.new(0))
        $player = @player

        @parallax = Omega::Parallax.new([Omega::Sprite.new("assets/nebula.png")])
        @parallax.scale = Omega::Vector2.new(4, 4)

        @player.set_position(Omega::Vector2.new(780 / 2, Omega.height * 0.8))

        @gui = Gui.new()

        # @boss = BossSoniaVA.new(@player)
        @boss = Cirno.new().set_position(Omega::Vector2.new(780 / 2, 100))

        @debug_text = Omega::Text.new("DEBUG MODE", $font)
        @debug_text.position.z = 100000000000

        @placeholders = [
            Omega::Rectangle.new(0, 0, 10, 1080),
            Omega::Rectangle.new(790, 0, 410, 1080),
            Omega::Rectangle.new(10, 0, 780, 10),
            Omega::Rectangle.new(10, 1070, 780, 10),
        ]

        for place in @placeholders
            place.color = Omega::Color.new(255, 50, 0, 25)
            place.position.z = 10000000
        end

        panel = GUI::Panel.new().set_position(Omega::Vector2.new(Omega.width - 400, 0)).set_scale(Omega::Vector2.new(2, 2)).set_tile_size(Omega::Vector2.new(48, 48)).set_texture("assets/textures/gui/panel.png").set_size(Omega::Vector2.new(200, 540))
        section = GUI::Section.new().set_size(Omega::Vector2.new(96, 96)).set_position(Omega::Vector2.new(48, 48))
        
        score_group = GUI::Group.new().set_position(Omega::Vector2.new(0, 0))
        score = GUI::Text.new().set_text("Score:").set_size(Omega::Vector2.new(96, 0)).set_font($font)
        @n = GUI::Text.new().set_text("#{$score}").set_size(Omega::Vector2.new(96, 0)).set_position(Omega::Vector2.new(0, 40)).set_font($font)

        placeholder = GUI::Section.new().set_size(Omega::Vector2.new(96, 96))

        boss_text = GUI::Text.new().set_text("Boss:").set_size(Omega::Vector2.new(96, 0)).set_font($font)
        @boss_life = GUI::ProgressBar.new().set_tile_size(Omega::Vector2.new(48, 20)).set_size(Omega::Vector2.new(144, 16)).set_scale(Omega::Vector2.new(2, 2)).set_position(Omega::Vector2.new(0, 80)).set_texture("assets/textures/gui/progress_bar.png").set_max(@boss._hp).set_value(@boss._hp)

        score_group.add(score, @n, placeholder, boss_text, @boss_life)
        section.add(score_group)
        panel.add(section)

        @gui.add(
            panel
        )

        # Some "Mode 7" clouds
        @ptex = PerspectiveTexture.new("assets/night_sky_filter_forge.png", Omega.width, Omega.height)
        @ptex.perspective_modifier = 50
        @ptex.base_perspective = 1.45
        @ptex.y = Omega.height - 500

        @tick = 0

        # Game Over Substate
        @substate = nil

        # MusiK
        @music = Gosu::Song.new("assets/musics/flandres_theme.ogg")
        @music.play(true)
        @volume ||= 0
    end

    def update_substate
        if not @player.is_alive? and not @substate
            @substate = GameOverState.new()
            @substate.load()
        end

        if @boss.is_dead? and not @substate
            @substate = WinState.new()
            @substate.load()
        end

        if @substate
            @volume -= (@volume - 0.1) * 0.05
            @substate.update
            if @substate.is_finished?
                @substate = nil
                $bullet_sink.clear
                load()
            end
            return true
        else
            @volume -= (@volume - 1) * 0.1
        end
        return false
    end

    def update
        Game.debug

        if $debug
            if Omega::just_pressed(Gosu::KB_K)
                @boss.hurt(10000000000)
            end
        end

        @music.volume = @volume # because the FRICKING VOLUME ATTRIBUTE IS WRITE ONLY GRAAAH
        
        return if update_substate()
        # $score += 10 if @tick % 60 == 0 and @tick != 0
        @n.set_text("#{$score}")
        @boss_life.set_value(@boss._hp)
        @gui.update
        @parallax.position.y += 1
        @player.update
        @boss.update
        @ptex.pz -= 1
        for bullet in $bullet_sink
            bullet.update()
            # if @player.hitbox.collides(bullet.hitbox) and bullet.hitbox.type == HitboxType::ENEMY_BULLET
            #     bullet.kill
            #     puts "PLAYER HIT"
            # end
            # if @boss.hitbox.collides(bullet.hitbox) and bullet.hitbox.type == HitboxType::PLAYER_BULLET
            #     bullet.kill
            #     puts "BOSS HIT"
            # end
        end
        @tick += 1
        $tree.update
    end

    def draw_substate
        @substate.draw if @substate
        return @substate != nil
    end

    def draw
        @parallax.draw
        # $tree.draw
        @ptex.draw
        @player.draw
        @boss.draw
        for bullet in $bullet_sink
            bullet.draw()
        end
        $tree.clear
        for place in @placeholders
            place.draw()
        end
        @gui.draw
        draw_substate()
        @debug_text.draw if $debug
        # $bullet_zone.draw()
    end
end