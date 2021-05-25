/*
* Inspiration: https://flow-view-source.com/testnet/account/0xba1132bc08f82fe2/contract/Ghost

Fields:

 - collection: {CollectionKey: Capability} //will this work?
 - featuresNfts: {String:NFTPointer}
 - wallet: [Wallet] //this needs to be an array since it is ordered.

Methods:
 - deposit(amount, type, message) : send flow to user, message paramter with a reason?
  - deposit to the first wallet with the given type in the wallet array.
 - depositFlow(amount)
 - verify(message) ; Emit an events that verifies that this user has signed this transaction.
 - addNFTcollection
 - addMarketplaceCollection
 - addCollection(type, name, capability)
 - addWallet(name, balancerCap, receiverCap, [type])
 - getWallets()
 - setWallets([wallet]) //so that you can reorder
 - addFeatureNFT(string, capability, id)
 - removeWallet(name)
 - removeCollection(name)
 - removeFeaturedNFT(string)
 - methods to add/remove followers/following

//Public methods
 - getNFTs()
 - getMarketplaces()
 - getProfile() //crete public profile struct
 - getName()
 - getAvatar()
 - getDescription()
 - getColor()
 - getTags()
 - find followers with some tags
 - find following with some tags
 - find all mututal followers/followings


  pub struct Wallet {
    pub let receiver: Capability<&{FungibleToken.Receiver}>
    pub let balancer: Capability<&{FungibleTOken.Balancer}>
    pub let accept: Type
    pub let tags: [String]

 
   init(
    receiver: Capability<&{FungibleToken.Receiver}>,
    balancer: Capability<&{FungibleTOken.Balancer}>,
    accept: Type,
    tags: [String]
  ) {
    self.receiver=receiver,
    self.balancer=balancer,
    self.accept=accept,
    self.tags=tags
  }
 }

NFTPointer:
 - collection: Capability<&NFT.PublicCollection>
 - type
 - index: UInt64

***
***
**/

import FungibleToken from "./standard/FungibleToken.cdc"

pub contract Profile {
  pub let publicPath: PublicPath
  pub let privatePath: StoragePath
  
  init() {
    self.publicPath = /public/User
    self.privatePath = /storage/User
  }

 pub struct Wallet {
   pub let name: String
   pub let receiver: Capability<&{FungibleToken.Receiver}>
   pub let balance: Capability<&{FungibleToken.Balance}>
   pub let accept: Type
   pub let tags: [String]

 
   init(
    name: String,
    receiver: Capability<&{FungibleToken.Receiver}>,
    balance: Capability<&{FungibleToken.Balance}>,
    accept: Type,
    tags: [String]
  ) {
    self.name=name
    self.receiver=receiver
    self.balance=balance
    self.accept=accept
    self.tags=tags
  }
 }

 pub struct ResourceCollection {
    pub let collection: Capability
    pub let tags: [String]
    pub let type: Type
    pub let name: String

    init(name: String, collection:Capability, type: Type, tags: [String]) {
      self.name=name
      self.collection=collection
      self.tags=tags
      self.type=type
    }
 }
  //should this have a owner and friend Address?
  pub struct FriendStatus {
    pub let follower: Address
    pub let following:Address
    pub let mutual: Bool
    pub let tags: [String]

    init(follower: Address, following:Address, mutual: Bool, tags: [String]) {
      self.follower=follower
      self.following=following 
      self.mutual=mutual
      self.tags= tags
    }
  }
  
 

  pub resource interface Public {
    pub fun getName(): String
    pub fun getDescription(): String
    pub fun getTags(): [String]
    pub fun getAvatar(): String
    pub fun getCollections(): [ResourceCollection] 
    pub fun follows(_ address: Address) : Bool
    pub fun getFollowers(): [FriendStatus]
    pub fun getFollowing(): [FriendStatus]
    pub fun getWallets() : [Wallet]
    pub fun deposit(from: @FungibleToken.Vault)
    
    access(contract) fun internal_addFollower(_ address: Address, status: FriendStatus)
    access(contract) fun internal_removeFollower(_ address: Address) 
  }
  
  pub resource interface Owner {
    pub fun setName(_ val: String) {
      pre {
        val.length <= 16: "Name must be 16 or less characters"
      }
    }
    pub fun setAvatar(_ val: String)
    pub fun setTags(_ val: [String])
    pub fun setDescription(_ val: String)
    pub fun follow(_ address: Address, tags:[String])
    pub fun unfollow(_ address: Address)
    pub fun removeCollection(_ val: String)
    pub fun addCollection(_ val: ResourceCollection)
    pub fun addWallet(_ val : Wallet) 
    //TODO remove wallet with Name
    //TODO set wallet
  }
  
  pub resource Base: Public, Owner, FungibleToken.Receiver {
    access(self) var name: String
    access(self) var description: String
    access(self) var avatar: String
    access(self) var tags: [String]
    access(self) var followers: {Address: FriendStatus}
    access(self) var following: {Address: FriendStatus}
    access(self) var collections: {String: ResourceCollection}
    access(self) var wallets: [Wallet]
    
    init(name:String, description: String, tags: [String]) {
      self.name = name
      self.description=description
      self.tags=tags
      self.avatar = "https://avatars.onflow.org/avatar/ghostnote"
      self.followers = {}
      self.following = {}
      self.collections={}
      self.wallets=[]
    }
    
    pub fun supportedTypes() : [Type] { 
        let types: [Type] =[]
        for w in self.wallets {
          if !types.contains(w.accept) {
            types.append(w.accept)
          }
        }
        return types
    }

    pub fun deposit(from: @FungibleToken.Vault) {
      for w in self.wallets {
        if from.isInstance(w.accept) {
          w.receiver.borrow()!.deposit(from: <- from)
          return
        }
      } 
      let identifier=from.getType().identifier
      //TODO: I need to destroy here for this to compile, but WHY?
      destroy from
      panic("could not find a supported wallet for:".concat(identifier))
    }

    pub fun getWallets() : [Wallet] { return self.wallets}
    pub fun addWallet(_ val: Wallet) { self.wallets.append(val) }

    pub fun follows(_ address: Address) : Bool {
      return self.following.containsKey(address)
    }

    pub fun getName(): String { return self.name }
    pub fun getDescription(): String{ return self.description}
    pub fun getTags(): [String] { return self.tags}
    pub fun getAvatar(): String { return self.avatar }
    pub fun getFollowers(): [FriendStatus] { return self.followers.values }
    pub fun getFollowing(): [FriendStatus] { return self.following.values }
    
    pub fun setName(_ val: String) { self.name = val }
    pub fun setAvatar(_ val: String) { self.avatar = val }
    pub fun setDescription(_ val: String) { self.description=val}
    pub fun setTags(_ val: [String]) { self.tags=val}

    pub fun removeCollection(_ val: String) { self.collections.remove(key: val)}
    pub fun addCollection(_ val: ResourceCollection) { self.collections[val.name]=val}
    pub fun getCollections(): [ResourceCollection] { return self.collections.values}

 

    pub fun follow(_ address: Address, tags:[String]) {
      let friendProfile=Profile.find(address)
      let owner=self.owner!.address
      let mutual = friendProfile.follows(owner)
      let status=FriendStatus(follower:owner, following:address, mutual:mutual, tags:tags)

      self.following[address] = status
      friendProfile.internal_addFollower(address, status: status)
    }
    
    pub fun unfollow(_ address: Address) {
      self.following.remove(key: address)
      Profile.find(address).internal_removeFollower(self.owner!.address)
    }
    
    access(contract) fun internal_addFollower(_ address: Address, status: FriendStatus) {
      self.followers[address] = status
    }
    
    access(contract) fun internal_removeFollower(_ address: Address) {
      self.followers.remove(key: address)
    }
    
  }

   pub fun find(_ address: Address) : &{Profile.Public} {
        return getAccount(address)
        .getCapability<&{Profile.Public}>(Profile.publicPath)!
        .borrow()!
    }
  
  pub fun createProfile(name: String, description:String, tags:[String]) : @Profile.Base {
    return <- create Profile.Base(name: name, description: description, tags: tags)
  }

}
