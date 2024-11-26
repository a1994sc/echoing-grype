package route

import (
	"net/http"

	"github.com/labstack/echo/v4"
)

// User
type Ver struct {
	Commit  string `json:"commit"`
	Version string `json:"version"`
}

var version = "dev"
var commit = "HEAD"

func Version(c echo.Context) error {
	u := &Ver{
		Commit:  commit,
		Version: version,
	}
	return c.JSON(http.StatusOK, u)
}
