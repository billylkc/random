package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
	"time"

	"cloud.google.com/go/bigquery"
	"cloud.google.com/go/civil"
	_ "github.com/lib/pq"
)

type HistoricalPrice struct {
	Code     int        `bigquery:"code"`
	CodeF    string     `bigquery:"codef"`
	Date     civil.Date `bigquery:"date"`
	Ask      float64    `bigquery:"ask"`
	Bid      float64    `bigquery:"bid"`
	Open     float64    `bigquery:"open"`
	High     float64    `bigquery:"high"`
	Low      float64    `bigquery:"low"`
	Close    float64    `bigquery:"close"`
	Volume   int        `bigquery:"volume"`
	Turnover int        `bigquery:"turnover"`
}

type Sector struct {
	Date        civil.Date `bigquery:"date"`
	Sector      string     `bigquery:"sector"`
	ChangePct   float64    `bigquery:"changepct"`
	PChangePct  float64    `bigquery:"pchangepct"`
	Turnover    int        `bigquery:"turnover"`
	AvgTurnover int        `bigquery:"avgturnover"`
	AvgPE       float64    `bigquery:"avgpe"`
	ZoneA       int        `bigquery:"zonea"`
	ZoneB       int        `bigquery:"zoneb"`
	ZoneC       int        `bigquery:"zonec"`
	ZoneD       int        `bigquery:"zoned"`
	ZoneE       int        `bigquery:"zonee"`
	ZoneN       int        `bigquery:"zonen"`
}

func main() {
	// fmt.Println("main")

	records, err := GetRecords("sector")
	if err != nil {
		fmt.Println(err.Error())
	}
	fmt.Println(len(records))

	err = bulkInsert(records, 500)
	if err != nil {
		fmt.Println(err.Error())
	}

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

func GetRecords(table string) ([]Sector, error) {
	var records []Sector
	db, err := GetConnection()
	defer db.Close()
	if err != nil {
		return records, err
	}
	queryF := `
    SELECT *
    FROM %s
`

	query := fmt.Sprintf(queryF, table)
	fmt.Println(query)

	rows, err := db.Query(query)
	if err != nil {
		return records, err
	}

	for rows.Next() {
		var (
			r    Sector
			date time.Time
			id   int
		)
		err = rows.Scan(&id, &date, &r.Sector, &r.ChangePct, &r.PChangePct, &r.Turnover, &r.AvgTurnover, &r.AvgPE, &r.ZoneA, &r.ZoneB, &r.ZoneC, &r.ZoneD, &r.ZoneE, &r.ZoneN)
		if err != nil {
			return records, err
		}
		_ = id
		d := civil.DateOf(date.Round(0))
		r.Date = d

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

func chunkStruct(items []Sector, chunkSize int) ([][]Sector, error) {
	var chunks [][]Sector

	if len(items) == 0 {
		return chunks, fmt.Errorf("Empty input")
	}

	for chunkSize < len(items) {
		chunks = append(chunks, items[0:chunkSize])
		items = items[chunkSize:]
	}
	chunks = append(chunks, items)

	return chunks, nil
}

func chunkSlice(items []int, chunkSize int) [][]int {
	var chunks [][]int
	for chunkSize < len(items) {
		chunks = append(chunks, items[0:chunkSize])
		items = items[chunkSize:]
	}
	return append(chunks, items)
}

// bulkInsert breaks the list into smaller chunks, and insert into bigquery
func bulkInsert(records []Sector, size int) error {
	chunks, err := chunkStruct(records, size)
	if err != nil {
		return err
	}

	n := len(chunks)
	for i, chunk := range chunks {
		err = insertRows(chunk)
		if err != nil {
			fmt.Println(err.Error())
		}
		fmt.Printf("Finished loop - %d/%d \n", i, n)

	}
	return err
}

// insertRows demonstrates inserting data into a table using the streaming insert mechanism.
func insertRows(records []Sector) error {

	ctx := context.Background()
	client, err := bigquery.NewClient(ctx, "stock-lib")
	if err != nil {
		return fmt.Errorf("bigquery.NewClient: %v", err)
	}
	defer client.Close()

	inserter := client.Dataset("stock").Table("sector").Inserter()

	var items []*Sector
	for i := range records {
		items = append(items, &records[i])
	}
	if err := inserter.Put(ctx, items); err != nil {
		return err
	}
	return nil
}

func convertCode(s string) (int, error) {

	if strings.TrimSpace(s) == "" {
		return 0, fmt.Errorf("Empty string")
	}

	ss := strings.TrimLeft(s, "0")
	i, err := strconv.Atoi(ss)
	if err != nil {
		return 0, err
	}

	return i, nil
}
