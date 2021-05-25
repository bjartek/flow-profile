import Profile from 0xf8d6e0586b0a20c7

transaction(friend: Address, tags:[String]) {
  prepare(acct: AuthAccount) {
    let profile=acct.borrow<&Profile.Base>(from: Profile.privatePath)!
    profile.follow(friend, tags:tags)
    log(profile.getFollowing())
  }
}