require_relative '../lib/fifth'

module Fifth
  describe List do
    context "when empty" do
      it "is empty" do
        expect(List::Empty).to be_empty
      end

      it "has no head" do
        expect { List::Empty.head }.to raise_error "Cannot get head of empty list."
      end

      it "has no tail" do
        expect { List::Empty.tail }.to raise_error "Cannot get tail of empty list."
      end
    end

    context "with one item" do
      subject { List::Empty.cons 1 }

      it "is headed by the item" do
        expect(subject.head).to eq 1
      end

      it "has an empty tail" do
        expect(subject.tail).to be_empty
      end

      it "is not empty" do
        expect(subject).not_to be_empty
      end

      it "is equal to another list with the same item" do
        expect(subject).to eq List::Empty.cons 1
      end

      it "is not equal to another list with a different item" do
        expect(subject).not_to eq List::Empty.cons 2
      end
    end

    context "with two items" do
      subject { List::Empty.cons(1).cons 2 }

      it "is headed by the last item consed" do
        expect(subject.head).to eq 2
      end

      it "has a tail which is the list minus the head" do
        expect(subject.tail.head).to eq 1
      end

      it "is equal to another list with the same items" do
        expect(subject).to eq List::Empty.cons(1).cons 2
      end

      it "is not equal to another list with different items" do
        expect(subject).not_to eq List::Empty.cons(2).cons 2
        expect(subject).not_to eq List::Empty.cons(1).cons 1
      end
    end
  end

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
    end

    context "with many keys" do
      subject do
        (0..9).reduce(Map.new) do |map, n|
          map.set(n, n.to_s)
        end
      end

      it "remembers them all" do
        (0..9).reverse_each do |n|
          expect(subject.get(n)).to eq n.to_s
        end
      end

      it "replaces their values" do
        new = (0..9).reduce(subject) do |map, n|
          map.set(n + 1, n.to_s)
        end
        (0..9).reverse_each do |n|
          expect(new.get(n + 1)).to eq n.to_s
        end
      end
    end

    context "when there is a hash collision" do
      let(:good) { double :good, hash: 0 }
      let(:evil) { double :evil, hash: 0 }
      let(:absent) { double :absent, hash: 0 }

      subject do
        Map.new.set(good, 1).set(evil, 2)
      end

      it "still keeps keys distinct" do
        expect(subject.get(good)).to eq 1
        expect(subject.get(evil)).to eq 2
      end

      it "does not mistake absent keys for present ones" do
        expect { subject.get(absent) }.to raise_error 'Cannot get nonexistent key #<Double :absent>'
      end
    end
  end
end
