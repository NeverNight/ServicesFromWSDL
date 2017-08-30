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
        classString += "\npublic struct \(filename) {\n"

        let indent = "    "
        classString += "\(indent)private let connector: ServerServicesConnector\n"

        classString += "\(indent)public enum DTOServiceError: Error {\n"
        classString += "\(indent)\(indent)case none, unableToCreateDTO\n\(indent)}\n"

        classString += "\n\(indent)public init(connector: ServerServicesConnector) {\n"
        classString += "\(indent)    self.connector = connector\n\(indent)}\n"

        // we sort the functions alphabetically
        // otherwise they come in random order and so it is difficult to track changes...
        let sortedServices = parser.services.sorted()
        for service in sortedServices {
            var repl = [[String]]()
            var hasInput = false
            classString += "\n\(indent)public func \(service.name)("
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

        if let staticFuncsPath = Bundle.main.path(forResource: "staticFunctions", ofType: "txt"),
            let staticFuncs = try? String(contentsOfFile: staticFuncsPath, encoding: .utf8) {
            classString += "\n\(indent)//MARK: - Private\n\n"
            classString += staticFuncs.replacingOccurrences(of: "%%serviceIdentifier%%", with: parser.serviceIdentifier)
        }

        classString += "}\n"
        return classString
    }
}
