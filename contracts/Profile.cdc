/*
* Inspiration: https://flow-view-source.com/testnet/account/0xba1132bc08f82fe2/contract/Ghost
*/

import FungibleToken from "./standard/FungibleToken.cdc"

pub contract Profile {
  pub let publicPath: PublicPath
  pub let privatePath: StoragePath
  
  init() {
    self.publicPath = /public/User
    self.privatePath = /storage/User
  }

  //TODO: Add Events

  /* 
  Represents a Fungible token wallet with a name and a supported type.
   */
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

  /*
  
   Represent a collection of a Resource that you want to expose
   Since NFT standard is not so great at just add Type and you have to use instanceOf to check for now
   */
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


  pub struct CollectionProfile{
    pub let tags: [String]
    pub let type: String
    pub let name: String

    init(_ collection: ResourceCollection){
      self.name=collection.name
      self.type=collection.type.identifier
      self.tags=collection.tags
    }
  }

  /*
    A link that you could add to your profile
   */
  pub struct Link {
     pub let url: String
     pub let title: String
     pub let type: String

     init(title: String, type: String, url: String) {
       self.url=url
       self.title=title
       self.type=type
     }
  }
  /*
    Information about a connection between one profile and another.
   */
  pub struct FriendStatus {
    pub let follower: Address
    pub let following:Address
    pub let tags: [String]

    init(follower: Address, following:Address, tags: [String]) {
      self.follower=follower
      self.following=following 
      self.tags= tags
    }
  }

  pub struct WalletProfile {
    pub let name: String
    pub let balance: UFix64
    pub let accept:  String
    pub let tags: [String] 

    init(_ wallet: Wallet) {
      self.name=wallet.name
      self.balance=wallet.balance.borrow()?.balance ?? 0.0 
      self.accept=wallet.accept.identifier
      self.tags=wallet.tags
    }
  }

  pub struct UserProfile {
    pub let address: Address
    pub let name: String
    pub let description: String
    pub let tags: [String]
    pub let avatar: String
    pub let links: [Link]
    pub let wallets: [WalletProfile]
    pub let collections: [CollectionProfile]
    pub let following: [FriendStatus]
    pub let followers: [FriendStatus]

    init(
      name: String,
      description: String, 
      tags: [String],
      avatar: String, 
      links: [Link],
      wallets: [WalletProfile],
      collections: [CollectionProfile],
      following: [FriendStatus],
      followers: [FriendStatus]) {
        self.address=Profile.account.address
        self.name=name
        self.description=description
        self.tags=tags
        self.avatar=avatar
        self.links=links
        self.collections=collections
        self.wallets=wallets
        self.following=following
        self.followers=followers
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
    pub fun getLinks() : [Link]
    pub fun deposit(from: @FungibleToken.Vault)
    pub fun supportedFungigleTokenTypes() : [Type]
    pub fun asProfile() : UserProfile
    
    access(contract) fun internal_addFollower(_ val: FriendStatus)
    access(contract) fun internal_removeFollower(_ address: Address) 
  }
  
  //TODO: Add more pre checks here
  pub resource interface Owner {
    pub fun setName(_ val: String) {
      pre {
        val.length <= 16: "Name must be 16 or less characters"
      }
    }

    pub fun setAvatar(_ val: String)
    //should pobably validate that tags cannot be above a certain length

    pub fun setTags(_ val: [String])
    
    //validate length of description to be 255 or something?
    pub fun setDescription(_ val: String)

    pub fun follow(_ address: Address, tags:[String])
    pub fun unfollow(_ address: Address)

    pub fun removeCollection(_ val: String)
    pub fun addCollection(_ val: ResourceCollection)

    pub fun addWallet(_ val : Wallet) 
    pub fun removeWallet(_ val: String)
    pub fun setWallets(_ val: [Wallet])

    pub fun addLink(_ val: Link)
    pub fun removeLink(_ val: String)
  }
  

  pub resource User: Public, Owner, FungibleToken.Receiver {
    access(self) var name: String
    access(self) var description: String
    access(self) var avatar: String
    access(self) var tags: [String]
    access(self) var followers: {Address: FriendStatus}
    access(self) var following: {Address: FriendStatus}
    access(self) var collections: {String: ResourceCollection}
    access(self) var wallets: [Wallet]
    access(self) var links: {String: Link}
    
    init(name:String, description: String, tags: [String]) {
      self.name = name
      self.description=description
      self.tags=tags
      self.avatar = "https://avatars.onflow.org/avatar/ghostnote"
      self.followers = {}
      self.following = {}
      self.collections={}
      self.wallets=[]
      self.links={}
    }

    pub fun asProfile() : UserProfile {
       let wallets: [WalletProfile]=[]
       for w in self.wallets {
        wallets.append(WalletProfile(w))
       }

       let collections:[CollectionProfile]=[]
       for c in self.getCollections() {
         collections.append(CollectionProfile(c))
       }

       return UserProfile(
         name: self.getName(),
         description: self.getDescription(),
         tags: self.getTags(),
         avatar: self.getAvatar(),
         links: self.getLinks(),
         wallets: wallets, 
         collections: collections,
         following: self.getFollowing(),
         followers: self.getFollowers()
       )
    }

    pub fun getLinks() : [Link] {
      return self.links.values
    }

    pub fun addLink(_ val: Link) {
      self.links[val.title]=val
    }

    pub fun removeLink(_ val: String) {
      self.links.remove(key: val)
    }
    
    pub fun supportedFungigleTokenTypes() : [Type] { 
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
    pub fun removeWallet(_ val: String) {
      let numWallets=self.wallets.length
      var i=0
      while(i < numWallets) {
        if self.wallets[i].name== val {
          self.wallets.remove(at: i)
          return
        }
        i=i+1
      }
    }

    pub fun setWallets(_ val: [Wallet]) { self.wallets=val }

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
      let status=FriendStatus(follower:owner, following:address, tags:tags)

      self.following[address] = status
      friendProfile.internal_addFollower(status)
    }
    
    pub fun unfollow(_ address: Address) {
      self.following.remove(key: address)
      Profile.find(address).internal_removeFollower(self.owner!.address)
    }
    
    access(contract) fun internal_addFollower(_ val: FriendStatus) {
      self.followers[val.following] = val
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
  
  pub fun createUser(name: String, description:String, tags:[String]) : @Profile.User {
    return <- create Profile.User(name: name, description: description, tags: tags)
  }

}
