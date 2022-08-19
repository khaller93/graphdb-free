package main

import (
	"fmt"
	"os"
	"strings"
)

const LogPrefix string = "[REPO INIT]"

func printUsage() {
	appName := "graphdb-repository-init"
	if len(os.Args) > 0 {
		appName = os.Args[0]
	}
	fmt.Printf("%s <repos-init-directory>\n", appName)
}

func main() {
	if len(os.Args) == 2 {
		fmt.Printf("%s Starting to check whether repositories need to be initialized.\n", LogPrefix)
		directoryPath := os.Args[1]
		repoFolders, err := Scan(directoryPath)
		if err == nil {
			fmt.Printf("%s Detected following repository folders: [%s].\n", LogPrefix,
				strings.Join(repoFolders, ","))
			for _, repoFolder := range repoFolders {
				success := InitRepository(repoFolder)
				if !success {
					os.Exit(1)
				}
			}
		} else {
			fmt.Printf("%s Could not check the subfolders of directory '%s'. %s\n", LogPrefix, directoryPath,
				err.Error())
		}
	} else {
		printUsage()
		os.Exit(1)
	}
}
