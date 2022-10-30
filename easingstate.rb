class EasingState < Omega::State

    def load
        @sprite = Omega::Sprite.new("assets/textures/bullet/red_warp.png")
        @sprite.position.move_to(Omega::Vector2.new(100, 100).to_vector3())
    end

    def update
        if Omega::just_pressed(Gosu::MS_LEFT)
            @sprite.position.move_to(Omega.mouse_position.to_vector3(), :ease_in_out_back, 0.02)
        end

        @sprite.position.update_easing()
    end

    def draw
        @sprite.draw()
    end

end
