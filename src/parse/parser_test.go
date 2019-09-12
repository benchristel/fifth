package parse_test

import (
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
	"strings"

	"."
	"../eval"
)

var _ = Describe("the fifth parser", func() {
	var in chan rune
	var out chan eval.Phrase
	var errOut *strings.Builder
	var parser *parse.Parser

	doParse := func(input string) {
		in = make(chan rune, len(input))
		out = make(chan eval.Phrase, 128)
		errOut = &strings.Builder{}
		for _, r := range input {
			in <- rune(r)
		}
		close(in)
		parser = parse.NewParser(parse.NewInputStream(in), out, errOut)
		parser.Parse()
	}

	It("emits no phrases given only whitespace", func() {
		doParse("  \n \t ")

		Expect(<-out).To(BeNil())
		Expect(errOut.String()).To(Equal(""))
	})

	It("emits an instruction phrase given one word", func() {
		doParse("wow")

		Expect(<-out).To(Equal(eval.InstructionPhrase("wow")))
		Expect(<-out).To(BeNil())
		Expect(errOut.String()).To(Equal(""))
	})

	It("emits two instruction phrases given space-separated words", func() {
		doParse("wow willy")

		Expect(<-out).To(Equal(eval.InstructionPhrase("wow")))
		Expect(<-out).To(Equal(eval.InstructionPhrase("willy")))
		Expect(<-out).To(BeNil())
		Expect(errOut.String()).To(Equal(""))
	})

	It("emits a list phrase", func() {
		doParse("[one two]")

		Expect(<-out).To(Equal(eval.ListPhrase([]eval.Phrase{
			eval.InstructionPhrase("one"),
			eval.InstructionPhrase("two"),
		})))
		Expect(<-out).To(BeNil())
		Expect(errOut.String()).To(Equal(""))
	})

	It("emits a list phrase when surrounded by whitespace", func() {
		doParse(" [ one two ] ")

		Expect(<-out).To(Equal(eval.ListPhrase([]eval.Phrase{
			eval.InstructionPhrase("one"),
			eval.InstructionPhrase("two"),
		})))
		Expect(<-out).To(BeNil())
		Expect(errOut.String()).To(Equal(""))
	})

	It("emits nested lists", func() {
		doParse("[[one][]three]")

		Expect(<-out).To(Equal(eval.ListPhrase([]eval.Phrase{
			eval.ListPhrase([]eval.Phrase{
				eval.InstructionPhrase("one"),
			}),
			eval.ListPhrase([]eval.Phrase{}),
			eval.InstructionPhrase("three"),
		})))
		Expect(<-out).To(BeNil())
		Expect(errOut.String()).To(Equal(""))
	})

	It("tolerates unexpected characters but prints an error", func() {
		doParse("a, b")

		Expect(<-out).To(Equal(eval.InstructionPhrase("a")))
		Expect(<-out).To(Equal(eval.InstructionPhrase("b")))
		Expect(<-out).To(BeNil())
		Expect(errOut.String()).To(Equal("unexpected character ',' in input\n"))
	})

	It("parses a string", func() {
		doParse(`"Hello, world!"`)

		Expect(<-out).To(Equal(eval.StringPhrase("Hello, world!")))
		Expect(errOut.String()).To(Equal(""))
	})
})
