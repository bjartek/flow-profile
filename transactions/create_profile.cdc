import FungibleToken from 0xee82856bf20e2aa6
import FlowToken from 0x0ae53cb6e3f42a79
import Profile, Art, NonFungibleToken, Marketplace, FUSD from 0xf8d6e0586b0a20c7

transaction(name: String, description: String, tags:[String]) {
  prepare(acct: AuthAccount) {

    let profile <-Profile.createUser(name:name, description: description, tags:tags)

    let flowReceiver= acct.getCapability<&{FungibleToken.Receiver}>(/public/flowTokenReceiver)
    let flowBalance= acct.getCapability<&{FungibleToken.Balance}>(/public/flowTokenBalance)
    let flow=acct.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)!

    let flowWallet= Profile.Wallet(name:"Flow", receiver: flowReceiver, balance: flowBalance, accept:flow.getType(), tags: ["flow"])
    profile.addWallet(flowWallet)

    acct.save(<-FUSD.createEmptyVault(), to: /storage/fusdVault)
    acct.link<&FUSD.Vault{FungibleToken.Receiver}>( /public/fusdReceiver, target: /storage/fusdVault)
    acct.link<&FUSD.Vault{FungibleToken.Balance}>( /public/fusdBalance, target: /storage/fusdVault)

    acct.save<@NonFungibleToken.Collection>(<- Art.createEmptyCollection(), to: Art.CollectionStoragePath)
    acct.link<&{Art.CollectionPublic}>(Art.CollectionPublicPath, target: Art.CollectionStoragePath)
    let artCollectionCap=acct.getCapability<&{Art.CollectionPublic}>(Art.CollectionPublicPath)
    let artCollection=artCollectionCap.borrow()!
    artCollection.deposit(token: <- Art.createArtWithContent(name: "TestArt1", artist:"Tester", artistAddress:acct.address, description: "This is a test art", url: "Testing", type: "String", royalty:{}))
    artCollection.deposit(token: <- Art.createArtWithContent(name: "TestArt2", artist:"Tester", artistAddress:acct.address, description: "This is a test art", url: "Testing", type: "String", royalty:{}))
    profile.addCollection(Profile.ResourceCollection( 
        name: "VersusArt", 
        collection:artCollectionCap, 
        type: Type<&{Art.CollectionPublic}>(),
        tags: ["versus", "nft"]))

    let marketplaceCap = acct.getCapability<&{Marketplace.SalePublic}>(Marketplace.CollectionPublicPath)

    let sale <- Marketplace.createSaleCollection(ownerVault: flowReceiver)
    acct.save<@Marketplace.SaleCollection>(<- sale, to:Marketplace.CollectionStoragePath)
    acct.link<&{Marketplace.SalePublic}>(Marketplace.CollectionPublicPath, target: Marketplace.CollectionStoragePath)
    let marketplace=acct.borrow<&Marketplace.SaleCollection>(from: Marketplace.CollectionStoragePath)!
    let art <- Art.createArtWithContent(name: "TestArt3", artist:"Tester", artistAddress:acct.address, description: "This is a test art", url: "Testing", type: "String", royalty:{})
    marketplace.listForSale(token: <- art, price: 10.0)
    profile.addCollection(Profile.ResourceCollection(
        "VersusMarketplace", 
        marketplaceCap, 
        Type<&{Marketplace.SalePublic}>(),
        ["versus", "marketplace"]))


    profile.addLink(Profile.Link("Foo", "Image", "http://foo.bar"))
    acct.save(<-profile, to: Profile.privatePath)
    acct.link<&Profile.User{Profile.Public}>(Profile.publicPath, target: Profile.privatePath)
  }
}