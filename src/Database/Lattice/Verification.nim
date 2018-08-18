#Errors lib.
import ../../lib/Errors

#BN lib.
import ../../lib/BN

#SHA512 lib.
import ../../lib/SHA512

#Wallet libs.
import ../../Wallet/Wallet

#Import the Serialization library.
import ../../Network/Serialize

#Node object and Send lib.
import objects/NodeObj
import Send

#Send object.
import objects/VerificationObj
export VerificationObj

proc newVerification*(send: Send, nonce: BN): Verification {.raises: [ResultError, ValueError, Exception].} =
    result = newVerificationObj(
        send.getSender(),
        send.getNonce(),
        send.getHash()
    )

    #Set the descendant type.
    if not result.setDescendant(4):
        raise newException(ResultError, "Couldn't set the node's descendant type.")

    #Set the nonce.
    if not result.setNonce(nonce):
        raise newException(ResultError, "Setting the Verification nonce failed.")

    #Set the hash.
    if not result.setHash(SHA512(result.serialize())):
        raise newException(ResultError, "Couldn't set the Verification hash.")

#Sign a TX.
proc sign*(wallet: Wallet, verif: Verification): bool {.raises: [ValueError].} =
    result = true

    #Set the sender behind the node.
    if not verif.setSender(wallet.getAddress()):
        result = false
        return

    #Sign the hash of the Verification.
    if not verif.setSignature(wallet.sign(verif.getHash())):
        result = false
        return