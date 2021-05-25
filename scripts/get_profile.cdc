
import Profile from 0xf8d6e0586b0a20c7
pub fun main(address: Address) {

    let profile=Profile.find(address)
    log("name=".concat(profile.getName()))
    log("avatar=".concat(profile.getAvatar()))

    for wallet in profile.getWallets() {
        log(wallet)
    }

    for collection in profile.getCollections() {
        log(collection)
    }
}