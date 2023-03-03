/*
Copyright © 2022 NAME HERE <EMAIL ADDRESS>

*/
package cmd

import (
	"github.com/spf13/cobra"
)

// updateCmd represents the update command
var updateCmd = &cobra.Command{
	Use:   "update",
	Short: "The 'update' subcommand will update a passed in key value pair for an existing set of data to the application configuration file.",
	Long: `The 'update' subcommand updates a key value pair, if the key value pair already exists it is updated, if it does
not exist then the passed in values are added to the application configuration file. For example:

'<cmd> config add --key theKey --value "the new value which will be updated for this particular key value pair."'.`,
	Run: func(cmd *cobra.Command, args []string) {
		key, _ := cmd.Flags().GetString("key")
		value, _ := cmd.Flags().GetString("value")
	},
}

func init() {
	rootCmd.AddCommand(updateCmd)
}
