package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"time"

	ash "github.com/doncannoli-burns/kolmafia-ash-go/ash"
)

func main() {
	pwd := os.Getenv("KOLMAFIA_PWD")
	if pwd == "" {
		log.Fatal("set KOLMAFIA_PWD to the current local KoLmafia session hash")
	}

	client, err := ash.NewClient(ash.Options{
		PasswordProvider: func(context.Context) (string, error) { return pwd, nil },
		Policy:           ash.AllowOnly("myName", "myMeat", "myAdventures", "availableAmount"),
	})
	if err != nil {
		log.Fatal(err)
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	name, err := client.MyName(ctx)
	if err != nil {
		log.Fatal(err)
	}
	meat, err := client.MyMeat(ctx)
	if err != nil {
		log.Fatal(err)
	}
	clubs, err := client.AvailableAmount(ctx, ash.NewItem("seal-clubbing club"))
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("player=%s meat=%d seal-clubbing-clubs=%d\n", name, meat, clubs)
}
