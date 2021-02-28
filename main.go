package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"regexp"
	"strconv"
	"strings"

	"github.com/PuerkitoBio/goquery"
)

type Industry struct {
	Group     string
	Industry  string
	CodeF     string
	Close     float64
	Change    float64
	ChangePct float64
	Volume    int
	Turnover  int
	PE        float64 // Price per Earnings
	PB        float64 // Price to Book
	YieldPct  float64
	MarketCap int
}

func main() {
	// GetIndustryDetails()
	dev()
}

// PrettyPrint to print struct in a readable way
func PrettyPrint(i interface{}) string {
	s, _ := json.MarshalIndent(i, "", "\t")
	return string(s)
}

func GetIndustryDetails() {
	links := getLinks()
	var results []Industry

	for _, link := range links {
		industry, _ := getDetails(link)
		results = append(results, industry...)
	}

	fmt.Println(PrettyPrint(results))
	fmt.Println(len(results))

}

func getDetails(link string) ([]Industry, error) {

	var result []Industry
	fmt.Printf("Getting link - %s\n", link)

	res, err := http.Get(link)
	if err != nil {
		log.Fatal(err)
	}
	defer res.Body.Close()
	if res.StatusCode != 200 {
		log.Fatalf("status code error: %d %s", res.StatusCode, res.Status)
	}

	doc, err := goquery.NewDocumentFromReader(res.Body)
	if err != nil {
		log.Fatal(err)
	}

	// Title
	var (
		group     string // Higher group, e.g. Materials
		industry  string // Industry, e.g. Chemical Products
		code      string
		close     float64
		change    float64
		changePct float64
		volume    int
		turnover  int
		pe        float64
		pb        float64
		yield     float64
		marketCap int
	)
	doc.Find("h1").Each(func(i int, s *goquery.Selection) {
		text := s.Text() // e.g. Industry Details - Materials - Chemical Products
		texts := strings.Split(text, "-")
		if len(texts) == 3 {
			group = strings.TrimSpace(texts[1])    // e.g. Materials
			industry = strings.TrimSpace(texts[2]) // e.g. Chemical Products
		}
	})

	// Links
	doc.Find("span.float_l").Each(func(i int, s *goquery.Selection) {
		code = strings.TrimSpace(s.Text()) // e.g. 00301.HK
		if strings.Contains(code, "0") {   // Check starts with 0
			code = strings.ReplaceAll(code, ".HK", "") // 00301.HK -> 00301
			ss := s.ParentsUntil("tbody")
			var values []string

			ss.Each(func(j int, tb *goquery.Selection) {
				tb.Find("td.cls.txt_r.pad3").Each(func(i int, td *goquery.Selection) {
					// fmt.Println(td.Text())
					values = append(values, td.Text())
				})
			})

			if len(values) == 10 {
				_ = values[0] // Some empty string
				close, _ = parseF(values[1])
				change, _ = parseF(values[2])
				changePct, _ = parseF(values[3])
				volume, _ = parseI(values[4])
				turnover, _ = parseI(values[5])
				pe, _ = parseF(values[6])
				pb, _ = parseF(values[7])
				yield, _ = parseF(values[8])
				marketCap, _ = parseI(values[9])

				rec := Industry{
					Group:     group,
					Industry:  industry,
					CodeF:     code,
					Close:     close,
					Change:    change,
					ChangePct: changePct,
					Volume:    volume,
					Turnover:  turnover,
					PE:        pe,
					PB:        pb,
					YieldPct:  yield,
					MarketCap: marketCap,
				}
				result = append(result, rec)
			}
		}
	})

	return result, nil
}

func getLinks() []string {
	var links []string
	res, err := http.Get("http://www.aastocks.com/en/stocks/market/industry/sector-industry-details.aspx")
	if err != nil {
		log.Fatal(err)
	}
	defer res.Body.Close()
	if res.StatusCode != 200 {
		log.Fatalf("status code error: %d %s", res.StatusCode, res.Status)
	}
	body, err := ioutil.ReadAll(res.Body)

	r := regexp.MustCompile("gotoindustry\\(\\'(\\d{4})\\'\\)")
	matches := r.FindAllStringSubmatch(string(body), -1)
	for _, match := range matches {
		if len(match) >= 2 {
			industryCode := match[1]
			link := fmt.Sprintf("http://www.aastocks.com/en/stocks/market/industry/sector-industry-details.aspx?industrysymbol=%s&t=1&s=&o=&p=", industryCode)

			links = append(links, link)
		}
	}
	return links
}

func dev() {
	res, err := http.Get("http://www.aastocks.com/en/stocks/market/industry/sector-industry-details.aspx?industrysymbol=2033&t=1&hk=0")
	if err != nil {
		log.Fatal(err)
	}
	defer res.Body.Close()
	if res.StatusCode != 200 {
		log.Fatalf("status code error: %d %s", res.StatusCode, res.Status)
	}
	body, err := ioutil.ReadAll(res.Body)
	re := regexp.MustCompile(`.*Last Update:\s*(\d{4}\/\d{2}\/\d{2})`)
	matched := re.FindAllSubmatch(body, -1)

	fmt.Println(string(matched[0][1]))

}

func parseF(s string) (float64, error) {
	s = strings.ReplaceAll(s, "%", "")
	num, err := strconv.ParseFloat(s, 64)
	if err != nil {
		return 0.0, nil
	}
	return num, err
}

func parseI(s string) (int, error) {
	var (
		num int
		f   float64
		err error
	)

	if strings.Contains(s, "N/A") {
		num = 0
	}
	if strings.Contains(s, "K") {
		s = strings.ReplaceAll(s, "K", "")
		f, err = strconv.ParseFloat(s, 64)
		num = int(f * 1_000)
	}
	if strings.Contains(s, "M") {
		s = strings.ReplaceAll(s, "M", "")
		f, err = strconv.ParseFloat(s, 64)
		num = int(f * 1_000_000)
	}
	if strings.Contains(s, "B") {
		s = strings.ReplaceAll(s, "B", "")
		f, err = strconv.ParseFloat(s, 64)
		num = int(f * 1_000_000_000)
	}
	if err != nil {
		return 0, err
	}

	return num, nil
}
