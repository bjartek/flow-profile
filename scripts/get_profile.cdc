
import Profile from 0xf8d6e0586b0a20c7
pub fun main(address: Address) : Profile.UserProfile {

    let profile=Profile.find(address)
    return profile.asProfile()
}