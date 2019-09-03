package parse_test

import (
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"

	"."
)

var _ = Describe("InputStream", func() {
	It("can peek at its next value", func() {
		ch := make(chan rune, 32)
		ch <- 'a'
		close(ch)
		s := parse.NewInputStream(ch)
		next, ok := s.Peek()
		Expect(next).To(Equal('a'))
		Expect(ok).To(BeTrue())
	})

	It("does not change its state when you call Peek", func() {
		ch := make(chan rune, 32)
		ch <- 'a'
		close(ch)
		s := parse.NewInputStream(ch)
		s.Peek()
		s.Peek()
		next, ok := s.Peek()
		Expect(next).To(Equal('a'))
		Expect(ok).To(BeTrue())
	})

	It("can get its next value", func() {
		ch := make(chan rune, 32)
		ch <- 'a'
		close(ch)
		s := parse.NewInputStream(ch)
		next, ok := s.Next()
		Expect(next).To(Equal('a'))
		Expect(ok).To(BeTrue())
	})

	It("dequeues the value when you call Next", func() {
		ch := make(chan rune, 32)
		ch <- 'a'
		ch <- 'b'
		close(ch)
		s := parse.NewInputStream(ch)
		s.Next()
		next, ok := s.Next()
		Expect(next).To(Equal('b'))
		Expect(ok).To(BeTrue())
	})

	It("gives different values when you call Next followed by Peek", func() {
		ch := make(chan rune, 32)
		ch <- 'a'
		ch <- 'b'
		close(ch)
		s := parse.NewInputStream(ch)
		s.Next()
		next, ok := s.Peek()
		Expect(next).To(Equal('b'))
		Expect(ok).To(BeTrue())
	})

	It("gives the same value when you call Peek followed by Next", func() {
		ch := make(chan rune, 32)
		ch <- 'a'
		ch <- 'b'
		close(ch)
		s := parse.NewInputStream(ch)
		s.Peek()
		next, ok := s.Next()
		Expect(next).To(Equal('a'))
		Expect(ok).To(BeTrue())
	})

	It("Peek followed by 2 Nexts", func() {
		ch := make(chan rune, 32)
		ch <- 'a'
		ch <- 'b'
		close(ch)
		s := parse.NewInputStream(ch)
		s.Peek()
		s.Next()
		next, ok := s.Next()
		Expect(next).To(Equal('b'))
		Expect(ok).To(BeTrue())
	})

	It("returns false from Peek when the channel is empty", func() {
		ch := make(chan rune, 32)
		close(ch)
		s := parse.NewInputStream(ch)
		next, ok := s.Peek()
		Expect(next).To(Equal(int32(0)))
		Expect(ok).To(BeFalse())
	})

	It("returns false from Next when the channel is empty", func() {
		ch := make(chan rune, 32)
		close(ch)
		s := parse.NewInputStream(ch)
		next, ok := s.Next()
		Expect(next).To(Equal(int32(0)))
		Expect(ok).To(BeFalse())
	})
})
