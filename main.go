package main

import (
	"encoding/json"
	"fmt"
	"time"
)

type Foo struct {
	Code      int
	Verbosity int
	Timeout   time.Duration // In nanoseconds
}

type option func(*Foo)

func main() {
	fmt.Println("Demo for option chain")
	foo := New(5)

	fmt.Println("Before")
	fmt.Println(PrettyPrint(foo))

	fmt.Println("After")
	foo.Option(Verbosity(-1))     // Set verbosity
	foo.Option(SetTimeout("10s")) // Set timeout to 10 sec

	fmt.Println(PrettyPrint(foo))
}

func New(code int) Foo {
	return Foo{
		Code: code,
	}
}

// Option sets the options specified.
func (f *Foo) Option(opts ...option) {
	for _, opt := range opts {
		opt(f)
	}
}

// Verbosity sets Foo's verbosity level to v.
func Verbosity(v int) option {
	return func(f *Foo) {
		f.Verbosity = v
	}
}

// SetTimeout sets Foo's verbosity level to v.
func SetTimeout(t string) option {
	timeout, _ := time.ParseDuration(t)
	return func(f *Foo) {
		f.Timeout = timeout
	}
}

// PrettyPrint to print struct in a readable way
func PrettyPrint(i interface{}) string {
	s, _ := json.MarshalIndent(i, "", "\t")
	return string(s)
}
