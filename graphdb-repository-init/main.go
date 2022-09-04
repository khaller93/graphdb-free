package main

import (
	"fmt"
	"log"
	"os"
	"strings"
)

const LogPrefix string = "[REPO INIT]"

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
	appName := "graphdb-repository-init"
	if len(os.Args) > 0 {
		appName = os.Args[0]
	}
	fmt.Printf("%s\nusage:\n\t%s <repos-init-directory>\n", errorLine,
		appName)
}

// initializeRepositories initializes the given array of repository folders. An
// error will be returned, if one of the initializations failed.
func initializeRepositories(repoFolders []string) error {
	for _, repoFolder := range repoFolders {
		err := InitRepository(repoFolder)
		if err != nil {
			return err
		}
	}
	return nil
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
	InfoLogger.Printf("starting to check whether repositories need to be initialized")
	repoFolders, err := Scan(repositoryInitDirectoryPath)
	if err != nil {
		ErrorLogger.Printf("couldn't check subfolders of directory '%s'",
			repositoryInitDirectoryPath)
		os.Exit(1)
	}
	InfoLogger.Printf("detected following repository folders: [%s]",
		strings.Join(repoFolders, ","))
	err = initializeRepositories(repoFolders)
	if err != nil {
		ErrorLogger.Printf(err.Error())
		os.Exit(1)
	}
}
