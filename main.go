package main

import (
	"fmt"
	"time"
)

func main() {
	fmt.Println("Hello, QA engineer! This is a multi-platform app")
	// keep container alive for 60 seconds
	time.Sleep(10 * time.Second)
}
