package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"github.com/andrewstuart/goq"
)

// Example as a struct to capture from example.com
type Example struct {
	Title     string `goquery:"h1"`
	Paragraph string `goquery:"div p"`
}

// Rice as a struct to capture from openrice.com
type Rice struct {
	Title   string `goquery:"div.cms-detail-title.or-font-family"`
	Section string `goquery:"section.cms-detail-main"`
}

// wiki as a struct to capture from wikipedia
type Wiki struct {
	Title    string   `goquery:"h1#firstHeading.firstHeading"`
	Contents []string `goquery:"div#mw-content-text.mw-content-ltr div p"`
}

func main() {
	// GetExample()
	// GetOpenrice()
	GetWiki()
}

func GetWiki() {
	res, err := http.Get("https://en.wikipedia.org/wiki/Logistic_regression")
	if err != nil {
		log.Fatal(err)
	}
	defer res.Body.Close()

	var example Wiki

	err = goq.NewDecoder(res.Body).Decode(&example)
	if err != nil {
		log.Fatal(err)
	}
	content := example.Contents
	for _, c := range content[0:3] {
		fmt.Println(c)
		fmt.Println("")
	}
}

func GetOpenrice() {
	res, err := http.Get("https://www.openrice.com/zh/hongkong/promo/%E3%80%90%E7%B5%82%E6%96%BC%E7%B4%84friend%E9%A3%9F%E9%A3%AF%E3%80%91%E5%B0%96%E6%B2%99%E5%92%80%E4%B8%BB%E6%89%93%E9%A3%B2%E9%85%92%E6%B5%B7%E9%AE%AE-outdoor%E4%BD%8D%E6%9C%89%E6%B0%A3%E6%B0%9B-a5816")
	if err != nil {
		log.Fatal(err)
	}
	defer res.Body.Close()

	var example Rice

	err = goq.NewDecoder(res.Body).Decode(&example)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(PrettyPrint(example))
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
