import CryptoSwift

final class CryptoSwiftManager {
    private static let logger = Logger(logLevel: .error)
    private init() {}
    static var key: [UInt8] {
        return Secrets.cryptoKey.bytes
    }

    static var ivRandom: [UInt8] {
        return ChaCha20.randomIV(12)
    }

    static func getIVFromHexString(_ hexString: String) -> [UInt8] {
        Self.hexToBytes(hexString: hexString)
    }

    static func encrypt(
        _ text: [UInt8],
        key: [UInt8],
        ivValue: [UInt8]
    ) throws -> [UInt8] {
        return try ChaCha20(key: key, iv: ivValue).encrypt(text)
    }

    static func decrypt(
        _ text: [UInt8],
        key: [UInt8],
        ivValue: [UInt8]
    ) throws -> [UInt8] {
        return try ChaCha20(key: key, iv: ivValue).decrypt(text)
    }

    static func toString(decrypted: [UInt8]) -> String? {
        return String(bytes: decrypted, encoding: .utf8)
    }

    static func hexToBytes(hexString: String) -> [UInt8] {
        return [UInt8](hex: hexString)
    }
}
