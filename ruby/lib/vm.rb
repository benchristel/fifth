module Fifth
  class VM
    def self.build(program: [], stack: [])
      Map.new
        .set(:program, List.from_a(program))
        .set(:stack, List.from_a(stack))
    end
  end
end
