class PlayState < Omega::State

    def load
        @player = Player.new(Joystick.new(0))

        @parallax = Omega::Parallax.new([Omega::Sprite.new("assets/nebula.png")])
        @parallax.scale = Omega::Vector2.new(4, 4)

        @player.set_position(Omega::Vector2.new(Omega.width / 2, Omega.height * 0.8))

        @gui = Gui.new()

        panel = GUI::Panel.new().set_position(Omega::Vector2.new(Omega.width - 384, 0)).set_scale(Omega::Vector2.new(2, 2)).set_tile_size(Omega::Vector2.new(48, 48)).set_texture("assets/textures/gui/panel.png").set_size(Omega::Vector2.new(192, 528))
        section = GUI::Section.new().set_size(Omega::Vector2.new(96, 96)).set_position(Omega::Vector2.new(48, 48))
        
        score_group = GUI::Group.new().set_position(Omega::Vector2.new(0, 0))
        score = GUI::Text.new().set_text("Score:").set_size(Omega::Vector2.new(96, 0)).set_font($font)
        @n = GUI::Text.new().set_text("#{$score}").set_size(Omega::Vector2.new(96, 0)).set_position(Omega::Vector2.new(0, 40)).set_font($font)

        score_group.add(score, @n)
        section.add(score_group)
        panel.add(section)

        @gui.add(
            panel
        )

        @tick = 0

        @boss = BossSoniaVA.new(@player)

        a = Hitbox.new(0, 0, 48, 48, HitboxType::ENEMY)
        b = Hitbox.new(594, 858, 12, 12, HitboxType::PLAYER)

        puts a.collides?(b)

    end

    def update
        Game.debug
        # $score += 10 if @tick % 60 == 0 and @tick != 0
        @n.set_text("#{$score}")
        @gui.update
        @parallax.position.y += 1
        @player.update
        @boss.update
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

    def draw
        @parallax.draw
        # $tree.draw
        @player.draw
        @boss.draw
        for bullet in $bullet_sink
            bullet.draw()
        end
        $tree.clear
        @gui.draw
    end
end