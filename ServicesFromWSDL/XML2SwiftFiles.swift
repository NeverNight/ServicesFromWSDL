//
//  XML2SwiftFiles.swift
//  SwiftDTO
//
//  Created by Alex da Franca on 24.05.17.
//  Copyright © 2017 Farbflash. All rights reserved.
//

import Cocoa

class XML2SwiftFiles {
    let parser: WSDLDefinitionParser
    let protocolInitializerLookup: [String: [String]]

    init(parser: WSDLDefinitionParser, protocolInitializerLookup: [String: [String]]) {
        self.parser = parser
        self.protocolInitializerLookup = protocolInitializerLookup
    }

    let indent = "    "

    final func generateFiles(inFolder folderPath: String? = nil) {
        let info = ProcessInfo.processInfo
        let workingDirectory = info.environment["PWD"]
        let pwd = (folderPath ?? workingDirectory)!

        if let content = generateServiceCode() {
            writeContent(content, toFileAtPath: pathForClassName(parser.serviceName, inFolder: pwd))
        }
    }

    func generateServiceCode() -> String? {
        let filename = parser.serviceName
        var classString = parser.headerStringFor(filename: filename)

        classString += "import Foundation\n"
        if !dtoModuleName.isEmpty {
            classString += "import \(dtoModuleName)\n"
        }
        classString += "\npublic struct \(filename) {\n"

        let indent = "    "
        classString += "\(indent)private let connector: ServerServicesConnector\n"

        classString += "\n\(indent)public init(connector: ServerServicesConnector) {\n"
        classString += "\(indent)    self.connector = connector\n\(indent)}\n"

        for service in parser.services {
            var repl = [[String]]()
            classString += "\n\(indent)public func \(service.name)("
            if let inputType = service.input?.type,
                !inputType.isEmpty {
                let inputTypeResolved = inputType.components(separatedBy: ":").last!.capitalizedFirst
                if let protocolInitializer = protocolInitializerLookup[inputTypeResolved]?.first {
                    classString += "input: \(protocolInitializer), "
                    repl.append([inputTypeResolved, protocolInitializer])
                } else {
                    classString += "input: \(inputTypeResolved), "
                }
            }
            if let outputType = service.output?.type,
                !outputType.isEmpty {
                let outputTypeResolved = outputType.components(separatedBy: ":").last!
                    .capitalizedFirst
                if let protocolInitializer = protocolInitializerLookup[outputTypeResolved]?.first {
                    classString += "completion: ((\(protocolInitializer)?, Error?) -> Void)?) {\n"
                    repl.append([outputTypeResolved, protocolInitializer])
                } else {
                    classString += "completion: ((\(outputTypeResolved)?, Error?) -> Void)?) {\n"
                }
            } else {
                classString += "completion: ((Error?) -> Void)?) {\n"
            }
            for stringpair in repl {
                classString += "\(indent)\(indent)// replaced protocol type: \(stringpair[0]) with concrete subclass: \(stringpair[1])"
            }
            classString += "\(indent)\(indent)call(\"\(service.name)\", parameters: [\"req\": input.jsobjRepresentation], completion: completion)\n\(indent)}\n"

        }

        classString += "\n\(indent)private func call<T: JSOBJSerializable>(_ function: String, parameters: JSOBJ?, completion: ((T?, Error?) -> Void)?) {\n"
        classString += "\(indent)\(indent)connector.callServerFunction(named: function, parameters: parameters) { (rslt, error) in\n"
        classString += "\(indent)\(indent)\(indent)if let error = error { completion?(nil, error) }\n"
        classString += "\(indent)\(indent)\(indent)else {\n"
        classString += "\(indent)\(indent)\(indent)\(indent)if let obj = T(jsonData: (rslt as? [String: Any])?[\"return\"] as? JSOBJ) { completion?(obj, nil) }"
        classString += "\(indent)\(indent)\(indent)\(indent)else { completion?(nil, DTOServiceError.unableToCreateDTO) }\n"
        classString += "\(indent)\(indent)\(indent)}\n\(indent)\(indent)}\n\(indent)}\n"

        classString += "\n\(indent)private func call(_ function: String, parameters: JSOBJ?, completion: ((Error?) -> Void)?) {\n"
        classString += "\(indent)\(indent)connector.callServerFunction(named: function, parameters: parameters) { (rslt, error) in\n"
        classString += "\(indent)\(indent)\(indent)completion?(error)\n\(indent)\(indent)}\n\(indent)}\n"
        
        classString += "}"
        return classString
    }
}
