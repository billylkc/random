package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	_ "github.com/lib/pq"
)

func main() {
	fmt.Println("main")

	bool, err := RecordExists("sector", "2022-01-25")
	if err != nil {
		fmt.Println(err.Error())
	}

	fmt.Println(bool)

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

func GetRecords(table string) error {
	db, err := GetConnection()
	if err != nil {
		return err
	}
	queryF := `
    SELECT *
    FROM %s
    WHERE date = '2022-01-25'`

	query := fmt.Sprintf(queryF, table)
	fmt.Println(query)

	return nil
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
