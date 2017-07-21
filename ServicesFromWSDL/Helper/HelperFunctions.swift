//
//  HelperFunctions.swift
//  SwiftDTO
//
//  Created by Alex da Franca on 24.05.17.
//  Copyright © 2017 Farbflash. All rights reserved.
//

import Foundation

func writeToStdError(_ str: String) {
    let handle = FileHandle.standardError

    if let data = str.data(using: String.Encoding.utf8) {
        handle.write(data)
    }
}

func writeToStdOut(_ str: String) {
    let handle = FileHandle.standardOutput

    if let data = "\(str)\n".data(using: String.Encoding.utf8) {
        handle.write(data)
    }
}

func createClassNameFromType(_ nsType: String?) -> String? {
    guard let nsType = nsType,
        !nsType.isEmpty else { return nil }
    guard let type = nsType.components(separatedBy: ":").last else { return nil }
    let capType = type.capitalizedFirst
    switch capType {
    case "Error": return "DTOError"
    default: return capType
    }
}

func writeContent(_ content: String, toFileAtPath fpath: String?) {
    guard let fpath = fpath else {
        writeToStdError("Error creating enum file. Path for target file is nil.")
        return
    }
    do {
        try content.write(toFile: fpath, atomically: false, encoding: String.Encoding.utf8)
        writeToStdOut("Successfully written file to: \(fpath)\n")
    } catch let error as NSError {
        writeToStdError("error: \(error.localizedDescription)")
    }

}

func pathForClassName(_ className: String, inFolder target: String?, outputType: OutputType = .swift) -> String? {
    guard let target = target else { return nil }
    let fileurl = URL(fileURLWithPath: target)
    let fileExt: String
    switch outputType {
    case .swift: fileExt = "swift"
        case .java: fileExt = "java"
    }
    let newUrl = fileurl.appendingPathComponent(className).appendingPathExtension(fileExt)
    return newUrl.path
}

func readProtocolParentLookup(targetFolder: String?) -> [String: [String]] {
    guard let targetFolder = targetFolder else { return [String: [String]]() }
    let fileurl = URL(fileURLWithPath: targetFolder)
    let newUrl = fileurl.appendingPathComponent("DTOParentInfo.json")
    guard let data = try? Data(contentsOf: newUrl),
        let json = try? JSONSerialization.jsonObject(with: data as Data, options: .allowFragments),
        let lookuplist = json as? [String: [String]] else { return [String: [String]]() }
    return lookuplist
}

func filename(for url: URL) -> String? {
    if let nameParts = url.pathComponents.last?.components(separatedBy: "."),
        !nameParts.isEmpty {
        if nameParts.count == 1 { return nameParts[0] }
        return "\((nameParts[0..<(nameParts.count - 1)].joined(separator: ".")))"
    }
    return nil
}
