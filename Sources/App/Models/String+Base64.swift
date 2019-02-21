//
//  String+Base64.swift
//  App
//
//  Created by Simon Mitchell on 21/02/2019.
//

import Foundation

extension String {
    
    var base64Decoded: String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    var base64Encoded: String? {
        return data(using: .utf8)?.base64EncodedString()
    }
}
