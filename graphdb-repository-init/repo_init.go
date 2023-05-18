package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"
)

const PreloadTool string = "importrdf"

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

// assembleToLoadFolderPath assembles the path to the toLoad folder
// as it is required for the preload tool.
func assembleToLoadFolderPath(repositoryDirectory string) string {
	toLoadFolder := filepath.Join(repositoryDirectory, "toLoad")
	if dExists(toLoadFolder) {
		var toLoadFolder, err = filepath.Abs(toLoadFolder)
		if err == nil {
			return toLoadFolder
		} else {
			fmt.Printf("%s Warning: Couldn't create absolute path to folder '%s': %s\n",
				LogPrefix, repositoryDirectory, err.Error())
		}
	} else {
		fmt.Printf("%s Warning: Couldn't find data to load for '%s'. 'toLoad' is missing.\n",
			LogPrefix, repositoryDirectory)
	}
	p := "/tmp/toLoad.tmp"
	err := os.MkdirAll(p, os.ModeDir)
	if err != nil {
		fmt.Printf("%s Warning: Couldn't create temporary folder '%s': %s\n",
			LogPrefix, p, err.Error())
	}
	return p
}

// InitRepository initializes the repository configured in the given directory. returns true,
// if the repository could be initialized, otherwise false.
func InitRepository(repositoryDirectory string) bool {
	fmt.Printf("%s ----- CHECK %s. -----\n", LogPrefix, repositoryDirectory)
	if !fExists(filepath.Join(repositoryDirectory, "init.lock")) {
		configPath := filepath.Join(repositoryDirectory, "config.ttl")
		if fExists(configPath) {
			absConfigPath, err := filepath.Abs(configPath)
			if err == nil {
				// construct arguments for init
				args := []string{
					"load",
					"-c",
					absConfigPath,
					"--partial-load",
					"--force",
				}
				toLoadFolder := assembleToLoadFolderPath(repositoryDirectory)
				args = append(args, toLoadFolder)
				// command execution
				cmd := exec.Command(PreloadTool, args...)
				cmd.Stdout = os.Stdout
				cmd.Stderr = os.Stderr
				err := cmd.Run()
				if err == nil {
					err := ioutil.WriteFile(filepath.Join(repositoryDirectory, "init.lock"), []byte("locked"), 0644)
					if err != nil {
						fmt.Printf("%s Error: Failed to write the lock for a new initialization. %s",
							LogPrefix, err.Error())
					}
					return true
				} else {
					fmt.Printf("%s Error: Execution of %s command failed. %s\n", LogPrefix, PreloadTool,
						err.Error())
				}
			} else {
				fmt.Printf("%s Error: Could not find config.ttl for '%s'. %s\n", LogPrefix, repositoryDirectory,
					err.Error())
			}
		} else {
			fmt.Printf("%s Error: config.ttl must exist for initializing a repository, but does not exists for '%v' \n",
				LogPrefix, repositoryDirectory)
		}
		return false
	}
	fmt.Printf("%s ----- %s. ALREADY INITIALIZED -----\n", LogPrefix, repositoryDirectory)
	return true
}
