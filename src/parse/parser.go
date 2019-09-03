package parse

import (
	"../eval"
	"fmt"
	"io"
	"strings"
)

type Parser struct {
	in            *InputStream
	out           chan eval.Phrase
	errOut        io.Writer
	currentPhrase *strings.Builder
}

func NewParser(in *InputStream, out chan eval.Phrase, errOut io.Writer) *Parser {
	return &Parser{
		in:            in,
		out:           out,
		errOut:        errOut,
		currentPhrase: &strings.Builder{},
	}
}

type InputStream struct {
	channel    chan rune
	next       rune
	nextCached bool
	open       bool
}

func NewInputStream(ch chan rune) *InputStream {
	return &InputStream{channel: ch}
}

func (i *InputStream) Peek() (rune, bool) {
	if !i.nextCached {
		i.next, i.open = <-i.channel
		i.nextCached = true
	}
	return i.next, i.open
}

func (i *InputStream) Next() (rune, bool) {
	if i.nextCached {
		i.nextCached = false
		return i.next, i.open
	} else {
		next, open := <-i.channel
		return next, open
	}
}

func (p *Parser) Parse() {
	for {
		_, ok := p.in.Peek()
		if !ok {
			break
		}
		phrase := p.parseOnePhrase()
		if phrase != nil {
			p.out <- phrase
		}
	}
	close(p.out)
}

func (p *Parser) parseOnePhrase() eval.Phrase {
	r, ok := p.in.Peek()
	if !ok {
		panic("the caller of parseOnePhrase is supposed to check for end of input")
	}
	switch {
	case r == ' ' || r == '\t' || r == '\n':
		return p.parseWhitespace()
	case r == '[':
		return p.parseList()
	case isValidInInstructions(r):
		return p.parseInstruction()
	case r == '"':
		return p.parseString()
	default:
		next, _ := p.in.Next() // consume the invalid input
		p.errOut.Write([]byte(fmt.Sprintf("unexpected character '%c' in input\n", next)))
		return nil
	}
}

func (p *Parser) parseList() eval.Phrase {
	list := eval.ListPhrase{}
	p.in.Next() // consume the opening square bracket
	for {
		next, ok := p.in.Peek()
		if next == ']' {
			p.in.Next()
			break
		}
		if !ok {
			p.errOut.Write([]byte("unexpected end of input, expecting ]\n"))
		}
		phrase := p.parseOnePhrase()
		if phrase != nil {
			list = append(list, phrase)
		}
	}
	return list
}

func (p *Parser) parseWhitespace() eval.Phrase {
	for {
		next, ok := p.in.Peek()
		if next != ' ' && next != '\t' && next != '\n' {
			break
		}
		if !ok {
			break
		}
		p.in.Next()
	}
	return nil
}

func (p *Parser) parseInstruction() eval.Phrase {
	p.currentPhrase.Reset()
	for {
		next, ok := p.in.Peek()
		if !isValidInInstructions(next) {
			break
		}
		if !ok {
			break
		}
		next, _ = p.in.Next()
		p.currentPhrase.WriteRune(next)
	}
	return eval.InstructionPhrase(p.currentPhrase.String())
}

func (p *Parser) parseString() eval.Phrase {
	p.currentPhrase.Reset()
	p.in.Next() // consume the opening quote
	for {
		next, ok := p.in.Next()
		if !ok {
			p.errOut.Write([]byte("unexpected end of input, expecting \"\n"))
			break
		}
		if next == '"' {
			break
		}
		p.currentPhrase.WriteRune(next)
	}
	return eval.StringPhrase(p.currentPhrase.String())
}

func isValidInInstructions(r rune) bool {
	return r >= 'a' && r <= 'z' || r == '-'
}
