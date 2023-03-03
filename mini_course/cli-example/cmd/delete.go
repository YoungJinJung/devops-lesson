/*
Copyright © 2022 NAME HERE <EMAIL ADDRESS>

*/
package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

// deleteCmd represents the delete command
var deleteCmd = &cobra.Command{
	Use:   "delete",
	Short: "The 'delete' subcommand removes a key value pair from the configuration file.",
	Long:  `The 'delete' subcommand removes a key value pair from the configuration file.`,
	Run: func(cmd *cobra.Command, args []string) {
		key, _ := cmd.Flags().GetString("key")
		fmt.Printf("\n\n    **** Deleting key: %s ****\n\n", key)
	},
}

func init() {
	rootCmd.AddCommand(deleteCmd)
}
