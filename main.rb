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

"
 .add_behaviour(ParametricBehaviour.new
                    .set_limits(0, 10)
                    .set_color(Omega::Color::YELLOW)
                    .set_step(1.0)
                    .set_lifetime(300)
                )
"



class OtherTestState < Omega::State
    def load
        @circles = []

        a = 0
        for i in 0..20
            m = MixedCastBehaviour.new()

            m.add_behaviour(
                ParametricBehaviour.new
                    .set_limits(-200, 200)
                    .set_color(Omega::Color.new(rand(0..255), rand(0..255), rand(0..255)))
                    .set_step(2)
                    .set_constants(a, 2, a)
                    .set_t(200)
                    .set_go_up(false)
                    .set_lifetime(2000)
            )

            for i in 0..2
                m.add_behaviour(
                    BasicCastBehaviour.new
                        .set_angle_speed(20)
                        .set_min_scale(0.2)
                        .set_max_scale(4)
                        .set_scale_speed(0.2)
                        .set_color(Omega::Color.new(rand(0..255), rand(0..255), rand(0..255)))
                        .set_lifetime(30))
            end

           circle = CastCircle.new("assets/textures/misc/main_spell.png", m)
           circle.position = Omega::Vector3.new(Omega.width / 2, Omega.height / 2, 0)

           a += 2 * 0.5

           @circles << circle
        end

    end

    def update
      @circles.each do |circle|
        circle.update
      end
    end

    def draw
        $camera.draw do
          @circles.each do |circle|
            circle.draw
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
        transition = Omega::FadeTransition.new(5, Omega::Color::copy(Omega::Color::BLACK)) { Omega.set_state(TestPlayState.new) }
        transition.alpha = 255

        Omega.launch_transition(transition)
    end

    def Game.is_just_pressed_ok
        return (Omega::just_pressed(Gosu::KB_X) or Omega::just_pressed(Gosu::KB_RETURN) or Omega::just_pressed(Gosu::GP_0_BUTTON_0))
    end

end

Omega.run(Game, "config.json")
