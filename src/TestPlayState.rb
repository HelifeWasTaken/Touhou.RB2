class TestPlayState < Omega::State

    def load
        # Fake player just for test purposes
        @test_player = Omega::SpriteSheet.new("assets/textures/character/player.png", 48, 48)
        @test_player.add_animation("PLAY", [0, 1, 2, 1], 0.2)
        @test_player.play_animation("PLAY")
        @test_player.set_position((Omega.width - @test_player.width_scaled) / 2, Omega.height - 200)
        @test_player.set_trail(true)

        # Add the boss
        @boss = BossSoniaVA.new(@test_player)

        # The parallax
        @parallax = Omega::Parallax.new([Omega::Sprite.new("assets/nebula.png")])
        @parallax.scale = Omega::Vector2.new(4, 4)

        # Some "Mode 7" clouds
        @ptex = PerspectiveTexture.new("assets/night_sky_filter_forge.png", Omega.width, Omega.height)
        @ptex.perspective_modifier = 50
        @ptex.base_perspective = 1.45
        @ptex.y = Omega.height - 500

        # Some music, because why play a game without music huh? Boring.
        @music = Gosu::Song.new("assets/musics/flandres_theme.ogg")
        @music.play(true)
    end

    def update
        @test_player.debug_move(10)
        @test_player.z = 10_000

        @boss.update
        @boss.z = 10_000


        @ptex.pz -= 1

        @parallax.position.y += 1
    end

    def draw
        @parallax.draw
        @test_player.draw
        @boss.draw
        @ptex.draw
    end

end