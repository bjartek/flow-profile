package main

import (

	"github.com/bjartek/go-with-the-flow/gwtf"
	"github.com/onflow/cadence"
)

func main() {

	g := gwtf.
		NewGoWithTheFlowEmulator().
		CreateAccount("first", "second")

	// create profile
	// follow

	tags := cadence.NewArray([]cadence.Value{
		cadence.String("tag1"),
		cadence.String("tag2"),
	})

	g.TransactionFromFile("create_profile").
		SignProposeAndPayAs("first").
		StringArgument("First").
		StringArgument("I am teh first user").
		Argument(tags).
		RunPrintEventsFull()

	g.TransactionFromFile("create_profile").
		SignProposeAndPayAs("second").
		StringArgument("Second").
		StringArgument("I am teh second user").
		Argument(tags).
		RunPrintEventsFull()

	g.TransactionFromFile("follow").
		SignProposeAndPayAs("first").
		AccountArgument("second").
		Argument(tags).
		RunPrintEventsFull()

	g.TransactionFromFile("follow").
		SignProposeAndPayAs("second").
		AccountArgument("first").
		Argument(tags).
		RunPrintEventsFull()

	g.TransactionFromFile("mint_tokens").
		SignProposeAndPayAsService().
		AccountArgument("first").
		UFix64Argument("100.0").
		Run()
	g.TransactionFromFile("transfer").
		SignProposeAndPayAs("first").
		UFix64Argument("10.0").
		AccountArgument("second").
		Run()

	g.TransactionFromFile("mint_fusd").
		SignProposeAndPayAsService().
		AccountArgument("first").
		UFix64Argument("100.0").
		Run()

	//This will fail since we do not have a FUSD wallet registered
	/*
		g.TransactionFromFile("transfer_fusd").
			SignProposeAndPayAs("first").
			UFix64Argument("10.0").
			AccountArgument("second").
			Run()
	*/

	g.ScriptFromFile("get_profile").AccountArgument("first").Run()
	g.ScriptFromFile("get_profile").AccountArgument("second").Run()

}
