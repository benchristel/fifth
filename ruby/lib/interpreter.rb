module Fifth
  class Interpreter
    def self.evolve(original_vm, steps)
      instruction, vm = dequeue_instruction(original_vm)
      begin
        new_vm = instruction.invoke(vm)
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
      [
        Instruction.build(vm.get(:program).head_or_nil),
        vm.set(:program, vm.get(:program).tail_or_empty)
      ]
    end
  end

  module Instruction
    def self.build(term)
      case term
      when Symbol
        {
          add: Add.new,
        }[term]
      when nil
        Noop.new
      else
        StackData.new(term)
      end
    end

    class StackData < Struct.new(:term)
      def invoke(vm)
        VM.build(
          program: vm.get(:program),
          stack: vm.get(:stack).cons(term)
        )
      end
    end

    class Noop
      def invoke(vm)
        vm
      end
    end

    class Add
      def invoke(vm)
        stack = vm.get(:stack)
        raise "`add` requires two operands" if stack.count_less_than(2)

        a = stack.head
        b = stack.tail.head
        vm.set(:stack, stack.tail.tail.cons(a + b))
      end
    end
  end
end
