require_relative '../lib/map'

module Fifth
  describe Map do
    context "when empty" do
      it "has no keys" do
        expect(Map.new.contains? "foo").to be false
      end

      it "raises an exception if you try to get a key" do
        expect { Map.new.get("foo") }.to raise_error 'Cannot get nonexistent key "foo"'
      end
    end

    context "with one key" do
      subject { Map.new.set("foo", "bar") }

      it "fetches the value for that key" do
        expect(subject.get("foo")).to eq "bar"
      end

      it "raises an exception for a nonexistent key" do
        expect { subject.get("blah") }.to raise_error 'Cannot get nonexistent key "blah"'
      end

      it "replaces the value for that key" do
        expect(subject.set("foo", "new").get("foo")).to eq "new"
      end

      it "says the key is present" do
        expect(subject.contains? "foo").to be true
      end

      it "can delete the key" do
        expect(subject.delete("foo").contains? "foo").to be false
      end
    end

    context "with two keys" do
      subject do
        Map.new.set("foo", 1).set("bar", 2)
      end

      it "can delete one key without affecting the other" do
        no_foo = subject.delete("foo")
        expect(no_foo.contains? "foo").to be false
        expect(no_foo.contains? "bar").to be true
        no_bar = subject.delete("bar")
        expect(no_bar.contains? "foo").to be true
        expect(no_bar.contains? "bar").to be false
      end
    end

    context "with many keys" do
      MANY = 33

      subject do
        (0...MANY).reduce(Map.new) do |map, n|
          map.set(n, n.to_s)
        end
      end

      it "remembers them all" do
        (0...MANY).reverse_each do |n|
          expect(subject.get(n)).to eq n.to_s
        end
      end

      it "replaces their values" do
        new = (0...MANY).reduce(subject) do |map, n|
          map.set(n + 1, n.to_s)
        end
        (0...MANY).reverse_each do |n|
          expect(new.get(n + 1)).to eq n.to_s
        end
      end

      it "can delete just one" do
        no_zero = subject.delete(0)
        expect(no_zero.contains? 0).to be false
        (1...MANY).each do |n|
          expect(no_zero.contains? n).to be true
        end
      end

      it "can delete them all" do
        emptied = (0...MANY).reduce(subject) do |map, n|
          map.delete(n)
        end
        expect(emptied.contains? 0).to be false
        expect(emptied.contains? 1).to be false
        expect(emptied.contains? 2).to be false
        expect(emptied.contains? 3).to be false
        expect(emptied.contains? MANY).to be false
      end
    end

    context "when there is a hash collision" do
      let(:good) { double :good, hash: 0 }
      let(:evil) { double :evil, hash: 0 }
      let(:neutral) { double :neutral, hash: 0 }
      let(:absent) { double :absent, hash: 0 }

      subject do
        Map.new.set(good, 1).set(evil, 2).set(neutral, 3)
      end

      it "still keeps keys distinct" do
        expect(subject.get(good)).to eq 1
        expect(subject.get(evil)).to eq 2
        expect(subject.get(neutral)).to eq 3
      end

      it "does not mistake absent keys for present ones" do
        expect { subject.get(absent) }.to raise_error 'Cannot get nonexistent key #<Double :absent>'
      end

      it "does not mistake an absent key for a single present one" do
        map = Map.new.set(good, 1)
        expect { map.get(absent) }.to raise_error 'Cannot get nonexistent key #<Double :absent>'
      end

      it "can overwrite the value for a key" do
        expect(subject.set(good, "new").get(good)).to eq "new"
        expect(subject.set(evil, "new").get(evil)).to eq "new"
      end

      it "can delete a value" do
        expect(subject.contains? evil).to be true
        map = subject.delete(evil)
        expect(map.contains? evil).to be false
        expect(map.contains? good).to be true
      end

      it "does not delete a different key when there is a collision" do
        map = Map.new.set(good, 1)
        expect(map.delete(evil).contains? good).to be true
      end

      it "is equal to an equivalent map" do
        a = Map.new.set(good, 1).set(evil, 2)
        b = Map.new.set(good, 1).set(evil, 2)
        expect(a).to eq b
        expect(a.hash).to eq b.hash
      end
    end

    it "compares for equality by value" do
      expect(Map.new).to eq Map.new
      expect(Map.new.set("foo", 1)).to eq Map.new.set("foo", 1)

      many_keys = (0..100).reduce(Map.new) { |map, n| map.set(n, n) }
      many_keys2 = (0..100).reverse_each.reduce(Map.new) { |map, n| map.set(n, n) }
      expect(many_keys).to eq many_keys2
    end

    it "computes its hash by value" do
      expect(Map.new.hash).to eq Map.new.hash
      expect(Map.new.set("foo", 1).hash).to eq Map.new.set("foo", 1).hash
    end
  end
end
