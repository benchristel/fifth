module Fifth
  class Interpreter
    def self.evolve(original_vm, steps)
      instruction = dequeue_instruction(original_vm)
      begin
        new_vm = instruction.invoke
      rescue
        return original_vm
      end

      if steps > 1
        evolve new_vm, steps - 1
      else
        new_vm
      end
    end

    def self.dequeue_instruction(vm)
      Instruction.build(
        vm.get(:program).head_or_nil,
        vm.set(:program, vm.get(:program).tail_or_empty))
    end
  end

  class Instruction
    attr_reader :vm

    def self.build(term, vm)
      case term
      when Symbol
        {
          add: Add.new(vm),
        }[term]
      when nil
        Noop.new(vm)
      else
        StackData.new(term, vm)
      end
    end

    def initialize(vm)
      @vm = vm
    end

    def stack
      @stack ||= vm.get(:stack)
    end

    def error
      "an unknown error occurred invoking `#{self.class.name}`"
    end

    def error?
      false
    end

    def invoke
      raise error if error?
      operate
    end

    def operate
      vm
    end

    class StackData < Instruction
      attr_reader :term

      def initialize(term, vm)
        super vm
        @term = term
      end

      def invoke
        VM.build(
          program: vm.get(:program),
          stack: vm.get(:stack).cons(term)
        )
      end
    end

    class Noop < Instruction
    end

    class Add < Instruction
      def error
        "`add` requires two operands"
      end

      def error?
        stack.count_less_than(2)
      end

      def operate
        a = stack.head
        b = stack.tail.head
        vm.set(:stack, stack.tail.tail.cons(a + b))
      end
    end

    class Eval < Instruction
      def error
        "`eval` requires a list"
      end

      def error?
        stack.count_less_than(1) || !stack.head.is_a?(List::Cell)
      end

      def operate
        stack.head.reduce(vm.set(:stack, stack.tail)) do |vm, instr|
          Instruction.build(instr, vm).invoke
        end
      end
    end

    class Dup < Instruction
      def error
        "`dup` requires an operand"
      end

      def error?
        stack.count_less_than(1)
      end

      def operate
        vm.set(:stack, stack.cons(stack.head))
      end
    end

    class Drop < Instruction
      def error
        "`drop` requires an operand"
      end

      def error?
        stack.count_less_than(1)
      end

      def operate
        vm.set(:stack, stack.tail)
      end
    end
  end
end
