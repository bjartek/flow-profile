import Profile from 0xf8d6e0586b0a20c7

transaction(ban: Address) {
  prepare(acct: AuthAccount) {
    let profile=acct.borrow<&Profile.User>(from: Profile.storagePath)!
    profile.addBan(ban)
  }
}