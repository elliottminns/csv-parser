
//
//  BluetoothParser.swift
//  OlympusKit
//
//  Created by Elliott Minns on 09/05/2016.
//  Copyright © 2016 Smartfocus. All rights reserved.
//

import Foundation

#if !swift(>=3.0)
struct CSVParserError: ErrorType {
    let message: String
}
#else
struct CSVParserError: ErrorProtocol {
    let message: String
}
#endif

public class CSVParser<T> {
    
    public typealias Object = T
    
    public typealias ParseData = [String: String]
    
    public var allHeaders: Set<String> {
        guard let headers = headers else { return [] }
        return Set<String>(headers)
    }
    
    var headers: [String]?
    
    var data: String
    
    convenience init(fileURL: NSURL) throws {
        guard let path = fileURL.path else {
            throw CSVParserError(message: "Path does not exist")
        }
        try self.init(fileURL: path)
    }
    
    init(fileURL: String) throws {
        headers = nil
        self.data = try String(contentsOfFile: fileURL)
    }
    
    init(data: String) {
        headers = nil
        self.data = data
    }
    
    func parseHeaders() throws -> Set<String> {
        #if !swift(>=3.0)

        guard let headerLine = self.data.componentsSeparatedByString("\n").first else {
            throw CSVParserError(message: "No lines")
        }

        let headers = headerLine.componentsSeparatedByString(",")
        #else 

        guard let headerLine = self.data.components(separatedBy: "\n").first else {
            throw CSVParserError(message: "No lines")
        }

        let headers = headerLine.components(separatedBy: ",")
        #endif
        
        return Set<String>(headers)
    }
    
    public func parse(method: (data: ParseData) -> Object?) -> [Object] {
        
        var result: [Object] = []
        
        #if !swift(>=3.0)
        let lines = self.data.componentsSeparatedByString("\n")
        #else
        let lines = self.data.components(separatedBy: "\n")
        #endif
        
        for line in lines {
            
            #if !swift(>=3.0)
            let lineParts = line.componentsSeparatedByString(",")
            #else
            let lineParts = line.components(separatedBy: ",")
            #endif
            
            if let headers = headers {
                
                var data: [String: String] = [:]
                
                for i in 0 ..< lineParts.count {
                    if i < headers.count {
                        let header = headers[i]
                        let value = lineParts[i]
                        data[header] = value
                    }
                    
                }
                
                if let object = method(data: data) {
                    result.append(object)
                }
                
            } else {
                headers = lineParts
            }
        }
        
        return result
    }
    
}
