module GUI

    class Text < GUI::Widget

        protected

        attr_accessor :_text, :_font, :_data, :_text_alignment

        public

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

            on_idle do |text|
                text._data.color = Omega::Color::WHITE if not text._data.nil?
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
                @size.y = @_font.height
            end
            if not @_data.nil?
                @_data.scale = @scale
                #----------------------------------------
                case @_text_alignment
                when Alignment::LEFT
                    @_data.position = @position.to_vector3
                when Alignment::CENTER
                    puts "CENTER"
                    @_data.position = (@position + Omega::Vector2.new(@size.x / 2.0 - @_font.text_width(@_text) / 2.0, 0)).to_vector3
                when Alignment::RIGHT
                    @_data.position = (@position + Omega::Vector2.new(@size.x - @_font.text_width(@_text), 0)).to_vector3
                end
                puts @position.s
                puts @_data.position
                @_data.position.z = 50000000
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