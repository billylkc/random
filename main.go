package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
)

func main() {
	result, err := GetHistoricalPrice(5)
	if err != nil {
		fmt.Println(err)
	}
	fmt.Println(PrettyPrint(result))
}

type HistoricalPrice struct {
	DatasetData struct {
		Limit       interface{}     `json:"limit"`
		Transform   interface{}     `json:"transform"`
		ColumnIndex interface{}     `json:"column_index"`
		ColumnNames []string        `json:"column_names"`
		StartDate   string          `json:"start_date"`
		EndDate     string          `json:"end_date"`
		Frequency   string          `json:"frequency"`
		Data        [][]interface{} `json:"data"`
		Collapse    interface{}     `json:"collapse"`
		Order       string          `json:"order"`
	} `json:"dataset_data"`
}

func GetHistoricalPrice(code int) (HistoricalPrice, error) {
	var data HistoricalPrice
	c := fmt.Sprintf("%05d", code)
	endpoint, err := getQuanEndPoint("HKEX", c, "historicalPrice")
	resp, err := http.Get(endpoint)
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)

	if err != nil {
		return data, err
	}

	if err := json.Unmarshal(body, &data); err != nil {
		panic(err)
	}

	return data, nil
}

// getQuanEndPoint returns the endpoint of the api callOB
func getQuanEndPoint(db, code, api string) (string, error) {

	token, err := getQuanToken()
	if err != nil {
		return "", err
	}

	var endpoint string
	switch api {
	case "historicalPrice":
		endpoint = "https://www.quandl.com/api/v3/datasets/HKEX/00005/data.json?api_key=%s&order=desc&end_date=2021-02-21&limit=5"
	default:
		return "", fmt.Errorf("no api endpoint - &s", api)
	}
	endpoint = fmt.Sprintf(endpoint, token)

	return endpoint, nil
}

// getQuanToken returns the
func getQuanToken() (string, error) {
	token, ok := os.LookupEnv("QUANDL_TOKEN")
	if !ok {
		return token, errors.New("quandl token not set, please check your env variable QUANDL_TOKEN")
	}
	return token, nil
}

// PrettyPrint to print struct in a readable way
func PrettyPrint(i interface{}) string {
	s, _ := json.MarshalIndent(i, "", "\t")
	return string(s)
}
