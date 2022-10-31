module GUI

    class Text < GUI::Widget

        module Alignment
            LEFT = 0
            CENTER = 1
            RIGHT = 2
        end

        def initialize()
            super()

            @_text = ""
            @_font = nil
            @_data = nil
            @_text_alignment = Alignment::LEFT

            on_idle do
                @_data.color = Omega::Color::WHITE
            end
        end

        def initialize_copy(other)
            self.__reload
            super(other)
        end

        protected

        def __reload()
            super()
            if not @_font.nil?
                @_data = Omega::Text.new(@_text, @_font)
            end
            if not @_data.nil?
                @_data.scale = @scale
                #----------------------------------------
                case @_text_alignment
                when Alignment::LEFT
                    @_data.position = @position.to_vector3
                when Alignment::CENTER
                    @_data.position = (@position + Omega::Vector2.new(@size.x / 2.0 - @_font.text_width(@_text) / 2.0, 0)).to_vector3
                when Alignment::RIGHT
                    @_data.position = (@position + Omega::Vector2.new(@size.x - @_font.text_width(@_text), 0)).to_vector3
                end
            end
        end

        public

        def set_text(text)
            @_text = text
            __reload
            return self
        end

        def set_font(font)
            @_font = font
            __reload
            return self
        end

        def set_alignment(align)
            @_text_alignment = align
            __reload
            return self
        end

        def disable()
            super()
            @_data.color = Omega::Color::GRAY if not @_data.nil?
        end

        def draw()
            if not @_data.nil?
                @_data.draw
            end
        end
    end
end