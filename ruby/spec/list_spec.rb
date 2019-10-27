require_relative '../lib/list'

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
end
