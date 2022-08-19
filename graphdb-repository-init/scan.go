package main

import (
	"io/ioutil"
	"path/filepath"
)

// Scan scans the given directory for sub folders which might contain the
// required information for initializing a repository.
func Scan(directoryPath string) ([]string, error) {
	repoFolders := make([]string, 0)
	files, err := ioutil.ReadDir(directoryPath)
	if err == nil {
		for _, f := range files {
			if f.IsDir() {
				repoFolders = append(repoFolders, filepath.Join(directoryPath,
					f.Name()))
			}
		}
	}
	return repoFolders, err
}
