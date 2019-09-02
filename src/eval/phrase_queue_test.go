package eval_test

import (
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"

	"."
)

var _ = Describe("a PhraseQueue", func() {
	var queue *eval.PhraseQueue

	BeforeEach(func() {
		queue = eval.NewPhraseQueue()
	})

	It("starts empty", func() {
		dequeued, err := queue.Dequeue()
		Expect(err).To(MatchError("queue is empty"))
		Expect(dequeued).To(BeNil())
	})

	It("dequeues an item that was enqueued", func() {
		queue.Enqueue(eval.StringPhrase("one"))
		item, err := queue.Dequeue()
		Expect(err).NotTo(HaveOccurred())
		Expect(item).To(Equal(eval.StringPhrase("one")))
	})

	It("is empty after dequeuing the last item", func() {
		queue.Enqueue(eval.StringPhrase("one"))
		queue.Dequeue()
		dequeued, err := queue.Dequeue()
		Expect(err).To(MatchError("queue is empty"))
		Expect(dequeued).To(BeNil())
	})

	It("dequeues in first-in, first-out order", func() {
		queue.Enqueue(eval.StringPhrase("one"))
		queue.Enqueue(eval.StringPhrase("two"))
		item, err := queue.Dequeue()
		Expect(err).NotTo(HaveOccurred())
		Expect(item).To(Equal(eval.StringPhrase("one")))
		item, err = queue.Dequeue()
		Expect(err).NotTo(HaveOccurred())
		Expect(item).To(Equal(eval.StringPhrase("two")))
	})

	It("is empty after dequeuing all items", func() {
		queue.Enqueue(eval.StringPhrase("one"))
		queue.Enqueue(eval.StringPhrase("two"))
		queue.Enqueue(eval.StringPhrase("three"))
		item, _ := queue.Dequeue()
		Expect(item).To(Equal(eval.StringPhrase("one")))
		item, _ = queue.Dequeue()
		Expect(item).To(Equal(eval.StringPhrase("two")))
		item, _ = queue.Dequeue()
		Expect(item).To(Equal(eval.StringPhrase("three")))
		_, err := queue.Dequeue()
		Expect(err).To(MatchError("queue is empty"))
	})

	It("can interleave enqueue and dequeue operations", func() {
		queue.Enqueue(eval.StringPhrase("one"))
		queue.Enqueue(eval.StringPhrase("two"))
		item, _ := queue.Dequeue()
		Expect(item).To(Equal(eval.StringPhrase("one")))
		queue.Enqueue(eval.StringPhrase("three"))
		item, _ = queue.Dequeue()
		Expect(item).To(Equal(eval.StringPhrase("two")))
		item, _ = queue.Dequeue()
		Expect(item).To(Equal(eval.StringPhrase("three")))
	})
})
