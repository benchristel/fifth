module Fifth
  class List
    class Cell < Struct.new(:head, :tail)
      def empty?
        false
      end

      def cons(item)
        List::Cell.new(item, self)
      end

      def select(&block)
        if yield head
          tail.select(&block).cons(head)
        else
          tail.select(&block)
        end
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

      def select
        Empty
      end
    end.new(nil, nil)
  end
end
