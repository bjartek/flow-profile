
import Profile from 0xf8d6e0586b0a20c7
pub fun main(address: Address) {

    let profile=Profile.find(address)
    log("name=".concat(profile.getName()))
    log("avatar=".concat(profile.getAvatar()))

    log("Wallets")
    for wallet in profile.getWallets() {
        log(wallet)
    }

    log("Collections")
    for collection in profile.getCollections() {
        log(collection)
    }

    log("Followers")
    for follower in profile.getFollowers() {
        log(follower)
    }

    log("Following")
    for following in profile.getFollowing() {
        log(following)
    }
}