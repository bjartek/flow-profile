

import FungibleToken from 0xee82856bf20e2aa6
import FUSD from 0xf8d6e0586b0a20c7

transaction(recipient: Address, amount: UFix64) {
    let tokenAdmin: &FUSD.Administrator
    let tokenReceiver: &{FungibleToken.Receiver}

    prepare(signer: AuthAccount) {

        self.tokenAdmin = signer
            .borrow<&FUSD.Administrator>(from: /storage/fusdAdmin)
            ?? panic("Signer is not the token admin")

        self.tokenReceiver = getAccount(recipient)
            .getCapability(/public/fusdReceiver)
            .borrow<&{FungibleToken.Receiver}>()
            ?? panic("Unable to borrow receiver reference")
    }

    execute {
        let minter <- self.tokenAdmin.createNewMinter()
        let mintedVault <- minter.mintTokens(amount: amount)

        self.tokenReceiver.deposit(from: <-mintedVault)

        destroy minter
    }
}