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


        @bullets << SplitBullet.new("assets/textures/bullet/red_warp.png")
            .setAngle(rand(0..180))
            .setSpeed(15)
            .setSplitNumber(10)
            .setLifespan(50)
            .setSplit(Bullet.new("assets/textures/bullet/red_blade.png"))
            .setSink(@bullets)
            .setDepth(2)
            .setSplitFactor(0.55);

        # @emitter = LinearEmitter.new(@bullets, Omega::Vector2.new(0, 100), Omega::Vector2.new(1000, 100)).setSpeed(5).setBulletNumber(20)
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
        # if not @emitter.isEmitting?
            # Omega.play() if Omega.paused?
        # end
        # return if (Omega.paused?)
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

class OtherTestState < Omega::State

    def load
        @circle = CastCircle.new(
            "assets/textures/misc/main_spell.png",
            800,
            ParametricBehaviour.new
                .set_limits(0, 200)
                .set_color(Omega::Color::YELLOW)
                .set_step(1.0)
       )

       @circle.position = Omega::Vector3.new(400, 500, 0)

       FixedToInstantCastBehaviour.new()
                .set_fixed_angle_speed(6)
                .set_instant_angle_speed(12)
                .set_scale_target(3)
                .set_scale_speed(0.4)
                .set_fixed_color(Omega::Color::RED)
                .set_instant_color(Omega::Color::BLUE)
                .set_min_scale(0.5)
                .set_tick_to_instant(50)
 
    end

    def update
        @circle.update
    end

    def draw
        $camera.draw do
            @circle.draw
        end
    end

end

class Game < Omega::RenderWindow
    $scale = 1
    $camera = Omega::Camera.new()
    $camera.scale = Omega::Vector2.new($scale, $scale)

    def load
        $game = self

        $camera = Omega::Camera.new($scale)
        transition = Omega::FadeTransition.new(5, Omega::Color::copy(Omega::Color::BLACK)) { Omega.set_state(OtherTestState.new) }
        transition.alpha = 255

        Omega.launch_transition(transition)
    end

    def Game.is_just_pressed_ok
        return (Omega::just_pressed(Gosu::KB_X) or Omega::just_pressed(Gosu::KB_RETURN) or Omega::just_pressed(Gosu::GP_0_BUTTON_0))
    end

end

Omega.run(Game, "config.json")
