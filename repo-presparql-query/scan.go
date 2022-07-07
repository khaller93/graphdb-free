package main

import (
	"io/ioutil"
	"os"
	"path/filepath"
	"regexp"
)

var sparqlFileRegex = regexp.MustCompile("^.*\\.sparql$")

// ScanForRepositories scans the given directory for sub folders which
// might contain the required information for initializing a repository.
func ScanForRepositories(directoryPath string) ([]string, error) {
	repoFolders := make([]string, 0)
	files, err := ioutil.ReadDir(directoryPath)
	if err == nil {
		for _, f := range files {
			if f.IsDir() {
				repoFolders = append(repoFolders, filepath.Join(directoryPath, f.Name()))
			}
		}
	}
	return repoFolders, err
}

// ScanForSPARQLFiles scans the given directory for files with the file ending
// '.sparql' and returns a list of paths to them.
func ScanForSPARQLFiles(repositoryPath string) ([]string, error) {
	sparqlFiles := make([]string, 0)
	err := filepath.Walk(repositoryPath, func(path string, info os.FileInfo, err error) error {
		if err == nil {
			if !info.IsDir() {
				match := sparqlFileRegex.MatchString(path)
				if match {
					sparqlFiles = append(sparqlFiles, path)
				}
			}
		}
		return err
	})
	return sparqlFiles, err
}
