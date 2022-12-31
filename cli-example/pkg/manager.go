package pkg

import (
	"fmt"
	"io/ioutil"
	"log"

	"github.com/YoungJinJung/devops-lesson/cli-example/helper"

	"github.com/spf13/viper"
)

func AddKeyValuePair(key string, value string) {
	if validateKeyValuePair(key, value) {
		log.Printf("Validation not met for %s.", key)
	} else {
		writeKeyValuePair(key, value)
	}
}

func UpdateKeyValuePair(key string, value string) {
	writeKeyValuePair(key, value)
}

func DeleteKeyValuePair(key string) {
	DeleteKeyHack(key)
}

func DeleteKeyHack(key string) {
	settings := viper.AllSettings()
	delete(settings, key)

	var parsedSettings string
	for key, value := range settings {
		parsedSettings = fmt.Sprintf("%s\n%s: %s", parsedSettings, key, value)
	}

	d1 := []byte(parsedSettings)
	helper.HandleError(ioutil.WriteFile(viper.ConfigFileUsed(), d1, 0644))
}

func writeKeyValuePair(key string, value interface{}) {
	//write code for write key pair method
}

func findExistingKey(searchKey string) bool {
	//write code for findExistingKey method
	return false
}

func validateKeyValuePair(key string, value string) bool {
	//write code for findExistingKey method
	return false
}
