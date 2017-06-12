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

        classString += "include Some.Java.class\n"
        if !dtoModuleName.isEmpty {
            classString += "include \(dtoModuleName)\n"
        }
        classString += "\nclass \(filename) {\n"

        let indent = "    "

        classString += "}"
        return classString
    }

    override func fileTypeExtension() -> OutputType {
        // Override 'fileTypeExtension()' in your concrete subclass of BaseExporter!
        // default type is swift
        return .java
    }
}
