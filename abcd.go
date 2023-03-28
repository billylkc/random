package main

import (
	"encoding/json"
	"fmt"
	"html"
	"io"
	"io/ioutil"
	"net/http"
	"os"
	"regexp"
	"strconv"
	"strings"
	"time"

	"github.com/PuerkitoBio/goquery"
	"github.com/gocarina/gocsv"
	"github.com/pkg/errors"
	"github.com/sirupsen/logrus"
)

// PrettyPrint to print struct in a readable way
func PrettyPrint(i interface{}) string {
	s, _ := json.MarshalIndent(i, "", "\t")
	return string(s)
}

func main() {

	// stage := 1
	// date := ""
	// prices, err := GetStocks(stage, date)
	// if err != nil {
	// 	fmt.Println(err)
	// }
	// PrettyPrint(prices)

	// codes, err := GetCompanyList()
	// if err != nil {
	// 	// Error(err.Error())
	// 	fmt.Println(err.Error())

	// }
	// PrettyPrint(codes)

	fmt.Println("Main")
	token := os.Getenv("QUANDL_TOKEN")
	fmt.Printf("token: %+v\n", token)

	// Create Quandl object
	logger := logrus.New()
	logger.Out = io.Writer(os.Stdout)

	date := "2023-03-28"
	q := NewQuandl(logger, date)
	fmt.Println(PrettyPrint(q))
	code, err := q.GetStock(5, date)
	if err != nil {
		fmt.Println(err)
	}
	fmt.Println(PrettyPrint(code))

}

// HistoricalPrice as the struct for the API result
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

// Quandl
type Quandl struct {
	logger *logrus.Logger
	limit  int
	start  string // not using start date right now
	end    string
	order  string
}

// DownloadStock
func DownloadStock(w http.ResponseWriter, r *http.Request) {

	today := time.Now().Format("2006-01-02")

	// Get data
	stage := 1
	records, err := GetStocks(stage, today)
	if err != nil {
		fmt.Println(err)
	}

	// Return result
	msg := fmt.Sprintf("No of records - %d", len(records))

	fmt.Fprint(w, html.EscapeString(msg))
}

// GetStocks gets the stock with different stage
func GetStocks(stage int, date string) ([]HistoricalPrice, error) {

	var result []HistoricalPrice

	// Info(fmt.Sprintf("Getting stock for stage - %d", stage))

	// Handle inputs. Within 1 and 9
	if (stage <= 0) || (stage > 10) {
		return result, fmt.Errorf("Input should be between 1-9.")
	}

	codes, err := GetCompanyList()
	if err != nil {
		// Error(err.Error())
		fmt.Println(err.Error())

	}

	// Create Quandl object
	logger := logrus.New()
	logger.Out = io.Writer(os.Stdout)
	q := NewQuandl(logger, date)

	// Set lower and upper to split getting code part to different part, 1-999, 1000-1999, etc..
	lower := (stage - 1) * 1000
	upper := stage * 1000
	n := len(codes)
	var counter int
	for i, code := range codes {
		if code >= lower && code < upper {

			// Check for consecutive failures
			if counter >= 20 {
				return []HistoricalPrice{}, fmt.Errorf("Data not ready - %s. Or too many consecutive fails.", date)
			}

			if (i > 0) && ((i % 100) == 0) {
				fmt.Println(fmt.Sprintf("Finished - [%d/%d]", i, n))
			}

			res, err := q.GetStock(code, date)
			if err != nil {
				counter += 1
				fmt.Println(fmt.Sprintf("Cannot get stock - %d", code))
			} else {
				counter = 0 // reset
			}
			result = append(result, res...)
		}
	}
	fmt.Println(fmt.Sprintf("Finished - [%d/%d]", n, n))
	return result, nil
}

// GetStock is the underlying function to get the stock by different code and date settings
func (q *Quandl) GetStock(code int, date string) ([]HistoricalPrice, error) {
	var data []HistoricalPrice

	// Derive input
	if date == "" {
		today := time.Now().Format("2006-01-02")
		q.option(setEndDate(today))
		q.option(setLimit(10000))
	} else {
		q.option(setEndDate(date))
		q.option(setLimit(10))
	}

	codeF := fmt.Sprintf("%05d", code)
	endpoint, _ := q.getEndpoint(code)
	fmt.Println(endpoint)

	response, err := http.Get(endpoint)
	if err != nil {
		return data, errors.Wrap(err, "something is wrong with the request")
	}
	defer response.Body.Close()
	body, err := ioutil.ReadAll(response.Body)

	if err := gocsv.UnmarshalBytes(body, &data); err != nil {
		q.logger.Error("unable to unmarshal the response")
		return data, errors.New("unable to unmarshal the response")
	}

	for i, _ := range data {
		data[i].Code = code
		data[i].CodeF = codeF
		data[i].Volume = data[i].Volume * 1000
		data[i].Turnover = data[i].Turnover * 1000
	}

	// Handle date logic
	var matched bool
	var result []HistoricalPrice
	if date == "" {
		matched = true
		result = data
	} else {
		for _, d := range data {
			if d.Date == date {
				matched = true
				result = []HistoricalPrice{d}
			}
		}
	}
	if !matched {
		return []HistoricalPrice{}, errors.New(fmt.Sprintf("Records not found on date - %s", date))
	}
	return result, nil
}

type option func(*Quandl)

// NewQuandl as Quandl constructor
func NewQuandl(logger *logrus.Logger, date string) Quandl {

	return Quandl{
		logger: logger,
		limit:  10,
		end:    date,
		order:  "desc",
	}
}

// GetCompanyList looks up all the companies' code on HKEX
func GetCompanyList() ([]int, error) {
	// http://www.etnet.com.hk/www/eng/stocks/cas_list.php

	var result []int

	currentTime := time.Now()
	d := currentTime.Format("2006-01-02")
	d = strings.ReplaceAll(d, "-", "") // date in string format

	url := fmt.Sprintf("https://www.hkexnews.hk/sdw/search/stocklist_c.aspx?sortby=stockcode&shareholdingdate=%s", d)
	res, err := http.Get(url)
	if err != nil {
		return result, err
	}
	defer res.Body.Close()
	if res.StatusCode != 200 {
		return result, err
	}

	// Load the HTML document
	doc, err := goquery.NewDocumentFromReader(res.Body)
	if err != nil {
		return result, err
	}

	// Find the review items
	doc.Find("table.table > tbody > tr").Each(func(i int, s *goquery.Selection) {
		// For each item found, get the band and title

		content := s.Find("td").Text()
		regex := *regexp.MustCompile(`\s*(\d{5})\s*(.*)`)
		matched := regex.FindAllStringSubmatch(content, -1)
		for i := range matched {
			codeF := matched[i][1]
			code, err := strconv.Atoi(codeF)
			if err != nil { // ignore
				fmt.Println(err.Error())
			}
			if code < 10000 {
				if code <= 8000 || code >= 9000 {
					result = append(result, code)
				}
			}
		}
	})
	if len(result) == 0 {
		return result, errors.New("something wrong with the hkex company list")
	}
	return result, nil
}

// Option sets the options specified.
func (q *Quandl) option(opts ...option) {
	for _, opt := range opts {
		opt(q)
	}
}

// getEndpoint gets the endpoint for the quandl api
func (q *Quandl) getEndpoint(code int) (string, error) {
	token, err := getToken()
	if err != nil {
		return "", err
	}
	codeF := fmt.Sprintf("%05d", code)
	endpoint := fmt.Sprintf("https://www.quandl.com/api/v3/datasets/HKEX/%s/data.csv?limit=%d&end_date=%s&order=%s&api_key=%s", codeF, q.limit, q.end, q.order, token)
	return endpoint, nil
}

// getToken returns the quandl api token
func getToken() (string, error) {
	token := os.Getenv("QUANDL_TOKEN")
	fmt.Println(token)

	if token == "" {
		return "", errors.New("please check you env variable QUANDL_TOKEN")
	}
	return token, nil
}

func setLimit(n int) option {
	return func(q *Quandl) {
		q.limit = n
	}
}
func setOrder(settings string) option {
	return func(q *Quandl) {
		q.order = settings
	}
}
func setStartDate(settings string) option {
	return func(q *Quandl) {
		q.start = settings
	}
}
func setEndDate(settings string) option {
	return func(q *Quandl) {
		q.end = settings
	}
}
