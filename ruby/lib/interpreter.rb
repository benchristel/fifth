module Fifth
  class Interpreter
    def self.evolve(original_vm, steps)
      instruction, vm = dequeue_instruction(original_vm)
      new_vm, err = instruction.invoke(vm)

      if err
        return [original_vm, err]
      end

      if steps > 1
        evolve new_vm, steps - 1
      else
        [new_vm, nil]
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
        [VM.build(
          program: vm.get(:program),
          stack: vm.get(:stack).cons(term)
        ), nil]
      end
    end

    class Noop
      def invoke(vm)
        [vm, nil]
      end
    end

    class Add
      def invoke(vm)
        stack = vm.get(:stack)
        return [vm, "`add` requires two operands"] if stack.count_less_than(2)

        a = stack.head
        b = stack.tail.head
        [vm.set(:stack, stack.tail.tail.cons(a + b)), nil]
      end
    end
  end
end
