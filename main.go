package main

import (
	"net/http"
	"text/template"
)

var bootstrap *template.Template

type data struct {
	Name  string
	Value int
}

func main() {
	var err error
	bootstrap, err = template.ParseGlob("templates/*.gohtml")
	if err != nil {
		panic(err)
	}

	http.HandleFunc("/", handler)
	http.ListenAndServe(":7002", nil)
}

func handler(w http.ResponseWriter, r *http.Request) {
	d := data{
		Name:  "Billy",
		Value: 12,
	}
	bootstrap.ExecuteTemplate(w, "bootstrap", nil)
	bootstrap.ExecuteTemplate(w, "about", d)
}
