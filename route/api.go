package route

import (
	"net/http"

	"github.com/labstack/echo/v4"
)

// User
type User struct {
	Name  string `json:"name"`
	Email string `json:"email"`
}

func HelloWorld(e echo.Context) error {
	return e.String(http.StatusOK, "Hello, World!")
}

func JSON(c echo.Context) error {
	u := &User{
		Name:  "Jon",
		Email: "jon@labstack.com",
	}
	return c.JSON(http.StatusOK, u)
}
