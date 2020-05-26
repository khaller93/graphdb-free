package main

import (
    "fmt"
    "io/ioutil"
    "os"
    "os/exec"
    "path/filepath"
)

const PreloadTool string = "/opt/graphdb/bin/preload"

// checks whether a file exists at the given path.
func fExists(name string) bool {
    stat, err := os.Stat(name)
    if err != nil {
        return !os.IsNotExist(err)
    } else {
        return !stat.IsDir()
    }
}

// checks whether a directory exists at the given path.
func dExists(name string) bool {
    stat, err := os.Stat(name)
    if err != nil {
        return !os.IsNotExist(err)
    } else {
        return stat.IsDir()
    }
}

// initializes the repository configured in the given directory.
func InitRepository(repositoryDirectory string) {
    fmt.Printf("%s ----- CHECK %s. -----\n", LogPrefix, repositoryDirectory)
    if !fExists(filepath.Join(repositoryDirectory, "init.lock")) {
        configPath := filepath.Join(repositoryDirectory, "config.ttl")
        if fExists(configPath) {
            absConfigPath, err := filepath.Abs(configPath)
            if err == nil {
                // construct arguments for init
                args := make([]string, 0)
                toLoadFolder := filepath.Join(repositoryDirectory, "toLoad")
                if dExists(toLoadFolder) {
                    absToLoadFolder, err := filepath.Abs(toLoadFolder)
                    if err == nil {
                        args = append(args, absToLoadFolder)
                    }
                } else {
                    fmt.Printf("%s Warning: Could not find data to load for '%s'. 'toLoad' is missing.\n",
                        LogPrefix, repositoryDirectory)
                }
                args = append(args, "-c", absConfigPath, "-p", "--force")
                // command execution
                cmd := exec.Command(PreloadTool, args...)
                cmd.Stdout = os.Stdout
                cmd.Stderr = os.Stderr
                err := cmd.Run()
                if err == nil {
                    err := ioutil.WriteFile(filepath.Join(repositoryDirectory, "init.lock"), []byte("locked"), 0644)
                    if err != nil {
                        fmt.Printf("%s Error: %s", LogPrefix, err.Error())
                    }
                }
            } else {
                fmt.Printf("%s Error: Could not find config.ttl for '%s'. %s\n", LogPrefix, repositoryDirectory,
                    err.Error())
            }
        } else {
            fmt.Printf("%s Error: config.ttl must exist for initializing a repository, but does not exists for '%v' \n",
                LogPrefix, repositoryDirectory)
        }
    } else {
        fmt.Printf("%s ----- %s. ALREADY INITIALIZED -----\n", LogPrefix, repositoryDirectory)
    }
}
