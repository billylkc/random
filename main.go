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

type CCASS struct {
	Date            civil.Date `bigquery:"date"`
	ParticipantCode string     `bigquery:"participantcode"`
	Participant     string     `bigquery:"participant"`
	Number          int        `bigquery:"number"`
	Code            int        `bigquery:"code"`
	CodeF           string     `bigquery:"codef"`
	Percentage      float64    `bigquery:"percentage"`
}

type Industry struct {
	Date      civil.Date `bigquery:"date"`
	Sector    string     `bigquery:"sector"`
	Industry  string     `bigquery:"industry"`
	Code      int        `bigquery:"code"`
	CodeF     string     `bigquery:"codef"`
	Close     float64    `bigquery:"close"`
	Change    float64    `bigquery:"change"`
	ChangePct float64    `bigquery:"changepct"`
	Volume    int        `bigquery:"volume"`
	Turnover  int        `bigquery:"turnover"`
	PE        float64    `bigquery:"pe"`
	PB        float64    `bigquery:"pb"`
	YieldPct  float64    `bigquery:"yieldpct"`
	MarketCap int        `bigquery:"marketcap"`
}

type Option struct {
	Date        civil.Date `bigquery:"date"`
	Code        int        `bigquery:"code"`
	CodeF       string     `bigquery:"codef"`
	OptionName  string     `bigquery:"optionname"`
	OptionDesc  string     `bigquery:"optiondesc"`
	OptionDate  civil.Date `bigquery:"optiondate"`
	Strike      float64    `bigquery:"strike"`
	Contract    string     `bigquery:"contract"`
	Open        float64    `bigquery:"open"`
	High        float64    `bigquery:"high"`
	Low         float64    `bigquery:"low"`
	Settle      float64    `bigquery:"settle"`
	DeltaSettle float64    `bigquery:"deltasettle"`
	IV          int        `bigquery:"iv"`
	Volume      int        `bigquery:"volume"`
	OI          int        `bigquery:"oi"`
	DeltaOI     int        `bigquery:"deltaoi"`
}

func main() {
	// fmt.Println("main")

	records, err := GetRecords("ccass")
	if err != nil {
		fmt.Println(err.Error())
	}
	fmt.Println(len(records))
	fmt.Println(PrettyPrint(records))

	// err = bulkInsert(records, 500)
	// if err != nil {
	// 	fmt.Println(err.Error())
	// }

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

func GetRecords(table string) ([]CCASS, error) {
	var records []CCASS
	db, err := GetConnection()
	defer db.Close()
	if err != nil {
		return records, err
	}
	queryF := `
    SELECT *
    FROM %s
    WHERE date >= '2019-04-01' and date < '2019-05-01'
    LIMIT 100
`

	query := fmt.Sprintf(queryF, table)
	fmt.Println(query)

	rows, err := db.Query(query)
	if err != nil {
		return records, err
	}

	for rows.Next() {
		var (
			r           CCASS
			date        time.Time
			participant sql.NullString
			id          int
		)
		err = rows.Scan(&id, &r.ParticipantCode, &participant, &r.Number, &r.CodeF, &date, &r.Percentage)
		if err != nil {
			return records, err
		}
		_ = id
		d := civil.DateOf(date.Round(0))
		r.Date = d
		r.Code, _ = convertCode(r.CodeF)

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

func chunkStruct(items []CCASS, chunkSize int) ([][]CCASS, error) {
	var chunks [][]CCASS

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

// bulkInsert breaks the list into smaller chunks, and insert into bigquery
func bulkInsert(records []CCASS, size int) error {
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
func insertRows(records []CCASS) error {

	ctx := context.Background()
	client, err := bigquery.NewClient(ctx, "stock-lib")
	if err != nil {
		return fmt.Errorf("bigquery.NewClient: %v", err)
	}
	defer client.Close()

	inserter := client.Dataset("stock").Table("ccass").Inserter()

	var items []*CCASS
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

func convertCodeF(in int) (string, error) {

	if in == 0 {
		return "", fmt.Errorf("Zero code")
	}

	s := fmt.Sprintf("%05d", in)
	return s, nil
}
