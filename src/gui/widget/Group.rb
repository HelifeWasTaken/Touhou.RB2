module GUI

    class Group < Widget

        def initialize()
            super()
            @widgets = []

            @_spacing = 16
        end

        def add(*widget)
            y = @position.y
            for w in @widgets
                y += w.get_size.y + @_spacing
            end
            for w in widget
                w.set_position(Omega::Vector2.new(@position.x, y))
                y += w.get_size.y + @_spacing
                @widgets << w
            end
            return self
        end

        def initialize_copy(other)
            self.widgets = other.widgets.map { |widget| widget.clone() }
            super(other)
        end

        def set_spacing(spacing_)
            @_spacing = spacing_
            return self
        end

        def set_position(position_)
            super(position_)
            y = @position.y
            for w in @widgets
                w.set_position(Omega::Vector2.new(@position.x, y))
                y += w.get_size.y + @_spacing
            end
            __reload
            return self
        end

        def update()
            super()
            # puts @widgets[0].is_hovered?
            @widgets.each { |widget| widget.update() }
        end

        def draw()
            @widgets.each { |widget| widget.draw() }
        end
    end
end