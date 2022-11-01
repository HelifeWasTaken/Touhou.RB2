module GUI
    
    class Widget

        # protected
            
        attr_accessor :position, :size, :tile_size, :scale, :_texture, :_tiles, :_rect, :_idle, :_hover, :_pressed, :_click, :_input, :_active, :_enabled, :_parent, :_was_pressed

        public

        def initialize()
            # Basic Data
            @position = Omega::Vector2.new(0, 0)
            @size = Omega::Vector2.new(0, 0)
            @tile_size = Omega::Vector2.new(16, 16)
            @scale = Omega::Vector2.new(1, 1)

            # Drawing Data
            @_texture = nil
            @_tiles = []

            # Bounding Data
            @_rect = Omega::Rectangle.new(0, 0, 0, 0)

            # GUI Data
            @_active = true
            @_enabled = true

            @_parent = nil

            # Misc Data
            @_was_pressed = false

            # Event Data
            @_idle = nil
            @_hover = nil
            @_pressed = nil
            @_click = nil
            @_input = nil
        end

        def initialize_copy(other)
            self.position = other.position.clone
            self.size = other.size.clone
            self.tile_size = other.tile_size.clone
            self.scale = other.scale.clone
            self._tiles = other._tiles.clone
            self._rect = other._rect.clone
            self._idle = other._idle.clone
            self._hover = other._hover.clone
            self._pressed = other._pressed.clone
            self._click = other._click.clone
            self._input = other._input.clone
            super(other)
        end

        protected

        def __reload()
            self._rect.x = self.position.x
            self._rect.y = self.position.y
            self._rect.width = self.size.x * self.scale.x
            self._rect.height = self.size.y * self.scale.y
        end

        public

        def set_position(position_)
            self.position = position_
            __reload
            return self
        end

        def set_size(size_)
            self.size = size_
            __reload
            return self
        end

        def set_tile_size(tile_size_)
            self.tile_size = tile_size_
            return self
        end

        def set_scale(scale_)
            self.scale = scale_
            __reload
            return self
        end

        def set_texture(texture_)
            self._texture = texture_
            self._tiles = Gosu::Image.load_tiles(self._texture, self.tile_size.x, self.tile_size.y, {})
            return self
        end

        def set_parent(parent_)
            self._parent = parent_
            return self
        end

        def get_position(local = true)
            pos = self.position
            parent = get_parent
            return pos if local
            while parent != nil
                pos += parent.get_position
                parent = parent.get_parent
            end
            return pos
        end

        def get_size(local = false)
            return self.size if local
            return Omega::Vector2.new(self.size.x * self.scale.x, self.size.y * self.scale.y)
        end

        def get_scale()
            return self.scale
        end

        def get_rect()
            return self._rect
        end

        def get_parent()
            return self._parent
        end

        def is_hovered?()
            return get_rect.contains?(Omega.mouse_position)
        end

        def is_pressed?()
            return (self.is_hovered? and Omega.pressed(Gosu::MS_LEFT))
        end

        def enable()
            self._enabled = true
        end

        def disable()
            self._enabled = false
        end
        
        def enabled?()
            return self._enabled
        end

        def active?()
            return self._active
        end

        def idle()
            self._idle.call(self) if not self._idle.nil?
        end
        def hover()
            self._hover.call(self) if not self._hover.nil?
        end
        def pressed()
            self._was_pressed = true
            self._pressed.call(self) if not self._pressed.nil?
        end
        def click()
            self._click.call(self) if not self._click.nil?
        end
        def input()
            self._input.call(self) if not self._input.nil?
        end

        def on_idle(&event)
            self._idle = event
        end
        
        def on_hover(&event)
            self._hover = event
        end
        
        def on_pressed(&event)
            self._pressed = event
        end
        
        def on_click(&event)
            self._click = event
        end
        
        def on_input(&event)
            self._input = event
        end

        def update()
            return if not enabled?
            if self.is_hovered?
                self.hover
                if Omega.pressed(Gosu::MS_LEFT)
                    self.pressed
                end
                if not Omega.pressed(Gosu::MS_LEFT) and self._was_pressed
                    self._was_pressed = false
                    self.click
                end
            else
                self.idle
                if not Omega.pressed(Gosu::MS_LEFT) or self._was_pressed
                    self._was_pressed = false
                end
            end
            self.input() if self._active
        end

        def draw(); end
    end
end