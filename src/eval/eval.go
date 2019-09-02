package eval

import (
	"fmt"
)

type Phrase interface {
	Eval(ExecutionContext)
}

type ExecutionContext struct {
	stack     *PhraseStack
	err       error
	namespace Namespace
}

type Namespace struct {
	vars   map[StringPhrase]Phrase
	macros map[InstructionPhrase][]Phrase
}

type StringPhrase string

func (s StringPhrase) Eval(ctx ExecutionContext) {
	ctx.stack.Push(s)
}

type IntPhrase int

func (i IntPhrase) Eval(ctx ExecutionContext) {
	ctx.stack.Push(i)
}

type InstructionPhrase string

func (i InstructionPhrase) Eval(ctx ExecutionContext) {
	// if expansion, exists := ctx.namespace.macros[i]; exists {
	// 	for _, phrase := range expansion {
	// 		phrase.Eval(ctx)
	// 	}
	// } else {
  //
	// }
}

type ListPhrase []Phrase

func (i ListPhrase) Eval(ctx ExecutionContext) {

}

type PhraseStack []Phrase

func NewPhraseStack() *PhraseStack {
	return &PhraseStack{}
}

func (ps *PhraseStack) Push(p Phrase) {
	*ps = append(*ps, p)
}

func (ps *PhraseStack) Peek() (Phrase, error) {
	if len(*ps) == 0 {
		return nil, fmt.Errorf("stack is empty")
	}
	return (*ps)[len(*ps)-1], nil
}

func (ps *PhraseStack) Pop() (Phrase, error) {
	item, err := ps.Peek()
	if err != nil {
		return nil, err
	}
	*ps = (*ps)[0 : len(*ps)-1]
	return item, err
}

type PhraseQueue struct {
	first *PhraseQueueItem
	last  *PhraseQueueItem
}

type PhraseQueueItem struct {
	phrase Phrase
	next   *PhraseQueueItem
}

func NewPhraseQueue() *PhraseQueue {
	return &PhraseQueue{}
}

func (q *PhraseQueue) Enqueue(phrase Phrase) {
	item := &PhraseQueueItem{phrase: phrase}
	if q.first == nil {
		// queue is empty; set up the first item
		q.first = item
		q.last = item
	} else {
		// not empty; link from the current last item to the new one
		q.last.next = item
		q.last = item
	}
}

func (q *PhraseQueue) Dequeue() (Phrase, error) {
	if q.first != nil {
		dequeued := q.first.phrase
		q.first = q.first.next
		return dequeued, nil
	}
	return nil, fmt.Errorf("queue is empty")
}
