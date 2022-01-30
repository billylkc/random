package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/PuerkitoBio/goquery"
	"github.com/gocarina/gocsv"
	"github.com/pkg/errors"
	"github.com/sirupsen/logrus"
)

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

type option func(*Quandl)

type Company struct {
	Code string
	Name string
}

// GetCompanyName looks up company name from HKEX
func getcompanyname(c int) (Company, error) {
	var result Company

	// Handle input, e.g. code = 00005, date 2021-02-01
	targetCode := fmt.Sprintf("%05d", c) // zfill to 5 digit
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
			codeStr := matched[i][1]
			companyStr := matched[i][2]

			if codeStr == targetCode {
				result = Company{
					Code: targetCode,
					Name: companyStr,
				}
				break // find then break
			}
		}
	})
	return result, nil
}

// GetCompanyList looks up all the companies' code on HKEX
func GetCompanyList() ([]int, error) {
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

// New as Quandl constructor
func New() Quandl {
	today := time.Now().Format("2006-01-02")

	return Quandl{
		limit: 10,
		end:   today,
		order: "desc",
	}
}

func send(nums ...int) <-chan int {
	out := make(chan int)
	go func() {
		for _, n := range nums {
			out <- n
		}
		close(out)
	}()
	return out
}

func process(done <-chan bool, in <-chan int) <-chan []HistoricalPrice {
	out := make(chan []HistoricalPrice)
	go func() {
		for n := range in {
			stock, _ := GetStockByCode(n)
			out <- stock
		}
		close(out)
	}()
	return out
}

func merge(done <-chan bool, cs ...<-chan []HistoricalPrice) <-chan []HistoricalPrice {
	var wg sync.WaitGroup
	out := make(chan []HistoricalPrice)

	// Start an output goroutine for each input channel in cs.  output
	// copies values from c to out until c is closed, then calls wg.Done.
	output := func(c <-chan []HistoricalPrice) {
		for n := range c {
			out <- n
		}
		wg.Done()
	}
	wg.Add(len(cs))
	for _, c := range cs {
		go output(c)
	}

	// Start a goroutine to close out once all the output goroutines are
	// done.  This must start after the wg.Add call.
	go func() {
		wg.Wait()
		close(out)
	}()
	return out
}

// GetStockByCode is a wrapper to get all the historical dat a for a single stock
func GetStockByCode(code int) ([]HistoricalPrice, error) {
	q := New()
	return q.GetStock(code, "2022-01-28")
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
		return []HistoricalPrice{}, errors.New("not found")
	}
	return result, nil
}

// Option sets the options specified.
func (q *Quandl) option(opts ...option) {
	for _, opt := range opts {
		opt(q)
	}
}

//getEndpoint gets the endpoint for the quandl api
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

func main() {
	// in := send(2, 3)

	// // Distribute the sq work across two goroutines that both read from in.
	// c1 := process(in)
	// c2 := process(in)

	// // Consume the merged output from c1 and c2.
	// for n := range merge(c1, c2) {
	// 	fmt.Println(n) // 4 then 9, or 9 then 4
	// }
	date := "2021-01-28"
	companies, err := GetCompanyList()
	if err != nil {
		fmt.Println(err.Error())
	}

	fmt.Printf("Getting date - %s - %d \n\n", date, len(companies))
	fmt.Println(companies[0:10])

}

func GetAllStocks(data ...int) []HistoricalPrice {
	var res []HistoricalPrice
	numWorkers := 5

	done := make(chan bool)
	defer close(done)

	// Send data
	in := send(data...)

	// Start workers to process the data
	workers := make([]<-chan []HistoricalPrice, numWorkers)
	for i := 0; i < len(workers); i++ {
		workers[i] = process(done, in)
	}

	// Merge all channels, and sort
	var result []HistoricalPrice

	for n := range merge(done, workers...) {
		result = append(result, n...)
	}
	sort.SliceStable(result, func(i, j int) bool {
		return result[i].Code < result[j].Code
	})

	return res

}

// PrettyPrint to print struct in a readable way
func PrettyPrint(i interface{}) string {
	s, _ := json.MarshalIndent(i, "", "\t")
	return string(s)
}
