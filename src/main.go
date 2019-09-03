package main

import (
	"./eval"
	"./parse"
	"bufio"
	"io"
	"os"
)

func main() {
	Repl(os.Stdin, os.Stdout, os.Stderr)
}

func Repl(in io.Reader, out io.Writer, errOut io.Writer) {
	runesToParse := make(chan rune, 4096)
	phrasesToEval := make(chan eval.Phrase, 1024)
	done := make(chan struct{})

	go Parse(runesToParse, phrasesToEval, errOut)
	go Eval(phrasesToEval, errOut, done)

	input := bufio.NewReader(in)
	for {
		line, err := input.ReadString('\n')
		if err != nil {
			break // Most likely, we reached the end of the stream
		}
		for _, rune := range line {
			runesToParse <- rune
		}
	}
	close(runesToParse)
	<-done
}

func Parse(in chan rune, out chan eval.Phrase, errOut io.Writer) {
	parse.NewParser(parse.NewInputStream(in), out, errOut).Parse()
}

func Eval(input chan eval.Phrase, errOut io.Writer, done chan struct{}) {
	ctx := eval.NewExecutionContext()
	for phrase := range input {
		phrase.Eval(ctx)
	}
	close(done)
}
