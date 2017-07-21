//
//  XML2JavaFiles.swift
//  SwiftDTO
//
//  Created by Alex da Franca on 08.06.17.
//  Copyright © 2017 Farbflash. All rights reserved.
//

import Foundation

class XML2JavaFiles: BaseExporter, DTOFileGenerator {

    override func generateServiceCode() -> String? {
        let filename = parser.serviceName
        var classString = parser.headerStringFor(filename: filename, outputType: .java)

        classString += "\npackage data.api.service.SoapServices.GeneratedFiles;"
        classString += "\n"
        classString += "\nimport component.module.JsonModule;"
        classString += "\nimport data.api.model.GeneratedFiles.*;"
        classString += "\nimport data.api.service.SoapServices.BaseSoapService;"
        classString += "\nimport rx.Observable;"
        classString += "\n"
        classString += "\npublic class \(filename) extends BaseSoapService {\n"
        classString += "\n"

        let indent = "    "

        classString += "\n\(indent)public \(filename)(JsonModule jsonModule) {"
        classString += "\n\(indent)\(indent)super(jsonModule);\n\(indent)}"

        for service in parser.services {
            var hasInput = false
            let inputTypeResolved: String
            classString += "\n\(indent)public Observable<Object> \(service.name)("
            if let inputType = service.input?.type,
                !inputType.isEmpty {
                //swiftlint:disable:next force_unwrapping
                inputTypeResolved = inputType.components(separatedBy: ":").last!.capitalizedFirst
                classString += "\(inputTypeResolved) request) {\n"
                hasInput = true
            } else {
                classString += ") {\n"
                inputTypeResolved = "null"
            }

            classString += "\(indent)\(indent)return startRequest(\"\(parser.serviceIdentifier)\", \"\(service.name)\""

            if hasInput {
                classString += ", request.asParameterMap()"
            } else {
                classString += ", null"
            }

            if let outputType = service.output?.type,
                !outputType.isEmpty {
                //swiftlint:disable:next force_unwrapping
                let outputTypeResolved = outputType.components(separatedBy: ":").last!
                    .capitalizedFirst
                classString += ", \(outputTypeResolved).class"
            } else {
                classString += ", null"
            }
            classString += ");\n"

            classString += "\(indent)}"
        }

        classString += "\n}"
        return classString
    }

    override func fileTypeExtension() -> OutputType {
        // Override 'fileTypeExtension()' in your concrete subclass of BaseExporter!
        // default type is swift
        return .java
    }
}
