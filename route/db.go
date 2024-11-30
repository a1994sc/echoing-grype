package route

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"reflect"

	"github.com/labstack/echo/v4"
	"github.com/spf13/viper"
)

type Database struct {
	Available VersionsDB `json:"available"`
	Comment   string     `json:"comment"`
}

type VersionsDB struct {
	One   []VersionDB `json:"1"`
	Two   []VersionDB `json:"2"`
	Three []VersionDB `json:"3"`
	Four  []VersionDB `json:"4"`
	Five  []VersionDB `json:"5"`
}

type VersionDB struct {
	Built   string `json:"built"`
	Check   string `json:"checksum"`
	URL     string `json:"url"`
	Version int    `json:"version"`
}

func DatabaseMutate(c echo.Context) error {
	var db Database
	resp, err := http.Get(viper.GetString("db.update-url"))
	if err != nil {
		log.Fatalln(err)
	}

	data, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Fatalln(err)
	}

	json.Unmarshal([]byte(data), &db)

	changeURLPath(db)

	db.Comment = "test"

	return c.JSON(http.StatusOK, db)
}

func changeURLPath(db Database) {
	v := reflect.ValueOf(db.Available)

	for i := 0; i < v.NumField(); i++ {
		field := v.Field(i)
		fieldName := v.Type().Field(i).Name
		fmt.Printf("%s: %v\n", fieldName, field.Interface())
	}
}
