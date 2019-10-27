module Fifth
  class List
    class Cell < Struct.new(:head, :tail)
      def empty?
        false
      end

      def cons(item)
        List::Cell.new(item, self)
      end
    end

    Empty = Class.new(Cell) do
      def empty?
        true
      end

      def head
        raise "Cannot get head of empty list."
      end

      def tail
        raise "Cannot get tail of empty list."
      end
    end.new(nil, nil)
  end

  class Map
    BASE = 16
    MAX_LEVEL = 6

    class Entry < Struct.new(:key, :value)
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
        case @items[index]
        when Map
          @items[index].get(key)
        when Entry
          @items[index].key == key ? @items[index].value : nil
        when List::Cell
          cell = @items[index]
          while cell.tail != List::Empty
            break if cell.head.key == key
            cell = cell.tail
          end
          cell.head.key == key ? cell.head.value : nil
        when nil
          nil
        end
      raise "Cannot get nonexistent key #{key.inspect}" if value.nil?
      value
    end

    def set(key, value)
      index = index_at_level(key.hash)
      items = @items.clone
      items[index] =
        case items[index]
        when nil
          Entry.new(key, value)
        when Map
          items[index].set(key, value)
        when List::Cell
          items[index].cons(Entry.new(key, value))
        else
          existing = items[index]
          if existing.key == key
            Entry.new(key, value)
          else
            if @level < MAX_LEVEL
              Map.new(@level + 1)
                .set(key, value)
                .set(existing.key, existing.value)
            else
              List::Empty.cons(Entry.new(key, value)).cons(Entry.new(existing.key, existing.value))
            end
          end
        end
      Map.new(@level, items)
    end

    def inspect
      @items.inspect
    end

    protected

    def index_at_level(hash, level = @level)
      if level == 1
        hash % BASE
      else
        index_at_level(hash / BASE, level - 1)
      end
    end
  end
end
