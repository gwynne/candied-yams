//
//  SugarSyrup.swift
//  candied-yams
//
//  Created by Gwynne Raskind on 12/14/21.
//

import Foundation
import Yams

@objc
public enum LineBreakMode: Int {
    case cr, lf, crlf
}

@objc
public final class CandiedYams: NSObject {
    @objc
    public class var nativeLineBreak: LineBreakMode {
        #if os(Windows)
        return .crlf
        #else
        return .lf
        #endif
    }
    
    @objc
    public class func load(yaml: String, encoding: UInt = String.Encoding.utf8.rawValue) throws -> Any {
        assert(
            encoding == String.Encoding.utf8.rawValue ||
            encoding == String.Encoding.utf16.rawValue ||
            encoding == String.Encoding.utf16LittleEndian.rawValue,
            "Encoding must be valid for YAML"
        )
        
        guard let result = try Yams.Parser(
            yaml: yaml,
            encoding: encoding == String.Encoding.utf8.rawValue ? .utf8 : .utf16
        ).singleRoot()?.any else {
            throw NSError(domain: "CandiedYamsErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "No result"])
        }
        return result
    }
    
    @objc
    public class func load(data: Data, encoding: UInt = String.Encoding.utf8.rawValue) throws -> Any {
        assert(
            encoding == String.Encoding.utf8.rawValue ||
            encoding == String.Encoding.utf16.rawValue ||
            encoding == String.Encoding.utf16LittleEndian.rawValue,
            "Encoding must be valid for YAML"
        )
                
        guard let result = try Yams.Parser(
            yaml: data,
            encoding: encoding == String.Encoding.utf8.rawValue ? .utf8 : .utf16
        ).singleRoot()?.any else {
            throw NSError(domain: "CandiedYamsErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "No result"])
        }
        return result
    }
    
    @objc
    public class func dump(
        _ object: Any?,
        canonical: Bool = false,
        indent: Int = 0,
        width: Int = -1,
        allowUnicode: Bool = false,
        lineBreak: LineBreakMode = CandiedYams.nativeLineBreak,
        explicitStart: Bool = false,
        explicitEnd: Bool = false,
        majorVersion: Int = -1,
        minorVersion: Int = -1,
        sortKeys: Bool = false
    ) throws -> String {
        assert((majorVersion == -1) == (minorVersion == -1), "Major and minor version must either both be set or both be -1.")
        
        return try Yams.dump(
            object: object,
            canonical: canonical,
            indent: indent,
            width: width,
            allowUnicode: allowUnicode,
            lineBreak: lineBreak == .cr ? .cr : (lineBreak == .lf ? .ln : .crln),
            explicitStart: explicitStart,
            explicitEnd: explicitEnd,
            version: majorVersion == -1 && minorVersion == -1 ? nil : (major: majorVersion, minor: minorVersion),
            sortKeys: sortKeys
        )
    }
}

extension Foundation.NSArray: Yams.NodeRepresentable {
    public func represented() throws -> Node {
        let nodes = try map { v -> Node in
            guard let value = v as? NodeRepresentable else { throw YamlError.representer(problem: "failed to represent \(v)") }
            return try value.represented()
        }
        return Node(nodes, Tag(.seq))
    }
}

extension Foundation.NSDictionary: Yams.NodeRepresentable {
    public func represented() throws -> Node {
        let pairs = try map { k, v -> (key: Node, value: Node) in
            guard let key = k as? NodeRepresentable else { throw YamlError.representer(problem: "failed to represent \(k)") }
            guard let value = v as? NodeRepresentable else { throw YamlError.representer(problem: "failed to represent \(v)") }
            return try (key: key.represented(), value: value.represented())
        }
        return Node(pairs.sorted { $0.key < $1.key }, Tag(.map))
    }
}

extension Foundation.NSNumber: Yams.ScalarRepresentable {
    public func represented() -> Node.Scalar {
        if self === kCFBooleanTrue { return true.represented() }
        else if self === kCFBooleanFalse { return false.represented() }
        else if let intValue = self as? Int64 { return intValue.represented() }
        else if let uintValue = self as? UInt64 { return uintValue.represented() }
        else if let doubleValue = self as? Double { return doubleValue.represented() }
        else { return self.stringValue.represented() }
    }
}

extension Foundation.NSData: Yams.ScalarRepresentable {
    public func represented() -> Node.Scalar { (self as Data).represented() }
}

extension Foundation.NSDate: Yams.ScalarRepresentable {
    public func represented() -> Node.Scalar { (self as Date).represented() }
}

extension Foundation.NSString: Yams.ScalarRepresentable {
    public func represented() -> Node.Scalar { (self as String).represented() }
}

extension Foundation.NSURL: Yams.ScalarRepresentable {
    public func represented() -> Node.Scalar { (self as URL).represented() }
}

extension Foundation.NSUUID: Yams.ScalarRepresentable {
    public func represented() -> Node.Scalar { (self as UUID).represented() }
}
