require_relative 'list'

module Fifth
  class Map
    BASE = 16
    MAX_LEVEL = 6

    class Entry < Struct.new(:key, :value)
      def self.matching(key)
        Proc.new do |entry|
          entry.is_a?(Entry) && entry.key == key
        end
      end
    end

    class CollisionList
      def initialize(list = List::Empty)
        @list = list
      end

      def set(key, value)
        self.class.new(@list.cons(Entry.new(key, value)))
      end

      def get(key)
        list = @list
        while list != List::Empty
          return list.head.value if list.head.key == key
          list = list.tail
        end
        nil
      end
    end

    def initialize(level = 1, items = Array.new(BASE))
      @level = level
      @items = items
    end

    def contains?(key)
      get key rescue return false
      true
    end

    def get(key)
      index = index_at_level(key.hash)
      value =
        case it = @items[index]
        when Map, CollisionList
          it.get(key)
        when Entry.matching(key)
          it.value
        else
          nil
        end
      raise "Cannot get nonexistent key #{key.inspect}" if value.nil?
      value
    end

    def set(key, value)
      index = index_at_level(key.hash)
      items = @items.clone
      items[index] =
        case existing = items[index]
        when Map, CollisionList
          existing.set(key, value)
        when Entry.matching(key)
          Entry.new(key, value)
        when Entry
          container =
            if @level < MAX_LEVEL
              Map.new(@level + 1)
            else
              CollisionList.new
            end
          container
            .set(key, value)
            .set(existing.key, existing.value)
        when nil
          Entry.new(key, value)
        end
      Map.new(@level, items)
    end

    def inspect
      @items.inspect
    end

    private

    def index_at_level(hash, level = @level)
      if level == 1
        hash % BASE
      else
        index_at_level(hash / BASE, level - 1)
      end
    end
  end
end
