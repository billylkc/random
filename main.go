package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"github.com/andrewstuart/goq"
)

// Structured representation for github file name table
type Example struct {
	Title     string `goquery:"h1"`
	Paragraph string `goquery:"div p"`
}

func main() {
	GetExample()
}

// GetExample extracts data from example.com
func GetExample() {
	res, err := http.Get("https://example.com/")
	if err != nil {
		log.Fatal(err)
	}
	defer res.Body.Close()

	var example Example

	err = goq.NewDecoder(res.Body).Decode(&example)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(PrettyPrint(example))
}

// PrettyPrint to print struct in a readable way
func PrettyPrint(i interface{}) string {
	s, _ := json.MarshalIndent(i, "", "\t")
	return string(s)
}
