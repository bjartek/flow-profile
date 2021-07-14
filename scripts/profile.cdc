import Profile from 0xf8d6e0586b0a20c7
pub fun main(address:Address) : &AnyResource{Profile.Public}? {
  return getAccount(address)
        .getCapability<&{Profile.Public}>(Profile.publicPath)
        .borrow()
}