package main

import (
	"fmt"
	"log"
	"os"
	"strings"
)

const LogPrefix string = "[SPARQL PRELOAD]"

var (
	InfoLogger    *log.Logger
	WarningLogger *log.Logger
	ErrorLogger   *log.Logger
)

func init() {
	InfoLogger = log.New(os.Stdout, LogPrefix+"[INFO ] ", log.Ldate|log.Ltime)
	WarningLogger = log.New(os.Stdout, LogPrefix+"[WARN ] ", log.Ldate|log.Ltime)
	ErrorLogger = log.New(os.Stdout, LogPrefix+"[ERROR] ", log.Ldate|log.Ltime)
}

// printUsage prints a usage message with the specified error message. If the
// given error message is an empty string, then the error line will be omitted.
func printUsage(errorMsg string) {
	errorLine := ""
	if errorMsg != "" {
		errorLine = fmt.Sprintf("error: %s\n", errorMsg)
	}
	appName := "graphdb-presparql-query"
	if len(os.Args) > 0 {
		appName = os.Args[0]
	}
	fmt.Printf("%s\nusage:\n\t%s <repos-init-directory>\n",
		errorLine, appName)
}

func main() {
	n := len(os.Args)
	if n != 2 {
		if n < 2 {
			printUsage("not enough arguments specified")
		} else {
			printUsage("too many arguments specified")
		}
		os.Exit(1)
	}
	repositoryInitDirectoryPath := os.Args[1]
	if !dExists(repositoryInitDirectoryPath) {
		os.Exit(0)
	}
	InfoLogger.Printf("starting to check whether SPARQL queries need to be executed")
	repoFolders, err := ScanForRepositories(repositoryInitDirectoryPath)
	if err != nil {
		ErrorLogger.Printf("couldn't check the subfolders of directory '%s': %s",
			repositoryInitDirectoryPath, err.Error())
		os.Exit(1)
	}
	InfoLogger.Printf("detected following repository folders: [%s]",
		strings.Join(repoFolders, ","))
	defer func() {
		if err := recover(); err != nil {
			fmt.Printf("%s %v \n", LogPrefix, err)
			os.Exit(1)
		}
	}()
	for _, repoFolder := range repoFolders {
		PreQuery(repoFolder)
	}
}
