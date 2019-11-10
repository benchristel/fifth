module Fifth
  class List
    def self.from_a(array)
      return array if array.is_a? Cell
      array.reverse.reduce(Empty) do |list, item|
        list.cons(item)
      end
    end

    class Cell < Struct.new(:head, :tail)
      include Enumerable

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

      def each(&block)
        yield head
        tail.each(&block)
      end

      def inspect
        "#{head.inspect} :: #{tail.inspect}"
      end

      def count
        1 + tail.count
      end

      def count_less_than(cap)
        # TODO: avoid counting the whole list
        count < cap
      end

      def head_or_nil
        head
      end

      def tail_or_empty
        tail
      end
    end

    class EmptyClass < Cell
      def empty?
        true
      end

      def head
        raise "Cannot get head of empty list."
      end

      def tail
        raise "Cannot get tail of empty list."
      end

      def each
      end

      def select
        Empty
      end

      def inspect
        "Empty"
      end

      def count
        0
      end

      def head_or_nil
        nil
      end

      def tail_or_empty
        Empty
      end
    end

    Empty = EmptyClass.new(nil, nil)
  end
end
