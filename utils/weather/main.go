package main

import (
	"fmt"
	"io"
	"net/http"
	"strings"
)

func parse(input string) string {
	input = strings.ReplaceAll(input, "🌡️", "")
	input = strings.ReplaceAll(input, "🌬️", "")
	input = strings.ReplaceAll(input, " ", "")

	input = strings.ReplaceAll(input, "+", " +")
	input = strings.ReplaceAll(input, "-", " -")

	input = strings.ReplaceAll(input, "C", "C  ")
	return input
}

func main() {
	resp, err := http.Get("https://wttr.in/versailles?format=2")
	if err != nil {
		fmt.Println("Error")
		return
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}

	fmt.Println(parse(string(body)))
}
