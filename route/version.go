package route

import (
	"net/http"

	"github.com/labstack/echo/v4"
)

// User
type Ver struct {
	Commit      string `json:"commit"`
	Version     string `json:"version"`
	Description string `json:"description"`
}

var version = "dev"
var commit = "HEAD"

func Version(c echo.Context) error {
	u := &Ver{
		Commit:      commit,
		Version:     version,
		Description: "Fun little project to mutate grype database endpoints",
	}
	return c.JSON(http.StatusOK, u)
}
