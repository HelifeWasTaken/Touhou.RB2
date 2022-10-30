class Curve

    def initialize()
        @_start = Omega::Vector2.new(0, 0)
        @_end = Omega::Vector2.new(10, 0)
    end

    def get(t); end

    def generate_from_array(array); end

    def generate_from_range(range)
        generate_from_array(range.map { |i| i.to_f / (range.size - 1) })
    end

    def generate(n)
        generate_from_range((0..n))
    end

    def set_start(start_)
        @_start = start_
        return self
    end

    def set_end(end_)
        @_end = end_
        return self
    end

    def draw(data)
        array = nil
        if (data.is_a? Integer)
            array = generate(data)
        elsif (data.is_a? Range)
            array = generate_from_range(data)
        elsif (data.is_a? Array)
            array = generate_from_array(data)
        end
        point = array[0]
        Gosu.draw_quad(point.x - 1, point.y - 1, Gosu::Color::CYAN, point.x + 1, point.y - 1, Gosu::Color::CYAN, point.x - 1, point.y + 1, Gosu::Color::CYAN, point.x + 1, point.y + 1, Gosu::Color::CYAN);
        for i in 1...array.size
            start = array[i - 1]
            finish = array[i]
            point = finish
            Gosu.draw_line(start.x, start.y, Gosu::Color::RED, finish.x, finish.y, Gosu::Color::RED);
            Gosu.draw_quad(point.x - 1, point.y - 1, Gosu::Color::RED, point.x + 1, point.y - 1, Gosu::Color::RED, point.x - 1, point.y + 1, Gosu::Color::RED, point.x + 1, point.y + 1, Gosu::Color::RED);
        end
        point = array[-1]
        Gosu.draw_quad(point.x - 1, point.y - 1, Gosu::Color::CYAN, point.x + 1, point.y - 1, Gosu::Color::CYAN, point.x - 1, point.y + 1, Gosu::Color::CYAN, point.x + 1, point.y + 1, Gosu::Color::CYAN);
    end
end

class LinearCurve < Curve
    
    def get(t)
        return @_start + (@_end - @_start) * t
    end

    def generate_from_array(array)
        return array.map { |i| get(i) }
    end

end

class QuadraticCurve < Curve

    def initialize()
        super()
        @_control = Omega::Vector2.new(5, 5)
    end

    def get(t)
        return @_start * ((1 - t) ** 2) + @_control * 2 * (1 - t) * t + @_end * (t ** 2)
    end

    def generate_from_array(array)
        return array.map { |i| get(i) }
    end

    def set_control(control_)
        @_control = control_
        return self
    end

    def draw(data)
        super(data)
        point = @_control
        Gosu.draw_quad(point.x - 1, point.y - 1, Gosu::Color::GREEN, point.x + 1, point.y - 1, Gosu::Color::GREEN, point.x - 1, point.y + 1, Gosu::Color::GREEN, point.x + 1, point.y + 1, Gosu::Color::GREEN);
    end
end

class CubicCurve < Curve

    def initialize()
        super()
        @_control1 = Omega::Vector2.new(3, 0)
        @_control2 = Omega::Vector2.new(7, 0)
    end

    def get(t)
        return @_start * ((1 - t) ** 3) + @_control1 * 3 * ((1 - t) ** 2) * t + @_control2 * 3 * (1 - t) * (t ** 2) + @_end * (t ** 3)
    end

    def generate_from_array(array)
        return array.map { |i| get(i) }
    end

    def set_control1(control1_)
        @_control1 = control1_
        return self
    end

    def set_control2(control2_)
        @_control2 = control2_
        return self
    end

    def draw(data)
        super(data)
        point = @_control1
        Gosu.draw_quad(point.x - 1, point.y - 1, Gosu::Color::GREEN, point.x + 1, point.y - 1, Gosu::Color::GREEN, point.x - 1, point.y + 1, Gosu::Color::GREEN, point.x + 1, point.y + 1, Gosu::Color::GREEN);
        point = @_control2
        Gosu.draw_quad(point.x - 1, point.y - 1, Gosu::Color::GREEN, point.x + 1, point.y - 1, Gosu::Color::GREEN, point.x - 1, point.y + 1, Gosu::Color::GREEN, point.x + 1, point.y + 1, Gosu::Color::GREEN);
    end
end

class BezierCurve < Curve

    def initialize()
        super()
        @_control = []
        @_points = nil
    end

    def get(t)
        if @_points == nil
            @_points = @_control.clone()
            @_points.unshift(@_start)
            @_points << @_end
        end
        n = @_points.size()
        return (0..n).map { |i| @_points[i] * (n.choose(i) * (1 - t) ** (n - i) * t ** i) }.reduce(:+)
    end

    def generate_from_array(array)
        return array.map { |i| get(i.to_f / n) }
    end

    def set_start(start_)
        @_points = nil
        return super(start_)
    end

    def set_end(end_)
        @_points = nil
        return super(end_)
    end

    def add_control(control_)
        @_control << control_
        @_points = nil
        return self
    end

    def reset()
        @_control.clear()
        @_points = nil
        return self
    end

    def draw(data)
        super(data)
        for i in 0...@_control.size()
            point = @_control[i]
            Gosu.draw_quad(point.x - 1, point.y - 1, Gosu::Color::GREEN, point.x + 1, point.y - 1, Gosu::Color::GREEN, point.x - 1, point.y + 1, Gosu::Color::GREEN, point.x + 1, point.y + 1, Gosu::Color::GREEN);
        end
    end
end