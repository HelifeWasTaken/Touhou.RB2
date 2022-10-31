module Button
    UP = 0
    DOWN = 1
    LEFT = 2
    RIGHT = 3
    A = 4
    B = 5
    X = 6
    Y = 7
    L = 8
    R = 9
    START = 10
    SELECT = 11
    HOME = 12
    L3 = 13
    R3 = 14
    JOYSTICK_MAP_BUTTON = [
        [
            Gosu::GP_0_UP,
            Gosu::GP_0_DOWN,
            Gosu::GP_0_LEFT,
            Gosu::GP_0_RIGHT,
            Gosu::GP_0_BUTTON_0,
            Gosu::GP_0_BUTTON_1,
            Gosu::GP_0_BUTTON_2,
            Gosu::GP_0_BUTTON_3,
            Gosu::GP_0_BUTTON_4,
            Gosu::GP_0_BUTTON_5,
            Gosu::GP_0_BUTTON_6,
            Gosu::GP_0_BUTTON_7,
            Gosu::GP_0_BUTTON_8,
            Gosu::GP_0_BUTTON_9,
            Gosu::GP_0_BUTTON_10
        ],
        [
            Gosu::GP_1_UP,
            Gosu::GP_1_DOWN,
            Gosu::GP_1_LEFT,
            Gosu::GP_1_RIGHT,
            Gosu::GP_1_BUTTON_0,
            Gosu::GP_1_BUTTON_1,
            Gosu::GP_1_BUTTON_2,
            Gosu::GP_1_BUTTON_3,
            Gosu::GP_1_BUTTON_4,
            Gosu::GP_1_BUTTON_5,
            Gosu::GP_1_BUTTON_6,
            Gosu::GP_1_BUTTON_7,
            Gosu::GP_1_BUTTON_8,
            Gosu::GP_1_BUTTON_9,
            Gosu::GP_1_BUTTON_10
        ],
        [
            Gosu::GP_2_UP,
            Gosu::GP_2_DOWN,
            Gosu::GP_2_LEFT,
            Gosu::GP_2_RIGHT,
            Gosu::GP_2_BUTTON_0,
            Gosu::GP_2_BUTTON_1,
            Gosu::GP_2_BUTTON_2,
            Gosu::GP_2_BUTTON_3,
            Gosu::GP_2_BUTTON_4,
            Gosu::GP_2_BUTTON_5,
            Gosu::GP_2_BUTTON_6,
            Gosu::GP_2_BUTTON_7,
            Gosu::GP_2_BUTTON_8,
            Gosu::GP_2_BUTTON_9,
            Gosu::GP_2_BUTTON_10
        ],
        [
            Gosu::GP_3_UP,
            Gosu::GP_3_DOWN,
            Gosu::GP_3_LEFT,
            Gosu::GP_3_RIGHT,
            Gosu::GP_3_BUTTON_0,
            Gosu::GP_3_BUTTON_1,
            Gosu::GP_3_BUTTON_2,
            Gosu::GP_3_BUTTON_3,
            Gosu::GP_3_BUTTON_4,
            Gosu::GP_3_BUTTON_5,
            Gosu::GP_3_BUTTON_6,
            Gosu::GP_3_BUTTON_7,
            Gosu::GP_3_BUTTON_8,
            Gosu::GP_3_BUTTON_9,
            Gosu::GP_3_BUTTON_10
        ]
    ]

end

module Axis
    XY = 0,
    ZR = 1
end

class Keyboard

    def initialize
        @action = {}
        @axis = {}
    end

    def set_key(key, action)
        @action[action] = key
    end

    def set_axis(axis, p, n)
        @axis[axis] = [p, n]
    end

    def get_axis(axis, value)
        if @axis[axis].nil?
            return Omega::Vector2.new(0, 0)
        else
            return Omega::Vector2.new(
                pressed(@axis[axis][0]) - pressed(@axis[axis][1]),
                pressed(@axis[axis][0]) - pressed(@axis[axis][1]) 
            )
        end
    end

    def get_key(action)
        @action[action]
    end

    def just_pressed(action)
        Omega.just_pressed(@action[action])
    end

    def pressed(action)
        Omega.pressed(@action[action])
    end

    def just_released(action)
        Omega.just_released(@action[action])
    end

end

class Joystick

    def initialize(index)
        @index = index
    end

    def get_button(button)
        Button::JOYSTICK_MAP_BUTTON[@index][button]
    end

    def get_axis(axis, value)
        if axis == Axis::XY
            return Omega::Vector2.new(
                (pressed(Button::RIGHT) ? 1 : 0) - (pressed(Button::LEFT) ? 1 : 0),
                (pressed(Button::DOWN) ? 1 : 0) - (pressed(Button::UP) ? 1 : 0)
            )
        elsif axis == Axis::ZR
            throw "Getting ZR axis is not supported"
        end
    end

    def just_pressed(action)
        Omega.just_pressed(get_button(action))
    end

    def pressed(action)
        Omega.pressed(get_button(action))
    end

    def just_released(action)
        Omega.just_released(get_button(action))
    end

end
