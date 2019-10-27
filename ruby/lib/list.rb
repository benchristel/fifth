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
end
