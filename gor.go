package main
import (
"fmt"
"net/http"
"log"
"encoding/base64"
"io/ioutil"
"net/url"
)

/* ****************************************************** */
func main() {
http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
    http.ServeFile(w, r, "plot.html")
})
http.HandleFunc("/getchartr", GetChartR)
fmt.Printf("Starting server get from R...\n")
  if err := http.ListenAndServe(":8080", nil); err != nil { 
  log.Fatal(err)
  }
}

/* ****************************************************** */
func GetChartR(w http.ResponseWriter, r *http.Request) {
// ---------------------------------------------------------
if r.Method == "POST" {
// ---------------------------------------------------------
  if err := r.ParseMultipartForm(64 << 20); err != nil {
  fmt.Println("ParseForm() err: ", err)
  fmt.Fprintf(w, "ParseForm() err: %v", err)
  checkErr(err, "Ошибка запроса POST: GetChartR")
  }
// ---------------------------------------------------------
info := r.FormValue("info")
fmt.Println("Получено GetChartR:", info)

sOut := "[1.25,2.38,3.54,3.1563]"

data := url.Values{}
data.Set("a", sOut)
data.Set("b", "b")
// Запрос к серверу R (использовать свой адрес)
response, err := http.PostForm("http://localhost:8000/plotly", data)
checkErr(err, "Не могу выполнить запрос к R")
//
defer response.Body.Close()
bytes, err := ioutil.ReadAll(response.Body)
checkErr(err, "Не могу получить ответ от R")

var base64Encoding string
base64Encoding = base64.StdEncoding.EncodeToString(bytes)
base64Encoding = "data:image/png;base64," + base64Encoding
fmt.Fprintf(w, "%v", base64Encoding)
// ---------------------------------------------------------
}
}

// *********************************************************
func checkErr(err error, mes string) {
  if err != nil {
  fmt.Println(mes)
  panic(err)
  }
}

