//
//  XML2SwiftFiles.swift
//  SwiftDTO
//
//  Created by Alex da Franca on 24.05.17.
//  Copyright © 2017 Farbflash. All rights reserved.
//

import Cocoa

class XML2SwiftFiles: BaseExporter, DTOFileGenerator {

    override func generateServiceCode() -> String? {
        let filename = parser.serviceName
        var classString = parser.headerStringFor(filename: filename, outputType: .swift)

        classString += "import Foundation\n"
        if !dtoModuleName.isEmpty {
            classString += "import \(dtoModuleName)\n"
        }
        classString += "\nstruct \(filename) {\n"

        let indent = "    "
        classString += "\(indent)private let connector: ServerServicesConnector\n"

        classString += "\(indent)enum DTOServiceError: Error {\n"
        classString += "\(indent)\(indent)case none, unableToCreateDTO\n\(indent)}\n"

        classString += "\n\(indent)init(connector: ServerServicesConnector) {\n"
        classString += "\(indent)    self.connector = connector\n\(indent)}\n"

        for service in parser.services {
            var repl = [[String]]()
            var hasInput = false
            classString += "\n\(indent)func \(service.name)("
            if let inputType = service.input?.type,
                !inputType.isEmpty {
                //swiftlint:disable:next force_unwrapping
                let inputTypeResolved = inputType.components(separatedBy: ":").last!.capitalizedFirst
                if let protocolInitializer = protocolInitializerLookup[inputTypeResolved]?.first {
                    classString += "input: \(protocolInitializer), "
                    repl.append([inputTypeResolved, protocolInitializer])
                } else {
                    classString += "input: \(inputTypeResolved), "
                }
                hasInput = true
            }
            if let outputType = service.output?.type,
                !outputType.isEmpty {
                //swiftlint:disable:next force_unwrapping
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
                classString += "\(indent)\(indent)// replaced protocol type: \(stringpair[0]) with concrete subclass: \(stringpair[1])\n"
            }
            if hasInput {
                classString += "\(indent)\(indent)call(\"\(service.name)\", parameters: [\"req\": input.jsobjRepresentation], completion: completion)\n\(indent)}\n"
            } else {
                classString += "\(indent)\(indent)call(\"\(service.name)\", parameters: nil, completion: completion)\n\(indent)}\n"
            }
        }

        classString += "\n\(indent)//swiftlint:disable unused_optional_binding"
        classString += "\n\(indent)private func call<T: JSOBJSerializable>(_ function: String, parameters: JSOBJ?, completion: ((T?, Error?) -> Void)?) {\n"
        classString += "\(indent)\(indent)connector.callWSDLFunction(named: function, parameters: parameters, in: \"\(parser.serviceIdentifier)\") { (rslt, error) in\n"

        classString += "\(indent)\(indent)\(indent)if let error = error {\n"
        classString += "\(indent)\(indent)\(indent)\(indent)completion?(nil, error)\n"
        classString += "\(indent)\(indent)\(indent)} else {\n"
        classString += "\(indent)\(indent)\(indent)\(indent)guard let returnValue = (rslt as? [String: Any])?[\"return\"] else {\n"
        classString += "\(indent)\(indent)\(indent)\(indent)\(indent)completion?(nil, DTOServiceError.unableToCreateDTO)\n"
        classString += "\(indent)\(indent)\(indent)\(indent)\(indent)return\n"
        classString += "\(indent)\(indent)\(indent)\(indent)}\n"
        classString += "\(indent)\(indent)\(indent)\(indent)if let obj = T(jsonData: (returnValue as? JSOBJ)) {\n"
        classString += "\(indent)\(indent)\(indent)\(indent)\(indent)completion?(obj, nil)\n"
        classString += "\(indent)\(indent)\(indent)\(indent)} else if let _ = returnValue as? NSNull,\n"
        classString += "\(indent)\(indent)\(indent)\(indent)\(indent)let obj = T(jsonData: [String: Any]()) {\n"
        classString += "\(indent)\(indent)\(indent)\(indent)\(indent)completion?(obj, nil)\n"
        classString += "\(indent)\(indent)\(indent)\(indent)} else {\n"
        classString += "\(indent)\(indent)\(indent)\(indent)\(indent)completion?(nil, DTOServiceError.unableToCreateDTO)\n"
        classString += "\(indent)\(indent)\(indent)\(indent)}\n"

        classString += "\(indent)\(indent)\(indent)}\n\(indent)\(indent)}\n\(indent)}\n"

        classString += "\n\(indent)private func call(_ function: String, parameters: JSOBJ?, completion: ((Error?) -> Void)?) {\n"
        classString += "\(indent)\(indent)connector.callWSDLFunction(named: function, parameters: parameters, in: \"\(parser.serviceIdentifier)\") { (_, error) in\n"
        classString += "\(indent)\(indent)\(indent)completion?(error)\n\(indent)\(indent)}\n\(indent)}\n"

        classString += "}"
        return classString
    }
}
