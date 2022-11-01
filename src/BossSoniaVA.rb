class BossSoniaVA < Omega::SpriteSheet

    BASIC_SHOTS = 0
    X_KNIFE = 1
    CIRCULAR_BULLET_EXPLOSION = 2

    KNIFES_CIRCLES = 4
    MAX_KNIFE_COUNT = 14 * KNIFES_CIRCLES
    KNIFES_AREA = 300

    PATTERNS_DURATION = 20

    def initialize(player)
        super("assets/textures/character/whiterock.png", 48, 48)

        @player = player
        @current_pattern = BASIC_SHOTS
        @phase = 1

        @phase_patterns = {
            BASIC_SHOTS => [Omega::Vector2.new(-300, 0),
                            Omega::Vector2.new(0, 100),
                            Omega::Vector2.new(300, 0),
                            Omega::Vector2.new(75, 200),
                            Omega::Vector2.new(0, 300),
                            Omega::Vector2.new(-75, 200)],
            X_KNIFE => [Omega::Vector2.new(-400, 40),
                        Omega::Vector2.new(0, 0),
                        Omega::Vector2.new(400, 40)],
            CIRCULAR_BULLET_EXPLOSION => [Omega::Vector2.new(0, 0),
                                          Omega::Vector2.new(100, 0),
                                          Omega::Vector2.new(200, 100),
                                          Omega::Vector2.new(300, 200),
                                          Omega::Vector2.new(0, 300),
                                          Omega::Vector2.new(-300, 200),
                                          Omega::Vector2.new(-200, 100),
                                          Omega::Vector2.new(-100, 0),]
        }

        # @bullets = []
        @frame_timer = 0
        @frames_counter = 0
        @current_pattern_pos = 0
        @stop_update = false
        @freeze_list = []
        @can_move = true

        @hitbox = BossCollider.new(self, 0, 0, 48, 48)

        @shot_sound = Gosu::Sample.new("assets/sounds/shot.wav")
        @knife_sound = Gosu::Sample.new("assets/sounds/knife.wav")

        set_origin(0.5)
    end

    def update
        $tree.insert(@hitbox.collision)
        # return
        @center ||= Omega::Vector3.new((Omega.width - width_scaled) / 2, 150, 0)
        @launched ||= false
        @position.update_easing()
        
        @hitbox.update_collider_position(@position.x - @hitbox.collision.w / 2.0, @position.y - @hitbox.collision.h / 2.0)

        case @current_pattern
        when BASIC_SHOTS
            basic_shots()
        when X_KNIFE
            x_knife()
        when CIRCULAR_BULLET_EXPLOSION
            circular_bullet_explosion()
        end
        @frames_counter += 1
        @frame_timer += 1

        if not @launched
            @position.move_to(@center)
            @launched = true
        end

        if @phase == 1
            if not @position.is_easing?() and @can_move
                @position.move_to(@center + @phase_patterns[@current_pattern][@current_pattern_pos].to_vector3())
                @current_pattern_pos += 1
                @current_pattern_pos %= @phase_patterns[@current_pattern].size
            end
        end
    end

    def basic_shots
        if @phase == 1 or @position.distance2d(@center) < 2
            @phase = 1

            if @frame_timer >= 8
                shoot_angle = Omega::to_deg(Math::atan2((@player.y - @position.y), (@player.x - @position.x)))

                Bullet.new("assets/textures/bullet/red_warp.png")
                            .set_speed(5) # Speed de la bullet
                            .set_angle(shoot_angle) # l'angle en grade
                            .set_sink($bullet_sink) # obligatoire sinon ça va crash
                            .set_position(@position.clone + Omega::Vector2.new(width_scaled / 2, height_scaled / 2).to_vector3) # kek
                            .spawn() # le push sur la liste

                Bullet.new("assets/textures/bullet/red_warp.png")
                            .set_speed(5) # Speed de la bullet
                            .set_angle(shoot_angle - 40) # l'angle en grade
                            .set_sink($bullet_sink) # obligatoire sinon ça va crash
                            .set_position(@position.clone + Omega::Vector2.new(width_scaled / 2, height_scaled / 2).to_vector3) # kek
                            .spawn() # le push sur la liste

                Bullet.new("assets/textures/bullet/red_warp.png")
                            .set_speed(5) # Speed de la bullet
                            .set_angle(shoot_angle + 40) # l'angle en grade
                            .set_sink($bullet_sink) # obligatoire sinon ça va crash
                            .set_position(@position.clone + Omega::Vector2.new(width_scaled / 2, height_scaled / 2).to_vector3) # kek
                            .spawn() # le push sur la liste

                @shot_sound.play(0.2)

                @frame_timer = 0

                if @frames_counter > PATTERNS_DURATION * 60
                    @current_pattern = X_KNIFE
                    @current_pattern_pos = 0
                    @frames_counter = 0
                    @phase = 0
                    @launched = false
                end
            end
        end
    end

    def x_knife
        @knifes_count ||= 0
        if @phase == 1 or @position.distance2d(@center) < 2
            if @knifes_count < MAX_KNIFE_COUNT and @frame_timer > 1 and not @position.is_easing?
                KNIFES_CIRCLES.times do |i|
                    @can_move = false
                    dist_to_boss = KNIFES_AREA / (i + 1)
                    knife_position = Omega::Vector2.new(@position.x - dist_to_boss * Math::cos(Omega::to_rad(@knifes_count * 25.0 / KNIFES_CIRCLES + 90 / KNIFES_CIRCLES)) + width_scaled / 2,
                                                        @position.y - dist_to_boss * Math::sin(Omega::to_rad(@knifes_count * 25.0 / KNIFES_CIRCLES + 90 / KNIFES_CIRCLES)) + height_scaled / 2)
                    shoot_angle = Omega::to_deg(Math::atan2((@player.y - knife_position.y), (@player.x - knife_position.x)))
                    bullet = Bullet.new("assets/textures/bullet/red_blade.png")
                                                .set_speed(8) # Speed de la bullet
                                                .set_angle(shoot_angle) # l'angle en grade
                                                .set_sink($bullet_sink) # obligatoire sinon ça va crash
                                                .set_position(knife_position) # kek
                                                .spawn() # le push sur la liste
                    bullet.set_trail(true, 10, 2)
                    @freeze_list << bullet.get_id()
                    @knifes_count += 1
                    if @knifes_count == MAX_KNIFE_COUNT
                        @freeze_list = []
                        @knifes_count = 0
                        @can_move = true
                    end
                    @frame_timer = 0
                end
                @knife_sound.play() if (@knifes_count / KNIFES_CIRCLES) % 2 == 1
                @phase = 1
            end

            if @frames_counter > PATTERNS_DURATION * 60
                @current_pattern = CIRCULAR_BULLET_EXPLOSION
                @current_pattern_pos = 0
                @frames_counter = 0
                @phase = 0
                @launched = false
            end
        end
    end

    def circular_bullet_explosion
        @circular_angle ||= 0
        @circular_angle_side ||= :right
        if @phase == 1 or @position.distance2d(@center) < 2
            if @frame_timer > 5
                shoot_angle = 0
                speed = 8
                Bullet.new("assets/textures/bullet/blue_warp.png")
                            .set_speed(speed) # Speed de la bullet
                            .set_angle(@circular_angle) # l'angle en grade
                            .set_sink($bullet_sink) # obligatoire sinon ça va crash
                            .set_position(@position.clone + Omega::Vector2.new(width_scaled / 2, height_scaled / 2).to_vector3) # kek
                            .spawn() # le push sur la liste

                Bullet.new("assets/textures/bullet/blue_warp.png")
                            .set_speed(speed) # Speed de la bullet
                            .set_angle(@circular_angle + 45) # l'angle en grade
                            .set_sink($bullet_sink) # obligatoire sinon ça va crash
                            .set_position(@position.clone + Omega::Vector2.new(width_scaled / 2, height_scaled / 2).to_vector3) # kek
                            .spawn() # le push sur la liste

                Bullet.new("assets/textures/bullet/blue_warp.png")
                            .set_speed(speed) # Speed de la bullet
                            .set_angle(@circular_angle + 90) # l'angle en grade
                            .set_sink($bullet_sink) # obligatoire sinon ça va crash
                            .set_position(@position.clone + Omega::Vector2.new(width_scaled / 2, height_scaled / 2).to_vector3) # kek
                            .spawn() # le push sur la liste

                Bullet.new("assets/textures/bullet/blue_warp.png")
                            .set_speed(speed) # Speed de la bullet
                            .set_angle(@circular_angle + 135) # l'angle en grade
                            .set_sink($bullet_sink) # obligatoire sinon ça va crash
                            .set_position(@position.clone + Omega::Vector2.new(width_scaled / 2, height_scaled / 2).to_vector3) # kek
                            .spawn() # le push sur la liste

                Bullet.new("assets/textures/bullet/blue_warp.png")
                            .set_speed(speed) # Speed de la bullet
                            .set_angle(@circular_angle + 180) # l'angle en grade
                            .set_sink($bullet_sink) # obligatoire sinon ça va crash
                            .set_position(@position.clone + Omega::Vector2.new(width_scaled / 2, height_scaled / 2).to_vector3) # kek
                            .spawn() # le push sur la liste

                Bullet.new("assets/textures/bullet/blue_warp.png")
                            .set_speed(speed) # Speed de la bullet
                            .set_angle(@circular_angle + 225) # l'angle en grade
                            .set_sink($bullet_sink) # obligatoire sinon ça va crash
                            .set_position(@position.clone + Omega::Vector2.new(width_scaled / 2, height_scaled / 2).to_vector3) # kek
                            .spawn() # le push sur la liste

                Bullet.new("assets/textures/bullet/blue_warp.png")
                            .set_speed(speed) # Speed de la bullet
                            .set_angle(@circular_angle + 270) # l'angle en grade
                            .set_sink($bullet_sink) # obligatoire sinon ça va crash
                            .set_position(@position.clone + Omega::Vector2.new(width_scaled / 2, height_scaled / 2).to_vector3) # kek
                            .spawn() # le push sur la liste

                Bullet.new("assets/textures/bullet/blue_warp.png")
                            .set_speed(speed) # Speed de la bullet
                            .set_angle(@circular_angle + 315) # l'angle en grade
                            .set_sink($bullet_sink) # obligatoire sinon ça va crash
                            .set_position(@position.clone + Omega::Vector2.new(width_scaled / 2, height_scaled / 2).to_vector3) # kek
                            .spawn() # le push sur la liste

                @can_move = true
                @phase = 1
                @circular_angle += 1
                @frame_timer = 0

                @shot_sound.play(0.2)

                if @frames_counter > PATTERNS_DURATION * 60
                    @current_pattern = BASIC_SHOTS
                    @current_pattern_pos = 0
                    @frames_counter = 0
                    @phase = 0
                    @launched = false
                end
            end
        end
    end

    def draw
        super()
        # @bullets.each do |bullet|
        #     bullet.update() if not @stop_update and not @freeze_list.include?(bullet.get_id)
        #     bullet.draw()
        # end
        @hitbox.draw if $debug_flags[:hitboxes]
    end

end