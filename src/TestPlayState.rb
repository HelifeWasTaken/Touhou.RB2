class TestPlayState < Omega::State

    def load
        # Fake player just for test purposes
        @test_player = Omega::SpriteSheet.new("assets/textures/character/player.png", 48, 48)
        @test_player.add_animation("PLAY", [0, 1, 2, 1], 0.2)
        @test_player.play_animation("PLAY")

        # Add the boss
        @boss = BossSoniaVA.new(@test_player)
    end

    def update
        @test_player.debug_move
        @boss.update
    end

    def draw
        @test_player.draw
        @boss.draw
    end

end