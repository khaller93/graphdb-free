package main

import (
	"fmt"
	"github.com/knakk/rdf"
	"io"
	"io/ioutil"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
	"time"
)

// fExists checks whether a file exists at the given path.
func fExists(name string) bool {
	stat, err := os.Stat(name)
	if err != nil {
		return !os.IsNotExist(err)
	} else {
		return !stat.IsDir()
	}
}

// dExists checks whether a directory exists at the given path.
func dExists(name string) bool {
	stat, err := os.Stat(name)
	if err != nil {
		return !os.IsNotExist(err)
	} else {
		return stat.IsDir()
	}
}

// containsQuery checks whether the given query is in the list of queries.
func containsQuery(queries []string, query string) bool {
	for _, entry := range queries {
		if query == entry {
			return true
		}
	}
	return false
}

// queryExecutionResponse is a response type for the execution of a query.
type queryExecutionResponse struct {
	sparqlFile string
	success    bool
	err        error
}

func executeQuery(repositoryID string, address string, sparqlFilePath string, successChannel chan queryExecutionResponse) {
	fmt.Printf("%s Executing the SPARQL query '%s'.\n", LogPrefix, sparqlFilePath)
	sparqlQueryFile, err := os.Open(sparqlFilePath)
	if err == nil {
		resp, err := http.Post(fmt.Sprintf("http://%v/repositories/%v/statements", address, repositoryID),
			"application/sparql-update", sparqlQueryFile)
		if resp != nil && err == nil {
			if 200 <= resp.StatusCode && resp.StatusCode < 300 {
				successChannel <- queryExecutionResponse{
					sparqlFile: sparqlFilePath,
					success:    true,
				}
				return
			} else {
				successChannel <- queryExecutionResponse{
					sparqlFile: sparqlFilePath,
					success:    false,
					err: fmt.Errorf("executing sparql query '%s' returned status code %v",
						sparqlFilePath, resp.StatusCode),
				}
			}
		}
	}
	successChannel <- queryExecutionResponse{
		sparqlFile: sparqlFilePath,
		success:    false,
		err:        err,
	}
}

// getRepositoryID gets the repository ID from the configuration file in turtle syntax.
func getRepositoryID(configFilePath string) (string, error) {
	configFile, err := os.Open(configFilePath)
	if err == nil {
		dec := rdf.NewTripleDecoder(configFile, rdf.Turtle)
		for triple, err := dec.Decode(); err != io.EOF; triple, err = dec.Decode() {
			if err == nil && triple.Pred.String() == "http://www.openrdf.org/config/repository#repositoryID" {
				return triple.Obj.String(), nil
			}
		}
	}
	return "", err
}

// waitForGraphDB waiting for the GraphDB on the given port to be reachable.
func waitForGraphDB() string {
	n := 1
	for {
		address, err := getGraphDBAddress()
		if err != nil {
			panic(fmt.Sprintf("could not check for the GraphDB process and its sockets: %s", err.Error()))
		}
		if address == "" {
			continue
		}
		graphdbURL := fmt.Sprintf("http://%v", address)
		resp, err := http.Get(graphdbURL)
		if err == nil {
			if 200 <= resp.StatusCode && resp.StatusCode < 300 {
				return address
			}
		} else {
			fmt.Printf("%s Could not connect to GraphDB instance. %v\n", LogPrefix, err)
		}
		fmt.Printf("%s Attempt %v: Failed to connect to GraphDB.\n", LogPrefix, n)
		n += 1
		time.Sleep(10 * time.Second)
	}
}

// getInitializedQueries gets all the queries that have been specified
// in the sparql.lock file, meaning they already have been
// initialized.
func getInitializedQueries(repositoryPath string) []string {
	queries := make([]string, 0)
	sparqlLock := filepath.Join(repositoryPath, "sparql.lock")
	if fExists(sparqlLock) {
		lockData, err := ioutil.ReadFile(sparqlLock)
		if lockData != nil && err == nil {
			lines := strings.Split(string(lockData), "\n")
			for _, line := range lines {
				if line != "" {
					queries = append(queries, line)
				}
			}
		}
	}
	return queries
}

// writeInitializedQueries writes the successfully initialized queries to the
// SPARQL lock.
func writeInitializedQueries(repositoryPath string, queries []string) error {
	sparqlLock := filepath.Join(repositoryPath, "sparql.lock")
	queriesString := ""
	for _, entry := range queries {
		queriesString = queriesString + entry + "\n"
	}
	return ioutil.WriteFile(sparqlLock, []byte(queriesString), 0644)
}

func getGraphDBAddress() (string, error) {
	cmd := exec.Command("ss", "-tulpn")
	out, err := cmd.Output()
	if err == nil {
		ssOut := string(out)
		tabRegex := regexp.MustCompile(`\s+`)
		for _, line := range strings.Split(ssOut, "\n") {
			if strings.Contains(line, "\"java\"") {
				tabs := tabRegex.Split(line, -1)
				if len(tabs) >= 4 {
					return tabs[4], nil
				}
			}
		}
	}
	return "", err
}

func PreQuery(repositoryPath string) {
	fmt.Printf("%s --- CHECK SPARQL QUERIES FOR %s. ---\n", LogPrefix, repositoryPath)
	sparqlDir := filepath.Join(repositoryPath, "sparql")
	if !dExists(sparqlDir) {
		panic(fmt.Sprintf("no sparql folder found for '%s'", repositoryPath))
	}
	sparqlFiles, err := ScanForSPARQLFiles(sparqlDir)
	if err != nil {
		panic(fmt.Sprintf("could not detect any SPARQL files for '%s'. %s", repositoryPath, err.Error()))
	}
	fmt.Printf("%s Detected following SPARQL files: [%s].\n", LogPrefix,
		strings.Join(sparqlFiles, ","))
	initializedQueries := getInitializedQueries(repositoryPath)
	configFilePath := filepath.Join(repositoryPath, "config.ttl")
	repositoryID, err := getRepositoryID(configFilePath)
	address := waitForGraphDB()
	if err != nil || repositoryID == "" {
		panic(fmt.Sprintf("could not get the repository ID from the file '%s'", configFilePath))
	}
	successChannel := make(chan queryExecutionResponse)
	executedQueries := make([]string, 0)
	for _, sparqlFilePath := range sparqlFiles {
		if !containsQuery(initializedQueries, sparqlFilePath) {
			executedQueries = append(executedQueries, sparqlFilePath)
			go executeQuery(repositoryID, address, sparqlFilePath, successChannel)
		} else {
			fmt.Printf("%s SPARQL file [%s] has already been initialized.\n", LogPrefix, sparqlFilePath)
		}
	}
	for i := 0; i < len(executedQueries); i++ {
		response := <-successChannel
		if response.success {
			initializedQueries = append(initializedQueries, response.sparqlFile)
		} else {
			errMessage := ""
			if response.err != nil {
				errMessage = response.err.Error()
			}
			fmt.Printf("%s SPARQL file [%s] could not be executed successfully. %s\n", LogPrefix,
				response.sparqlFile, errMessage)
		}
	}
	err = writeInitializedQueries(repositoryPath, initializedQueries)
	if err != nil {
		panic(fmt.Sprintf("could not write the initialized queries to the SPARQL lock: %s", err.Error()))
	}
}
