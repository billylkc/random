package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"os"

	_ "github.com/lib/pq"
)

type HistoricalPrice struct {
	Code     int     `csv:"-"`
	CodeF    string  `csv:"-"` // code in string format
	Date     string  `csv:"Date"`
	Ask      float64 `csv:"Ask"`
	Bid      float64 `csv:"Bid"`
	Open     float64 `csv:"Previous Close"` // open is missing in quandl, using prev close
	High     float64 `csv:"High"`
	Low      float64 `csv:"Low"`
	Close    float64 `csv:"Nominal Price"`
	Volume   int     `csv:"Share Volume (000)"`
	Turnover int     `csv:"Turnover (000)"`
}

func main() {
	fmt.Println("main")

	records, err := GetRecords("stock")
	if err != nil {
		fmt.Println(err.Error())
	}
	fmt.Println(PrettyPrint(records))

}

func GetConnection() (*sql.DB, error) {
	secret := os.Getenv("STOCK_CONNECT")
	if secret == "" {
		log.Fatal(fmt.Errorf("missing environment variable STOCK_CONNECT. Please check."))
	}

	db, err := sql.Open("postgres", secret)
	if err != nil {
		return nil, err
	}
	return db, nil
}

func GetRecords(table string) ([]HistoricalPrice, error) {
	var records []HistoricalPrice
	db, err := GetConnection()
	if err != nil {
		return records, err
	}
	queryF := `
    SELECT *
    FROM %s
    WHERE date = '2022-01-25'
    LIMIT 10
`

	query := fmt.Sprintf(queryF, table)
	fmt.Println(query)

	rows, err := db.Query(query)
	if err != nil {
		return records, err
	}

	for rows.Next() {
		var (
			r        HistoricalPrice
			id       int
			volume   float64
			turnover float64
		)
		err = rows.Scan(&id, &r.Date, &r.Ask, &r.Bid, &r.Open, &r.High, &r.Low, &r.Close, &volume, &turnover, &r.CodeF)
		if err != nil {
			return records, err
		}
		_ = id
		// _ = turnover
		// _ = volume
		r.Turnover = int(turnover)
		r.Volume = int(volume)
		records = append(records, r)
	}

	return records, nil
}

func RecordExists(table, date string) (bool, error) {
	db, err := GetConnection()
	if err != nil {
		return true, err
	}
	queryF := `
    SELECT count(1) as cnt
    FROM %s
    WHERE date = '%s'`

	query := fmt.Sprintf(queryF, table, date)
	fmt.Println(query)
	rows, err := db.Query(query)
	defer rows.Close()
	if err != nil {
		return true, err
	}
	var num int
	for rows.Next() {
		_ = rows.Scan(&num)
	}
	fmt.Printf("Found - %d records \n", num)
	if num > 0 {
		return true, err
	}
	return false, nil // false as safe to insert
}

// PrettyPrint to print struct in a readable way
func PrettyPrint(i interface{}) string {
	s, _ := json.MarshalIndent(i, "", "\t")
	return string(s)
}
