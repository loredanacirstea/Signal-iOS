//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

import Foundation

@objc
public extension OWSUserProfile {

    static var maxNameLengthGlyphs: Int = 26
    // The max bytes for a user's profile name, encoded in UTF8.
    // Before encrypting and submitting we NULL pad the name data to this length.
    static var maxNameLengthBytes: Int = 128

    static let kMaxBioLengthGlyphs: Int = 140
    static let kMaxBioLengthBytes: Int = 512

    static let kMaxBioEmojiLengthGlyphs: Int = 1
    static let kMaxBioEmojiLengthBytes: Int = 32

    // MARK: - Bio

    @nonobjc
    private static let bioComponentCache = LRUCache<String, String>(maxSize: 256)
    private static let unfairLock = UnfairLock()

    private static func filterBioComponentForDisplay(_ input: String?,
                                                     maxLengthGlyphs: Int,
                                                     maxLengthBytes: Int) -> String? {
        guard let input = input else {
            return nil
        }
        let cacheKey = "\(maxLengthGlyphs)-\(maxLengthBytes)-\(input)"
        return unfairLock.withLock {
            // Note: we use empty strings in the cache, but return nil for empty strings.
            if let cachedValue = bioComponentCache.get(key: cacheKey) {
                return cachedValue.nilIfEmpty
            }
            let value = input.filterStringForDisplay().trimToGlyphCount(maxLengthGlyphs).trimToUtf8ByteCount(maxLengthBytes)
            bioComponentCache.set(key: cacheKey, value: value)
            return value.nilIfEmpty
        }
    }

    // Joins the two bio components into a single string
    // ready for display. It filters and enforces length
    // limits on the components.
    static func bioForDisplay(bio: String?, bioEmoji: String?) -> String? {
        var components = [String]()
        // TODO: We could use EmojiWithSkinTones to check for availability of the emoji.
        if let emoji = filterBioComponentForDisplay(bioEmoji,
                                                    maxLengthGlyphs: kMaxBioEmojiLengthGlyphs,
                                                    maxLengthBytes: kMaxBioEmojiLengthBytes) {
            components.append(emoji)
        }
        if let bioText = filterBioComponentForDisplay(bio,
                                                      maxLengthGlyphs: kMaxBioLengthGlyphs,
                                                      maxLengthBytes: kMaxBioLengthBytes) {
            components.append(bioText)
        }
        guard !components.isEmpty else {
            return nil
        }
        return components.joined(separator: " ")
    }

    // MARK: - Encryption

    class func encrypt(profileData: Data, profileKey: OWSAES256Key) -> Data? {
        assert(profileKey.keyData.count == kAES256_KeyByteLength)
        return Cryptography.encryptAESGCMProfileData(plainTextData: profileData, key: profileKey)
    }

    class func decrypt(profileData: Data, profileKey: OWSAES256Key) -> Data? {
        assert(profileKey.keyData.count == kAES256_KeyByteLength)
        return Cryptography.decryptAESGCMProfileData(encryptedData: profileData, key: profileKey)
    }

    class func decrypt(profileNameData: Data, profileKey: OWSAES256Key, address: SignalServiceAddress) -> PersonNameComponents? {
        guard let decryptedData = decrypt(profileData: profileNameData, profileKey: profileKey) else { return nil }

        // Unpad profile name. The given and family name are stored
        // in the string like "<given name><null><family name><null padding>"
        let nameSegments: [Data] = decryptedData.split(separator: 0x00)

        // Given name is required
        guard nameSegments.count > 0,
              let givenName = String(data: nameSegments[0], encoding: .utf8), !givenName.isEmpty else {
            Logger.warn("unexpectedly missing first name for \(address), isLocal: \(address.isLocalAddress).")
            return nil
        }

        // Family name is optional
        let familyName: String?
        if nameSegments.count > 1 {
            familyName = String(data: nameSegments[1], encoding: .utf8)
        } else {
            familyName = nil
        }

        var nameComponents = PersonNameComponents()
        nameComponents.givenName = givenName
        nameComponents.familyName = familyName
        return nameComponents
    }

    class func decrypt(profileStringData: Data, profileKey: OWSAES256Key) -> String? {
        guard let decryptedData = decrypt(profileData: profileStringData, profileKey: profileKey) else {
            return nil
        }

        // Remove padding.
        let segments: [Data] = decryptedData.split(separator: 0x00)
        guard let firstSegment = segments.first else {
            return nil
        }
        guard let string = String(data: firstSegment, encoding: .utf8), !string.isEmpty else {
            return nil
        }
        return string
    }

    class func encrypt(profileNameComponents: PersonNameComponents, profileKey: OWSAES256Key) -> ProfileValue? {
        let givenName: String? = profileNameComponents.givenName?.trimToGlyphCount(maxNameLengthGlyphs)
        guard var paddedNameData = givenName?.data(using: .utf8) else { return nil }
        if let familyName = profileNameComponents.familyName?.trimToGlyphCount(maxNameLengthGlyphs) {
            // Insert a null separator
            paddedNameData.count += 1
            guard let familyNameData = familyName.data(using: .utf8) else { return nil }
            paddedNameData.append(familyNameData)
        }

        // The Base 64 lengths reflect encryption + Base 64 encoding
        // of the max-length padded value.
        //
        // Two names plus null separator.
        let totalNameMaxLength = Int(maxNameLengthBytes) * 2 + 1
        let paddedLengths: [Int]
        let validBase64Lengths: [Int]
        owsAssertDebug(totalNameMaxLength == 257)
        paddedLengths = [53, 257 ]
        validBase64Lengths = [108, 380 ]

        // All encrypted profile names should be the same length on the server,
        // so we pad out the length with null bytes to the maximum length.
        return encrypt(data: paddedNameData,
                       profileKey: profileKey,
                       paddedLengths: paddedLengths,
                       validBase64Lengths: validBase64Lengths)
    }

    class func encrypt(data unpaddedData: Data,
                       profileKey: OWSAES256Key,
                       paddedLengths: [Int],
                       validBase64Lengths: [Int]) -> ProfileValue? {

        guard paddedLengths == paddedLengths.sorted() else {
            owsFailDebug("paddedLengths have incorrect ordering.")
            return nil
        }

        guard let paddedData = ({ () -> Data? in
            guard let paddedLength = paddedLengths.first(where: { $0 >= unpaddedData.count }) else {
                owsFailDebug("Oversize value: \(unpaddedData.count) > \(paddedLengths)")
                return nil
            }

            var paddedData = unpaddedData
            let paddingByteCount = paddedLength - paddedData.count
            paddedData.count += paddingByteCount

            assert(paddedData.count == paddedLength)
            return paddedData
        }()) else {
            owsFailDebug("Could not pad value.")
            return nil
        }

        guard let encrypted = encrypt(profileData: paddedData, profileKey: profileKey) else {
            owsFailDebug("Could not encrypt.")
            return nil
        }
        let value = ProfileValue(encrypted: encrypted, validBase64Lengths: validBase64Lengths)
        guard value.hasValidBase64Length else {
            owsFailDebug("Value has invalid base64 length: \(encrypted.count) -> \(value.encryptedBase64.count) not in \(validBase64Lengths).")
            return nil
        }
        return value
    }
}

// MARK: -

@objc
public class ProfileValue: NSObject {
    public let encrypted: Data

    let validBase64Lengths: [Int]

    required init(encrypted: Data,
                  validBase64Lengths: [Int]) {
        self.encrypted = encrypted
        self.validBase64Lengths = validBase64Lengths
    }

    @objc
    var encryptedBase64: String {
        encrypted.base64EncodedString()
    }

    @objc
    var hasValidBase64Length: Bool {
        validBase64Lengths.contains(encryptedBase64.count)
    }
}
