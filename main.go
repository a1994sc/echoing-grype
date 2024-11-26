package main

import (
	"github.com/a1994sc/echoing-grype/route"
	"github.com/labstack/echo/v4"
	"github.com/labstack/gommon/log"
)

func main() {
	e := echo.New()
	e.GET("/", route.HelloWorld)
	e.GET("/json", route.JSON)
	e.Logger.SetLevel(log.DEBUG)
	e.Logger.Fatal(e.Start(":1323"))
}
