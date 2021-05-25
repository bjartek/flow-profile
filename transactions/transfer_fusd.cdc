import FungibleToken from 0xee82856bf20e2aa6
import FUSD, Profile from 0xf8d6e0586b0a20c7

//This transactions transfers flow on testnet from one account to another
transaction(amount: UFix64, to: Address) {
  let sentVault: @FungibleToken.Vault

  prepare(signer: AuthAccount) {

    let vaultRef = signer.borrow<&FUSD.Vault>(from: /storage/fusdVault)
      ?? panic("Could not borrow reference to the owner's Vault!")

    self.sentVault <- vaultRef.withdraw(amount: amount)
  }

  execute {
    Profile.find(to).deposit(from: <- self.sentVault)
  }
}