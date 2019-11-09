require_relative "../lib/interpreter"
require_relative "../lib/vm"

module Fifth
  describe Interpreter do
    def evolve(vm, steps)
      Interpreter.evolve(vm, steps)
    end

    it "does nothing to a VM with an empty program" do
      vm = VM.build
      expect(evolve(vm, 1)).to eq VM.build
    end

    it "moves a non-Name term from the top of the program to the stack" do
      vm = VM.build program: ["hi"]
      expect(evolve vm, 1).to eq VM.build(stack: ["hi"])
    end

    it "moves two non-Name terms from the program to the stack" do
      vm = VM.build program: [1, 2]
      expect(evolve vm, 2).to eq VM.build(stack: [2, 1])
    end

    it "invokes an instruction" do
      vm = VM.build program: [1, 2, :add]
      expect(evolve vm, 3).to eq VM.build(stack: [3])
    end

    it "halts on failure" do
      vm = VM.build program: [:add], stack: [1]
      expect(evolve vm, 1).to eq vm
    end

    it "does nothing after the VM has halted" do
      vm = VM.build program: [:add], stack: [1, 2]
      expect(evolve vm, 10).to eq VM.build(stack: [3])
    end

    it "evolves only the specified number of steps" do
      vm = VM.build program: [:add, :add, :add], stack: [1, 2, 3, 4]
      expect(evolve vm, 2).to eq VM.build(stack: [6, 4], program: [:add])
    end
  end

  module Instruction
    describe Add do
      it "adds two numbers without erroring" do
        vm = VM.build stack: [3, 5]
        expect(Add.new.invoke(vm)).to eq VM.build(stack: [8])
      end

      it "errors given a single number" do
        vm = VM.build stack: [3]
        expect { Add.new.invoke(vm) }.to raise_error "`add` requires two operands"
      end
    end
  end
end
