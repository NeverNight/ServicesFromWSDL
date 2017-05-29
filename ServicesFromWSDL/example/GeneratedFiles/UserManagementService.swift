//
//  UserManagementService.swift

//  Automatically created by ServicesFromWSDL.
//  Copyright (c) 2016 Farbflash. All rights reserved.

// DO NOT EDIT THIS FILE!
// This file was automatically generated from a wsdl definitions wsdl file)
// Edit the source data and then use the ServicesFromWSDL
// to create the corresponding services files automatically

import Foundation
import DLRModels

struct UserManagementService {
    private let connector: ServerServicesConnector
    enum DTOServiceError: Error {
        case none, unableToCreateDTO
    }

    init(connector: ServerServicesConnector) {
        self.connector = connector
    }

    func updatePersonalData(input: UpdatePersonalDataRequest, completion: ((GetPersonsResponse?, Error?) -> Void)?) {
        // replaced protocol type: SessionResponse with concrete subclass: GetPersonsResponse
        call("updatePersonalData", parameters: ["req": input.jsobjRepresentation], completion: completion)
    }

    func getPersons(input: GetPersonsRequest, completion: ((GetPersonsResponse?, Error?) -> Void)?) {
        call("getPersons", parameters: ["req": input.jsobjRepresentation], completion: completion)
    }

    func addPoi(input: AddPoiRequest, completion: ((GetPoisResponse?, Error?) -> Void)?) {
        call("addPoi", parameters: ["req": input.jsobjRepresentation], completion: completion)
    }

    func updatePoi(input: UpdatePoiRequest, completion: ((GetPoisResponse?, Error?) -> Void)?) {
        call("updatePoi", parameters: ["req": input.jsobjRepresentation], completion: completion)
    }

    func deletePoi(input: DeletePoiRequest, completion: ((GetPoisResponse?, Error?) -> Void)?) {
        call("deletePoi", parameters: ["req": input.jsobjRepresentation], completion: completion)
    }

    func updatePassword(input: UpdatePasswordRequest, completion: ((GetPersonsResponse?, Error?) -> Void)?) {
        // replaced protocol type: SessionResponse with concrete subclass: GetPersonsResponse
        call("updatePassword", parameters: ["req": input.jsobjRepresentation], completion: completion)
    }

    func resetPassword(input: ResetPasswordRequest, completion: ((GetStatisticResponse?, Error?) -> Void)?) {
        // replaced protocol type: DefaultResponse with concrete subclass: GetStatisticResponse
        call("resetPassword", parameters: ["req": input.jsobjRepresentation], completion: completion)
    }

    func sendRegistrationKeys(input: RegistrationKeyDispatchRequest, completion: ((GetPersonsResponse?, Error?) -> Void)?) {
        // replaced protocol type: SessionResponse with concrete subclass: GetPersonsResponse
        call("sendRegistrationKeys", parameters: ["req": input.jsobjRepresentation], completion: completion)
    }

    func getPersonalData(input: DeletePoiRequest, completion: ((GetPersonalDataResponse?, Error?) -> Void)?) {
        // replaced protocol type: SessionRequest with concrete subclass: DeletePoiRequest
        call("getPersonalData", parameters: ["req": input.jsobjRepresentation], completion: completion)
    }

    func verifyCompany(input: CompanyVerificationRequest, completion: ((CompanyVerificationResponse?, Error?) -> Void)?) {
        call("verifyCompany", parameters: ["req": input.jsobjRepresentation], completion: completion)
    }

    func login(input: LoginRequest, completion: ((LoginResponse?, Error?) -> Void)?) {
        call("login", parameters: ["req": input.jsobjRepresentation], completion: completion)
    }

    func logout(input: DeletePoiRequest, completion: ((Error?) -> Void)?) {
        // replaced protocol type: SessionRequest with concrete subclass: DeletePoiRequest
        call("logout", parameters: ["req": input.jsobjRepresentation], completion: completion)
    }

    func register(input: RegistrationRequest, completion: ((LoginResponse?, Error?) -> Void)?) {
        call("register", parameters: ["req": input.jsobjRepresentation], completion: completion)
    }

    private func call<T: JSOBJSerializable>(_ function: String, parameters: JSOBJ?, completion: ((T?, Error?) -> Void)?) {
        connector.callWSDLFunction(named: function, parameters: parameters, in: "user") { (rslt, error) in
            if let error = error { completion?(nil, error) }
            else {
                if let obj = T(jsonData: (rslt as? [String: Any])?["return"] as? JSOBJ) { completion?(obj, nil) }                else { completion?(nil, DTOServiceError.unableToCreateDTO) }
            }
        }
    }

    private func call(_ function: String, parameters: JSOBJ?, completion: ((Error?) -> Void)?) {
        connector.callWSDLFunction(named: function, parameters: parameters, in: "user") { (rslt, error) in
            completion?(error)
        }
    }
}
