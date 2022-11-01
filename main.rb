#!/bin/ruby
require_relative "./lib/omega"

forbidden_files = [
    "push_that.rb"
]

(Dir["*.rb"] + Dir["src/*.rb"] + Dir["src/gui/*.rb"] + Dir["src/state/*.rb"] + Dir["src/gui/widget/*.rb"].reverse).each do |file|
    require_relative file if file != File.basename(__FILE__) and not forbidden_files.include?(file)
end

Gosu::enable_undocumented_retrofication

class TestState < Omega::State
    def load
        @bullets = [];


        # @bullets << SplitBullet.new("assets/textures/bullet/red_warp.png")
        #     .set_angle(rand(0..180))
        #     .set_speed(15)
        #     .set_split_number(10)
        #     .set_lifespan(50)
        #     .set_split(Bullet.new("assets/textures/bullet/red_blade.png"))
        #     .set_sink(@bullets)
        #     .set_depth(2)
        #     .set_split_factor(0.55);
        
            # Omega::draw_line(array[i - 1].toVector3, array[i].toVector3)
        @curve = QuadraticCurve.new().set_start(Omega::Vector2.new(100, 100)).set_end(Omega::Vector2.new(200, 200)).set_control(Omega::Vector2.new(100, 200))
        @curve2 = QuadraticCurve.new().set_start(Omega::Vector2.new(200, 200)).set_end(Omega::Vector2.new(300, 100)).set_control(Omega::Vector2.new(300, 200))
        @curve3 = QuadraticCurve.new().set_start(Omega::Vector2.new(300, 100)).set_end(Omega::Vector2.new(400, 200)).set_control(Omega::Vector2.new(400, 100))

        @button = GUI::Button.new().set_size(Omega::Vector2.new(128, 30)).set_scale(Omega::Vector2.new(2, 2)).set_position(Omega::Vector2.new(100, 100)).set_texture("assets/textures/gui/button.png")
        @text = GUI::Text.new().set_text("Hello").set_size(Omega::Vector2.new(256, 20)).set_position(Omega::Vector2.new(0, 10)).set_font($font).set_alignment(GUI::Text::Alignment::CENTER)

        @button.on_click do |button|
            button.disable
        end

        a = GUI::Button.new().set_size(Omega::Vector2.new(16, 16)).set_scale(Omega::Vector2.new(2, 2)).set_position(Omega::Vector2.new(100, 450)).set_texture("assets/textures/gui/button.png")

        a.on_click do
            @button.enable
        end

        @button.add(@text)

        group = GUI::Group.new().set_position(Omega::Vector2.new(500, 100)).add(@button.clone())

        @gui = Gui.new().set_position(Omega::Vector2.new(0, 0)).add(@button, a, group)

        # text = GUI::Text.new().set_text("Hello").set_font($font).set_size(Omega::Vector2.new(500, 10)).set_alignment(GUI::Text::Alignment::RIGHT)
        # @gui.add(text)

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
        if @button.enabled?
            @text.set_text("Enabled")
        else
            @text.set_text("Disabled")
        end
        @gui.update()
        for bullet in @bullets
            bullet.update()
        end
    end

    def draw
        $camera.draw do
            @curve.draw(25)
            @curve2.draw(25)
            @curve3.draw(25)
            @gui.draw()
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

    $font = Gosu::Font.new(35, name: "assets/SuperLegendBoy.ttf")

    $scale = 1
    $camera = Omega::Camera.new()
    $camera.scale = Omega::Vector2.new($scale, $scale)

    $tree = QuadTree.new(-250, -250, 1700, 1580)

    $bullet_sink = []

    $score = 0

    # Debug variables
    $debug = false
    $debug_flags = {
        :hitboxes => false,
        :gui => false
    }
    $combination = false
    $debug_pressed = false

    def load
        $game = self

        $camera = Omega::Camera.new($scale)
        transition = Omega::FadeTransition.new(5, Omega::Color::copy(Omega::Color::BLACK)) { Omega.set_state(PlayState.new) }
        # transition = Omega::FadeTransition.new(5, Omega::Color::copy(Omega::Color::BLACK)) { Omega.set_state(MenuState.new) }
        transition.alpha = 255

        Omega.launch_transition(transition)
    end

    def Game.is_just_pressed_ok
        return (Omega::just_pressed(Gosu::KB_X) or Omega::just_pressed(Gosu::KB_RETURN) or Omega::just_pressed(Gosu::GP_0_BUTTON_0))
    end

    def Game.debug
        if Omega::pressed(Gosu::KB_F3)
            if not $debug
                if Omega::just_pressed(Gosu::KB_B)
                    $debug = true
                    $combination = true
                    $debug_flags[:hitboxes] = true
                # elsif Omega::just_pressed(Gosu::KB_C)
                #     $debug = true
                #     $combination = true
                #     $debug_flags[:collisions] = true
                # elsif Omega::just_pressed(Gosu::KB_E)
                #     $debug = true
                #     $combination = true
                #     $debug_flags[:emitters] = true
                elsif Omega::just_pressed(Gosu::KB_H)
                    $debug = true
                    $combination = true
                    $debug_flags[:gui] = true
                end
            end
            $debug_pressed = true
        end
        if not Omega::pressed(Gosu::KB_F3) and $debug_pressed
            $debug_pressed = false
            if not $combination
                $debug = !$debug
                $debug_flags.each do |key, value|
                    $debug_flags[key] = false
                end
            end
            $combination = false
        end
    end
end

Omega.run(Game, "config.json")
