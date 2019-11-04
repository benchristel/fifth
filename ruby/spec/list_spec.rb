require_relative '../lib/list'

module Fifth
  describe List do
    describe "from_a" do
      it "creates an empty list from an array" do
        expect(List.from_a []).to be_empty
      end

      it "creates a list of one element" do
        expect(List.from_a [1]).to eq List::Empty.cons(1)
      end

      it "creates a list of two elements" do
        list = List.from_a [1, 2]
        expect(list.head).to eq 1
        expect(list.tail).to eq List::Empty.cons(2)
      end

      it "creates a list from another list" do
        list = List.from_a [1, 2, 3]
        expect(List.from_a list).to eq list
      end
    end

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

      it "has a count of 0" do
        expect(List::Empty.count).to eq 0
      end

      it "returns nil when asked for head_or_nil" do
        expect(List::Empty.head_or_nil).to be_nil
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

      it "has a count of 1" do
        expect(subject.count).to eq 1
      end

      it "returns the head when asked for head_or_nil" do
        expect(subject.head_or_nil).to eq 1
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

      it "has a count of 2" do
        expect(subject.count).to eq 2
      end
    end
  end
end
