import CryptoSwift

final class CryptoSwiftManager {
    static let shared = CryptoSwiftManager()
    private init() {}
    var key: [UInt8] {
        return Secrets.cryptoKey.bytes
    }

    var ivRandom: [UInt8] {
        return ChaCha20.randomIV(12)
    }

    func encrypt(
        _ text: String,
        key: [UInt8],
        ivValue: [UInt8]
    ) throws -> String {
        return try ChaCha20(key: key, iv: ivValue)
            .encrypt(text.bytes)
            .toHexString()
    }

    func decrypt(
        _ hexText: String,
        key: [UInt8],
        ivValue: [UInt8]
    ) throws -> String {
        let text = [UInt8](hex: hexText)
        let bytes = try ChaCha20(key: key, iv: ivValue).decrypt(text)
        return String(bytes: bytes, encoding: .utf8) ?? ""
    }
}
