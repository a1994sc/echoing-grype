package main

import (
	"fmt"

	"github.com/a1994sc/echoing-grype/route"
	"github.com/labstack/echo/v4"
	"github.com/labstack/gommon/log"
	"github.com/spf13/viper"
)

func main() {
	config()

	e := echo.New()

	// Stats Middleware
	s := route.NewStats()

	e.Use(s.Process)
	e.Use(route.ServerHeader)

	e.GET("/", route.HelloWorld)
	e.GET("/json", route.JSON)
	e.GET("/mutate", route.DatabaseMutate)
	e.GET("/version", route.Version)
	e.GET("/stats", s.Handle)
	e.Logger.SetLevel(log.DEBUG)
	e.Logger.Fatal(e.Start(":" + viper.GetString("port")))
}

func config() {
	viper.SetConfigName("config")
	viper.SetConfigType("yaml")

	viper.AddConfigPath("/etc/echoing-grype/")
	viper.AddConfigPath(".")

	err := viper.ReadInConfig() // Find and read the config file
	if err != nil {             // Handle errors reading the config file
		panic(fmt.Errorf("fatal error config file: %w", err))
	}
}
