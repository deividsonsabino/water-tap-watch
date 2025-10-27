import Foundation

public protocol KeyValueStoring {
    func integer(forKey defaultName: String) -> Int
    func set(_ value: Int, forKey defaultName: String)
}

// Adapta UserDefaults ao protocolo
extension UserDefaults: KeyValueStoring {}
