#!/bin/ruby
require_relative "./lib/omega"

forbidden_files = [
    "push_that.rb"
]

(Dir["*.rb"] + Dir["src/*.rb"]).each do |file|
    require_relative file if file != File.basename(__FILE__) and not forbidden_files.include?(file)
end

Gosu::enable_undocumented_retrofication

class TestState < Omega::State
    def load
        @bullets = [];

        slurp = SplitBullet.new("assets/textures/bullet/red_warp.png").set_angle(45).set_speed(7).set_split_number(8).set_lifespan(100).set_emitter(SpiralEmitter.new(@bullets).set_bullet_number(7).set_speed(4).set_split_bullet(Bullet.new("assets/textures/bullet/red_blade.png").set_sink(@bullets))).set_sink(@bullets).set_depth(1).set_split_factor(0.5).spawn();
        
        # @emitter = LinearEmitter.new(@bullets, Omega::Vector2.new(0, 100), Omega::Vector2.new(1000, 100)).set_speed(5).set_bullet_number(20).set_bullet(slurp)
    end
  
    def update()
        if (Omega.just_pressed(Gosu::KB_SPACE))
            if (Omega.paused?)
                Omega.play();
            else
                Omega.pause();
            end
        end
        if (Omega.just_pressed(Gosu::KB_RETURN))
            # @emitter.emit()
            # Omega.pause()
        end
        # @emitter.update()
        # if not @emitter.is_emitting?
            # Omega.play() if Omega.paused?
        # end
        return if (Omega.paused?)
        for bullet in @bullets
            bullet.update()
        end
    end
  
    def draw
        $camera.draw do
            for bullet in @bullets
                bullet.draw()
            end
        end
    end
end

class Game < Omega::RenderWindow
    $scale = 1
    $camera = Omega::Camera.new()
    $camera.scale = Omega::Vector2.new($scale, $scale)

    $tree = nil

    def load
        $game = self

        $camera = Omega::Camera.new($scale)
        transition = Omega::FadeTransition.new(5, Omega::Color::copy(Omega::Color::BLACK)) { Omega.set_state(TestState.new) }
        transition.alpha = 255

        Omega.launch_transition(transition)
    end

    def Game.is_just_pressed_ok
        return (Omega::just_pressed(Gosu::KB_X) or Omega::just_pressed(Gosu::KB_RETURN) or Omega::just_pressed(Gosu::GP_0_BUTTON_0))
    end

end

Omega.run(Game, "config.json")
