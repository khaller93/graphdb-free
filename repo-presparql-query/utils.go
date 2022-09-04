package main

import "os"

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
