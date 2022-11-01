module HitboxType
    HITBOX_NO_TYPE = -1
    #---
    BULLET = 1
    PLAYER_BULLET = HitboxType::BULLET | 256
    ENEMY_BULLET = HitboxType::BULLET | 512
    #---
    PLAYER = 2
    ENEMY = 4
    #---

    def HitboxType.isBullet(type)
        return type & BULLET != 0
    end
end

class Hitbox

  attr_accessor :x, :y, :w, :h, :type

  def initialize(x, y, w, h, type = HitboxType::HITBOX_NO_TYPE, owner = nil)
    @x = x
    @y = y
    @w = w
    @h = h
    @type = type
    @owner = owner
  end

  def collides?(other)
    if @x > other.x + other.w or
        @x + @w < other.x or
        @y > other.y + other.h or
        @y + @h < other.y
        return false
    end
    return true
end

  def draw
    Gosu.draw_rect(@x, @y, @w, @h, Gosu::Color.new(0x80_ff0000), 25000)
  end

  def move(x, y)
    @x += x
    @y += y
  end

  def set_size(w, h)
    @w = w
    @h = h
  end

  def set_position(x, y)
    @x = x
    @y = y
  end

  def on_collision(other)
    @owner.on_collision(other) if @owner != nil
  end

  def update_rect(x, y, w, h)
    @x = x
    @y = y
    @w = w
    @h = h
  end

  def to_s
    return "Hitbox(#{@x}, #{@y}, #{@w}, #{@h}, #{@type})"
  end

end

QUADTREE_NODE_TYPE = 0xFFFFFFFF
QUADTREE_CAPACITY = 4
QUADTREE_MIN_DEPTH = 0

class QuadTree

  def initialize(x, y, w, h, depth=20)
    if depth < QUADTREE_MIN_DEPTH
      raise "QuadTree depth must be greater than " + QUADTREE_MIN_DEPTH.to_s
    end

    # Kek
    @x = x
    @y = y
    @w = w
    @h = h

    @hitbox = Hitbox.new(x, y, w, h, -1)
    @depth = depth
    @children = []
    @hitboxes = []
  end

  def insert(hitbox)
    # print "Inserting #{hitbox} type: #{hitbox.type}\n"
    if @children.empty?
      @hitboxes << hitbox
      if @hitboxes.length > QUADTREE_CAPACITY && @depth > QUADTREE_MIN_DEPTH
        subdivide
      end
    else
      @children.each do |child|
        if child.contains(hitbox)
          child.insert(hitbox)
          break
        end
      end
    end
  end

  def subdivide
    # print "Subdividing\n"
    @children << QuadTree.new(@hitbox.x, @hitbox.y, @hitbox.w / 2, @hitbox.h / 2, @depth - 1)
    @children << QuadTree.new(@hitbox.x + @hitbox.w / 2, @hitbox.y, @hitbox.w / 2, @hitbox.h / 2, @depth - 1)
    @children << QuadTree.new(@hitbox.x, @hitbox.y + @hitbox.h / 2, @hitbox.w / 2, @hitbox.h / 2, @depth - 1)
    @children << QuadTree.new(@hitbox.x + @hitbox.w / 2, @hitbox.y + @hitbox.h / 2, @hitbox.w / 2, @hitbox.h / 2, @depth - 1)

    @hitboxes.each do |hitbox|
      @children.each do |child|
        if child.contains(hitbox)
          child.insert(hitbox)
          break
        end
      end
    end
    @hitboxes = []
  end

  def contains(hitbox)
    @hitbox.collides?(hitbox)
  end

  def draw
    Gosu.draw_rect(@x + 2, @y + 2, @w - 2, @h - 2, Gosu::Color.new(0x8000FF00)) if @children.empty?# Setting an offset to clearly see the quadtree
    @children.each do |child|
      child.draw
    end
  end

  def query_range(range)
    results = []
    if @children.empty?
      @hitboxes.each do |hitbox|
        if range.collides?(hitbox)
          results << hitbox
        end
      end
    else
      @children.each do |child|
        if child.contains(range)
          results += child.query_range(range)
        end
      end
    end
    results
  end

  def query_point(x, y)
    query_range(Hitbox.new(x, y, 1, 1, QUADTREE_NODE_TYPE))
  end

  def clear()
    @children = []
    @hitboxes = []
  end

  def update()
    @hitboxes.each do |hitbox|
      query_range(hitbox).each do |other|
        if hitbox != other
          hitbox.on_collision(other)
        end
      end
    end
    @children.each do |child|
      child.update
    end
  end

  def to_s
    s = "QuadTree(#@hitbox, #@depth): ["

    if @hitboxes.empty?
      s += "n/a"
    else
      tabs = "\t" * (@depth + 2)
      s += "\n" + tabs + @hitboxes.join(",\n" + tabs)
    end
    s += "]\n"

    @children.each do |child|
      s += "\t" + child.to_s
    end
    return s
  end

end

class CollidableEntity

  attr_accessor :collision

  def initialize(child, x, y, w, h, type)
      # ...
      
      #assume type x, y, w, h and type are set, accesible and exists
      @rect_collision = Omega::Rectangle.new(x, y, w, h)

      @collision = Hitbox.new(@rect_collision.position.x, @rect_collision.position.y,
                              @rect_collision.width, @rect_collision.height, type, child)
  end

  def on_collision(other)
      # does nothing by default
  end

  def update_collider_position(x, y)
      @rect_collision.position.x = x
      @rect_collision.position.y = y
      @collision.set_position(x, y)
  end

  def update_collider_size(w, h)
      @rect_collision.width = w
      @rect_collision.height = h
      @collision.set_size(w, h)
  end

  def update_collider(x, y, w, h)
    update_collider_position(x, y)
    update_collider_size(w, h)
  end

  def draw()
    @collision.draw()
  end

  def copy(owner)
    return CollidableEntity.new(owner, @collision.x, @collision.y, @collision.w, @collision.h, @collision.type)
  end
end

class BulletCollider < CollidableEntity

    def initialize(bullet, x, y, w, h)
        @_bullet = bullet 
        super(self, x, y, w, h, HitboxType::BULLET)
    end

    def on_collision(other)
        return if (HitboxType::isBullet(other.type))
        @_bullet.kill if not is_enemy? and other.type != HitboxType::PLAYER
        @_bullet.kill if is_enemy? and other.type == HitboxType::PLAYER
    end

    def set_side(enemy = true)
        if enemy
            self.collision.type = HitboxType::ENEMY_BULLET
        else
            self.collision.type = HitboxType::PLAYER_BULLET
        end
    end

    def is_enemy?
        return self.collision.type == HitboxType::ENEMY_BULLET
    end
end

class PlayerCollider < CollidableEntity

    def initialize(child, x, y, w, h)
        @_player = child
        super(self, x, y, w, h, HitboxType::PLAYER)
    end

    def on_collision(other)
        return if not (HitboxType::isBullet(other.type))
        return if other.type == HitboxType::PLAYER_BULLET
        # @_parent.die
        throw "PLAYER HAS BEEN HIT"
    end
end

class BossCollider < CollidableEntity

    def initialize(child, x, y, w, h)
        @_boss = child
        super(self, x, y, w, h, HitboxType::ENEMY)
    end

    def on_collision(other)
        return if not (HitboxType::isBullet(other.type))
        return if other.type == HitboxType::ENEMY_BULLET
        #@_boss.hurt
        throw "BOSS HAS BEEN HIT"
    end
end

#class Player < CollidableEntity

#  def initialize(x, y)
#    super(self, x, y, 32, 32, 0)
#  end

#  def on_collision(other)
#    puts "Player collided with #{other}"
#  end

#  def update
#    update_collider(x, y, w, h)
#  end

#end