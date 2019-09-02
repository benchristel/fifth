package eval_test

import (
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"

	"."
)

var _ = Describe("a PhraseStack", func() {
	var stack *eval.PhraseStack

	BeforeEach(func() {
		stack = eval.NewPhraseStack()
	})

	It("starts empty", func() {
		item, err := stack.Peek()
		Expect(err).To(MatchError("stack is empty"))
		Expect(item).To(BeNil())
	})

	It("pops an item that was pushed", func() {
		stack.Push(eval.StringPhrase("hello"))

		item, err := stack.Pop()
		Expect(err).NotTo(HaveOccurred())
		Expect(item).To(Equal(eval.StringPhrase("hello")))
	})

	It("peeks at an item that was pushed", func() {
		stack.Push(eval.StringPhrase("hello"))

		item, err := stack.Peek()
		Expect(err).NotTo(HaveOccurred())
		Expect(item).To(Equal(eval.StringPhrase("hello")))
	})

	It("is empty after the last item is popped", func() {
		stack.Push(eval.StringPhrase("hello"))

		item, err := stack.Pop()
		Expect(err).NotTo(HaveOccurred())

		item, err = stack.Pop()
		Expect(err).To(MatchError("stack is empty"))
		Expect(item).To(BeNil())
	})

	It("pops items in last-in, first-out order", func() {
		stack.Push(eval.StringPhrase("one"))
		stack.Push(eval.StringPhrase("two"))

		item, err := stack.Pop()
		Expect(err).NotTo(HaveOccurred())
		Expect(item).To(Equal(eval.StringPhrase("two")))

		item, err = stack.Pop()
		Expect(err).NotTo(HaveOccurred())
		Expect(item).To(Equal(eval.StringPhrase("one")))
	})
})
