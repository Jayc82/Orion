package main

import (
	"github.com/JayC82/orion/core"
	"github.com/JayC82/orion/p2p"
	"github.com/JayC82/orion/rpc"
)

func main() {
	bc := core.NewBlockchain()

	go rpc.StartRPC()

	node := p2p.Node{}
	go node.Start("6001")

	select {} // keep node running
}

