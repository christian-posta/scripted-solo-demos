package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	http.HandleFunc("/vets/new", newVetForm)
	http.HandleFunc("/", getVets)

	fmt.Printf("Starting HTTP server at port %s\n", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}

func getVets(w http.ResponseWriter, r *http.Request) {
	vetList, err := vets()
	if err != nil {
		http.Error(w, fmt.Sprintf("unable to get vets: %q\n", err),
			http.StatusInternalServerError)
		return
	}
	if err := pageTemplate.Execute(w, vetList); err != nil {
		http.Error(w, fmt.Sprintf("unable to execute template: %q\n", err),
			http.StatusInternalServerError)
	}
}

func newVetForm(w http.ResponseWriter, r *http.Request) {
	if err := formTemplate.Execute(w, nil); err != nil {
		http.Error(w, fmt.Sprintf("unable to execute form template: %q", err),
			http.StatusInternalServerError)
	}
}
