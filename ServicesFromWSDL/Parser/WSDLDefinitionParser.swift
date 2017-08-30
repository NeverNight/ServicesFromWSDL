//
//  WSDLDefinitionParser.swift
//  ServicesFromWSDL
//
//  Created by Alex Apprime on 28.05.17.
//  Copyright © 2017 Farbflash. All rights reserved.
//

import Foundation

struct Service {
    let name: String
    let input: Message?
    let output: Message?
}

extension Service: Comparable {}

func < (lhs: Service, rhs: Service) -> Bool {
    return lhs.name < rhs.name
}

func == (lhs: Service, rhs: Service) -> Bool {
    return lhs.name == rhs.name
}

struct Message {
    let name: String
    let type: String
}

struct WSDLDefinitionParser {
    let serviceName: String
    let serviceIdentifier: String
    let services: [Service]
    let messages: [Message]

    init?(xmlData: XMLDocument, serviceIdentifier: String?) {
        guard let children = xmlData.children,
            !children.isEmpty,
            let model = children.first(where: { $0.name == "definitions" }) as? XMLElement else {
                return nil
        }
        guard let portType = model.elements(forName: "portType").first else { return nil }

        let servName = (model.attribute(forName: "name")?.stringValue ?? "") + "Service"
        serviceName = servName
        self.serviceIdentifier = serviceIdentifier ?? servName

        var messageArray = [Message]()
        let msgs = model.elements(forName: "message")
        for thisMessage in msgs {
            guard let msgName = thisMessage.attribute(forName: "name")?.stringValue,
                let part = thisMessage.elements(forName: "part").first,
                let msgType = part.attribute(forName: "type")?.stringValue else { continue }
            messageArray.append(Message(name: msgName, type: msgType))
        }
        messages = messageArray

        var servicesArray = [Service]()
        let ports = portType.elements(forName: "operation")
        for port in ports {
            guard let srvName = port.attribute(forName: "name")?.stringValue else { continue }
            let inputMsg: Message?
            if let input = port.elements(forName: "input").first,
                let msg = input.attribute(forName: "message")?.stringValue,
                !msg.isEmpty,
                let resolvedMessageName = msg.components(separatedBy: ":").last {
                inputMsg = messages.first(where: { $0.name == resolvedMessageName })
            } else {
                inputMsg = nil
            }
            let outputMsg: Message?
            if let output = port.elements(forName: "output").first,
                let msg = output.attribute(forName: "message")?.stringValue,
                !msg.isEmpty,
                let resolvedMessageName = msg.components(separatedBy: ":").last {
                outputMsg = messages.first(where: { $0.name == resolvedMessageName })
            } else {
                outputMsg = nil
            }
            servicesArray.append(Service(name: srvName, input: inputMsg, output: outputMsg))
        }
        services = servicesArray
    }

    func headerStringFor(filename: String, outputType: OutputType = .swift) -> String {
        let fileExtension: String
        switch outputType {
        case .swift: fileExtension = "swift"
        case .java: fileExtension = "java"
        }
        return "//\n//  \(filename).\(fileExtension)\n\n"
            + "//  Automatically created by ServicesFromWSDL.\n"
            + "//  \(copyRightString)\n\n"
            + "// DO NOT EDIT THIS FILE!\n"
            + "// This file was automatically generated from a wsdl definitions wsdl file)\n"
            + "// Edit the source data and then use the ServicesFromWSDL\n"
            + "// to create the corresponding services files automatically\n\n"
    }

}
