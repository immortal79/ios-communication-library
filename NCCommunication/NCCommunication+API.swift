//
//  NCCommunication+API.swift
//  NCCommunication
//
//  Created by Marino Faggiana on 07/05/2020.
//  Copyright © 2020 Marino Faggiana. All rights reserved.
//
//  Author Marino Faggiana <marino.faggiana@nextcloud.com>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import Alamofire
import SwiftyJSON

extension NCCommunication {
    
    //MARK: -
    
    @objc public func checkServer(serverUrl: String, completionHandler: @escaping (_ errorCode: Int, _ errorDescription: String?) -> Void) {
        
        guard let url = NCCommunicationCommon.shared.StringToUrl(serverUrl) else {
            completionHandler(NSURLErrorUnsupportedURL, "Invalid server url")
            return
        }
        
        let method = HTTPMethod(rawValue: "HEAD")
                
        sessionManager.request(url, method: method, parameters:nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).response { (response) in
            switch response.result {
            case .failure(let error):
                let error = NCCommunicationError().getError(error: error, httResponse: response.response)
                completionHandler(error.errorCode, error.description)
            case .success( _):
                completionHandler(0, nil)
            }
        }
    }
    
    //MARK: -
    
    @objc public func downloadPreview(serverUrlPath: String, fileNameLocalPath: String, customUserAgent: String?, addCustomHeaders: [String:String]?, account: String, completionHandler: @escaping (_ account: String, _ data: Data?, _ errorCode: Int, _ errorDescription: String?) -> Void) {
        
        guard let url = NCCommunicationCommon.shared.StringToUrl(serverUrlPath) else {
            completionHandler(account, nil, NSURLErrorUnsupportedURL, "Invalid server url")
            return
        }
        
        let method = HTTPMethod(rawValue: "GET")
        let headers = NCCommunicationCommon.shared.getStandardHeaders(addCustomHeaders, customUserAgent: customUserAgent)
                
        sessionManager.request(url, method: method, parameters:nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).validate(statusCode: 200..<300).response { (response) in
            switch response.result {
            case .failure(let error):
                let error = NCCommunicationError().getError(error: error, httResponse: response.response)
                completionHandler(account, nil, error.errorCode, error.description)
            case .success( _):
                if let data = response.data {
                    do {
                        let url = URL.init(fileURLWithPath: fileNameLocalPath)
                        try data.write(to: url, options: .atomic)
                        completionHandler(account, data, 0, nil)
                    } catch {
                        completionHandler(account, nil, error._code, error.localizedDescription)
                    }
                } else {
                    completionHandler(account, nil, NSURLErrorCannotDecodeContentData, "Response error data null")
                }
            }
        }
    }
    
    @objc public func downloadPreview(serverUrl: String, fileNamePath: String, fileNameLocalPath: String, width: Int, height: Int, customUserAgent: String?, addCustomHeaders: [String:String]?, account: String, completionHandler: @escaping (_ account: String, _ data: Data?, _ errorCode: Int, _ errorDescription: String?) -> Void) {
        
        guard let fileNamePath = NCCommunicationCommon.shared.encodeString(fileNamePath) else {
            completionHandler(account, nil, NSURLErrorUnsupportedURL, "Invalid server url")
            return
        }
        let endpoint = "index.php/core/preview.png?file=" + fileNamePath + "&x=\(width)&y=\(height)&a=1&mode=cover"
            
        guard let url = NCCommunicationCommon.shared.createStandardUrl(serverUrl: serverUrl, endpoint: endpoint) else {
            completionHandler(account, nil, NSURLErrorUnsupportedURL, "Invalid server url")
            return
        }
        
        let method = HTTPMethod(rawValue: "GET")
        let headers = NCCommunicationCommon.shared.getStandardHeaders(addCustomHeaders, customUserAgent: customUserAgent)
                
        sessionManager.request(url, method: method, parameters:nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).validate(statusCode: 200..<300).response { (response) in
            switch response.result {
            case .failure(let error):
                let error = NCCommunicationError().getError(error: error, httResponse: response.response)
                completionHandler(account, nil, error.errorCode, error.description)
            case .success( _):
                if let data = response.data {
                    do {
                        let url = URL.init(fileURLWithPath: fileNameLocalPath)
                        try data.write(to: url, options: .atomic)
                        completionHandler(account, data, 0, nil)
                    } catch {
                        completionHandler(account, nil, error._code, error.localizedDescription)
                    }
                } else {
                    completionHandler(account, nil, NSURLErrorCannotDecodeContentData, "Response error data null")
                }
            }
        }
    }
    
    @objc public func downloadPreviewTrash(serverUrl: String, fileId: String, fileNameLocalPath: String, width: Int, height: Int, customUserAgent: String?, addCustomHeaders: [String:String]?, account: String, completionHandler: @escaping (_ account: String, _ data: Data?, _ errorCode: Int, _ errorDescription: String?) -> Void) {
        
        let endpoint = "index.php/apps/files_trashbin/preview?fileId=" + fileId + "&x=\(width)&y=\(height)"
        
        guard let url = NCCommunicationCommon.shared.createStandardUrl(serverUrl: serverUrl, endpoint: endpoint) else {
            completionHandler(account, nil, NSURLErrorUnsupportedURL, "Invalid server url")
            return
        }
        
        let method = HTTPMethod(rawValue: "GET")
        let headers = NCCommunicationCommon.shared.getStandardHeaders(addCustomHeaders, customUserAgent: customUserAgent)
                
        sessionManager.request(url, method: method, parameters:nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).validate(statusCode: 200..<300).response { (response) in
            switch response.result {
            case .failure(let error):
                let error = NCCommunicationError().getError(error: error, httResponse: response.response)
                completionHandler(account, nil, error.errorCode, error.description)
            case .success( _):
                if let data = response.data {
                    do {
                        let url = URL.init(fileURLWithPath: fileNameLocalPath)
                        try  data.write(to: url, options: .atomic)
                        completionHandler(account, data, 0, nil)
                    } catch {
                        completionHandler(account, nil, error._code, error.localizedDescription)
                    }
                } else {
                    completionHandler(account, nil, NSURLErrorCannotDecodeContentData, "Response error data null")
                }
            }
        }
    }
    
    //MARK: -
    
    @objc public func getActivity(serverUrl: String, since: Int, limit: Int, objectId: String?, objectType: String?, previews: Bool, customUserAgent: String?, addCustomHeaders: [String:String]?, account: String, completionHandler: @escaping (_ account: String, _ activities: [NCCommunicationActivity], _ errorCode: Int, _ errorDescription: String?) -> Void) {
        
        var activities = [NCCommunicationActivity]()
        var endpoint = "ocs/v2.php/apps/activity/api/v2/activity"
        
        if objectId == nil {
            endpoint = endpoint + "/all?format=json&since=" + String(since) + "&limit=" + String(limit)
        } else if objectId != nil && objectType != nil {
            endpoint = endpoint + "/filter?format=json&since=" + String(since) + "&limit=" + String(limit) + "&object_id=" + objectId! + "&object_type=" + objectType!
        }
         
        if previews {
            endpoint = endpoint + "&previews=true"
        }
        
        guard let url = NCCommunicationCommon.shared.createStandardUrl(serverUrl: serverUrl, endpoint: endpoint) else {
            completionHandler(account, activities, NSURLErrorUnsupportedURL, "Invalid server url")
            return
        }
        
        let method = HTTPMethod(rawValue: "GET")
        let headers = NCCommunicationCommon.shared.getStandardHeaders(addCustomHeaders, customUserAgent: customUserAgent)
        
        sessionManager.request(url, method: method, parameters:nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).validate(statusCode: 200..<300).responseJSON { (response) in
            debugPrint(response)
            switch response.result {
            case .failure(let error):
                let error = NCCommunicationError().getError(error: error, httResponse: response.response)
                completionHandler(account, activities, error.errorCode, error.description)
            case .success(let json):
                let json = JSON(json)
                let ocsdata = json["ocs"]["data"]
                for (_, subJson):(String, JSON) in ocsdata {
                    let activity = NCCommunicationActivity()
                    
                    activity.app = subJson["app"].stringValue
                    activity.idActivity = subJson["activity_id"].intValue
                    if let datetime = subJson["datetime"].string {
                        if let date = NCCommunicationCommon.shared.convertDate(datetime, format: "yyyy-MM-dd'T'HH:mm:ssZZZZZ") {
                            activity.date = date
                        }
                    }
                    activity.icon = subJson["icon"].stringValue
                    activity.link = subJson["link"].stringValue
                    activity.message = subJson["message"].stringValue
                    if subJson["message_rich"].exists() {
                        do {
                            activity.message_rich = try subJson["message_rich"].rawData()
                        } catch {}
                    }
                    activity.object_id = subJson["object_id"].intValue
                    activity.object_name = subJson["object_name"].stringValue
                    activity.object_type = subJson["object_type"].stringValue
                    if subJson["previews"].exists() {
                        do {
                            activity.previews = try subJson["previews"].rawData()
                        } catch {}
                    }
                    activity.subject = subJson["subject"].stringValue
                    if subJson["subject_rich"].exists() {
                        do {
                            activity.subject_rich = try subJson["subject_rich"].rawData()
                        } catch {}
                    }
                    activity.type = subJson["type"].stringValue
                    activity.user = subJson["user"].stringValue
                    
                    activities.append(activity)
                }
                completionHandler(account, activities, 0, nil)
            }
        }
    }
    
    //MARK: -
    
    @objc public func getExternalSite(serverUrl: String, customUserAgent: String?, addCustomHeaders: [String:String]?, account: String, completionHandler: @escaping (_ account: String, _ externalFiles: [NCCommunicationExternalSite], _ errorCode: Int, _ errorDescription: String?) -> Void) {
        
        var externalSites = [NCCommunicationExternalSite]()

        let endpoint = "ocs/v2.php/apps/external/api/v1?format=json"
        
        guard let url = NCCommunicationCommon.shared.createStandardUrl(serverUrl: serverUrl, endpoint: endpoint) else {
            completionHandler(account, externalSites, NSURLErrorUnsupportedURL, "Invalid server url")
            return
        }
        
        let method = HTTPMethod(rawValue: "GET")
        let headers = NCCommunicationCommon.shared.getStandardHeaders(addCustomHeaders, customUserAgent: customUserAgent)
        
        sessionManager.request(url, method: method, parameters:nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).validate(statusCode: 200..<300).responseJSON { (response) in
            debugPrint(response)
            switch response.result {
            case .failure(let error):
                let error = NCCommunicationError().getError(error: error, httResponse: response.response)
                completionHandler(account, externalSites, error.errorCode, error.description)
            case .success(let json):
                let json = JSON(json)
                let ocsdata = json["ocs"]["data"]
                for (_, subJson):(String, JSON) in ocsdata {
                    let extrernalSite = NCCommunicationExternalSite()
                    
                    extrernalSite.icon = subJson["icon"].stringValue
                    extrernalSite.idExternalSite = subJson["id"].intValue
                    extrernalSite.lang = subJson["lang"].stringValue
                    extrernalSite.name = subJson["name"].stringValue
                    extrernalSite.type = subJson["type"].stringValue
                    extrernalSite.url = subJson["url"].stringValue
                    
                    externalSites.append(extrernalSite)
                }
                completionHandler(account, externalSites, 0, nil)
            }
        }
    }
    
    @objc public func getServerStatus(serverUrl: String, customUserAgent: String?, addCustomHeaders: [String:String]?, completionHandler: @escaping (_ serverProductName: String?, _ serverVersion: String? , _ versionMajor: Int, _ versionMinor: Int, _ versionMicro: Int, _ extendedSupport: Bool, _ errorCode: Int, _ errorDescription: String?) -> Void) {
                
        let endpoint = "status.php"
        
        guard let url = NCCommunicationCommon.shared.createStandardUrl(serverUrl: serverUrl, endpoint: endpoint) else {
            completionHandler(nil, nil, 0, 0, 0, false, NSURLErrorUnsupportedURL, "Invalid server url")
            return
        }
        
        let method = HTTPMethod(rawValue: "GET")
        let headers = NCCommunicationCommon.shared.getStandardHeaders(addCustomHeaders, customUserAgent: customUserAgent)
        
        sessionManager.request(url, method: method, parameters:nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).validate(statusCode: 200..<300).responseJSON { (response) in
            switch response.result {
            case .failure(let error):
                let error = NCCommunicationError().getError(error: error, httResponse: response.response)
                completionHandler(nil, nil, 0, 0, 0, false, error.errorCode, error.description)
            case .success(let json):
                let json = JSON(json)
                var versionMajor = 0, versionMinor = 0, versionMicro = 0
                
                let serverProductName = json["productname"].stringValue.lowercased()
                let serverVersion = json["version"].stringValue
                let serverVersionString = json["versionstring"].stringValue
                let extendedSupport = json["extendedSupport"].boolValue
                    
                let arrayVersion = serverVersion.components(separatedBy: ".")
                if arrayVersion.count == 1 {
                    versionMajor = Int(arrayVersion[0]) ?? 0
                } else if arrayVersion.count == 2 {
                    versionMajor = Int(arrayVersion[0]) ?? 0
                    versionMinor = Int(arrayVersion[1]) ?? 0
                } else if arrayVersion.count >= 3 {
                    versionMajor = Int(arrayVersion[0]) ?? 0
                    versionMinor = Int(arrayVersion[1]) ?? 0
                    versionMicro = Int(arrayVersion[2]) ?? 0
                }
                
                completionHandler(serverProductName, serverVersionString, versionMajor, versionMinor, versionMicro, extendedSupport, 0, "")
            }
        }
    }
    
    @objc public func downloadAvatar(serverUrl: String, userID: String, fileNameLocalPath: String, size: Int, customUserAgent: String?, addCustomHeaders: [String:String]?, account: String, completionHandler: @escaping (_ account: String, _ data: Data?, _ errorCode: Int, _ errorDescription: String?) -> Void) {
        
        let endpoint = "index.php/avatar/" + userID + "/\(size)"
        
        guard let url = NCCommunicationCommon.shared.createStandardUrl(serverUrl: serverUrl, endpoint: endpoint) else {
            completionHandler(account, nil, NSURLErrorUnsupportedURL, "Invalid server url")
            return
        }
        
        let method = HTTPMethod(rawValue: "GET")
        let headers = NCCommunicationCommon.shared.getStandardHeaders(addCustomHeaders, customUserAgent: customUserAgent)
                
        sessionManager.request(url, method: method, parameters:nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).validate(statusCode: 200..<300).response { (response) in
            switch response.result {
            case .failure(let error):
                let error = NCCommunicationError().getError(error: error, httResponse: response.response)
                completionHandler(account, nil, error.errorCode, error.description)
            case .success( _):
                if let data = response.data {
                    do {
                        let url = URL.init(fileURLWithPath: fileNameLocalPath)
                        try  data.write(to: url, options: .atomic)
                        completionHandler(account, data, 0, nil)
                    } catch {
                        completionHandler(account, nil, error._code, error.localizedDescription)
                    }
                } else {
                    completionHandler(account, nil, NSURLErrorCannotDecodeContentData, "Response error data null")
                }
            }
        }
    }
    
    @objc public func downloadContent(serverUrl: String, customUserAgent: String?, addCustomHeaders: [String:String]?, account: String, completionHandler: @escaping (_ account: String, _ data: Data?, _ errorCode: Int, _ errorDescription: String?) -> Void) {
        
        guard let url = NCCommunicationCommon.shared.encodeStringToUrl(serverUrl) else {
            completionHandler(account, nil, NSURLErrorUnsupportedURL, "Invalid server url")
            return
        }
        
        let method = HTTPMethod(rawValue: "GET")
        let headers = NCCommunicationCommon.shared.getStandardHeaders(addCustomHeaders, customUserAgent: customUserAgent)
                
        sessionManager.request(url, method: method, parameters:nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).validate(statusCode: 200..<300).response { (response) in
            switch response.result {
            case .failure(let error):
                let error = NCCommunicationError().getError(error: error, httResponse: response.response)
                completionHandler(account, nil, error.errorCode, error.description)
            case .success( _):
                if let data = response.data {
                    completionHandler(account, data, 0, nil)
                } else {
                    completionHandler(account, nil, NSURLErrorCannotDecodeContentData, "Response error data null")
                }
            }
        }
    }
    
    //MARK: -
    
    @objc public func getUserProfile(serverUrl: String, customUserAgent: String?, addCustomHeaders: [String:String]?, account: String, completionHandler: @escaping (_ account: String, _ userProfile: NCCommunicationUserProfile?, _ errorCode: Int, _ errorDescription: String?) -> Void) {
    
        let endpoint = "ocs/v2.php/cloud/user?format=json"
        
        guard let url = NCCommunicationCommon.shared.createStandardUrl(serverUrl: serverUrl, endpoint: endpoint) else {
            completionHandler(account, nil, NSURLErrorUnsupportedURL, "Invalid server url")
            return
        }
        
        let method = HTTPMethod(rawValue: "GET")
        let headers = NCCommunicationCommon.shared.getStandardHeaders(addCustomHeaders, customUserAgent: customUserAgent)
        
        sessionManager.request(url, method: method, parameters:nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).validate(statusCode: 200..<300).responseJSON { (response) in
            debugPrint(response)
            switch response.result {
            case .failure(let error):
                let error = NCCommunicationError().getError(error: error, httResponse: response.response)
                completionHandler(account, nil, error.errorCode, error.description)
            case .success(let json):
                let json = JSON(json)
                let ocs = json["ocs"]
                let data = ocs["data"]
                
                let statusCode = json["ocs"]["meta"]["statuscode"].int ?? -999
                
                if statusCode == 200 {
                    
                    let userProfile = NCCommunicationUserProfile()
                    
                    userProfile.address = data["address"].stringValue
                    userProfile.backend = data["backend"].stringValue
                    userProfile.backendCapabilitiesSetDisplayName = data["backendCapabilities"]["setDisplayName"].boolValue
                    userProfile.backendCapabilitiesSetPassword = data["backendCapabilities"]["setPassword"].boolValue
                    userProfile.displayName = data["display-name"].stringValue
                    userProfile.email = data["email"].stringValue
                    userProfile.enabled = data["enabled"].boolValue
                    if let groups = data["groups"].array {
                        for group in groups {
                            userProfile.groups.append(group.stringValue)
                        }
                    }
                    userProfile.userID = data["id"].stringValue
                    userProfile.language = data["language"].stringValue
                    userProfile.lastLogin = data["lastLogin"].doubleValue
                    userProfile.locale = data["locale"].stringValue
                    userProfile.phone = data["phone"].stringValue
                    userProfile.quotaFree = data["quota"]["free"].doubleValue
                    userProfile.quota = data["quota"]["quota"].doubleValue
                    userProfile.quotaRelative = data["quota"]["relative"].doubleValue
                    userProfile.quotaTotal = data["quota"]["total"].doubleValue
                    userProfile.quotaUsed = data["quota"]["used"].doubleValue
                    userProfile.storageLocation = data["storageLocation"].stringValue
                    if let subadmins = data["subadmin"].array {
                        for subadmin in subadmins {
                            userProfile.subadmin.append(subadmin.stringValue)
                        }
                    }
                    userProfile.twitter = data["twitter"].stringValue
                    userProfile.webpage = data["webpage"].stringValue
                    
                    completionHandler(account, userProfile, 0, nil)
                    
                } else {
                    
                    let errorDescription = json["ocs"]["meta"]["errorDescription"].string ?? "Internal error"
                    
                    completionHandler(account, nil, statusCode, errorDescription)
                }
            }
        }
    }

    @objc public func getCapabilities(serverUrl: String, customUserAgent: String?, addCustomHeaders: [String:String]?, account: String, completionHandler: @escaping (_ account: String, _ data: Data?, _ errorCode: Int, _ errorDescription: String?) -> Void) {
    
        let endpoint = "ocs/v1.php/cloud/capabilities?format=json"
        
        guard let url = NCCommunicationCommon.shared.createStandardUrl(serverUrl: serverUrl, endpoint: endpoint) else {
            completionHandler(account, nil, NSURLErrorUnsupportedURL, "Invalid server url")
            return
        }
        
        let method = HTTPMethod(rawValue: "GET")
        let headers = NCCommunicationCommon.shared.getStandardHeaders(addCustomHeaders, customUserAgent: customUserAgent)
        
        sessionManager.request(url, method: method, parameters:nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).validate(statusCode: 200..<300).response { (response) in
            debugPrint(response)
            switch response.result {
            case .failure(let error):
                let error = NCCommunicationError().getError(error: error, httResponse: response.response)
                completionHandler(account, nil, error.errorCode, error.description)
            case .success( _):
                if let data = response.data {
                    completionHandler(account, data, 0, nil)
                } else {
                    completionHandler(account, nil, NSURLErrorCannotDecodeContentData, "Response error data null")
                }
            }
        }
    }
    
    //MARK: -
    
    @objc public func getRemoteWipeStatus(serverUrl: String, token: String, customUserAgent: String?, addCustomHeaders: [String:String]?, account: String, completionHandler: @escaping (_ account: String, _ wipe: Bool, _ errorCode: Int, _ errorDescription: String?) -> Void) {
        
        let endpoint = "index.php/core/wipe/check"
        
        guard let url = NCCommunicationCommon.shared.createStandardUrl(serverUrl: serverUrl, endpoint: endpoint) else {
            completionHandler(account, false, NSURLErrorUnsupportedURL, "Invalid server url")
            return
        }
        
        let method = HTTPMethod(rawValue: "POST")
        let headers = NCCommunicationCommon.shared.getStandardHeaders(addCustomHeaders, customUserAgent: customUserAgent)
        
        // request
        var urlRequest: URLRequest
        do {
            try urlRequest = URLRequest(url: url, method: method, headers: headers)
            urlRequest.httpBody = ("token=" + token).data(using: .utf8)
        } catch {
            completionHandler(account, false, error._code, error.localizedDescription)
            return
        }
        
        sessionManager.request(urlRequest).validate(statusCode: 200..<300).responseJSON { (response) in
            switch response.result {
            case .failure(let error):
                let error = NCCommunicationError().getError(error: error, httResponse: response.response)
                completionHandler(account, false, error.errorCode, error.description)
            case .success(let json):
                let json = JSON(json)
                let wipe = json["wipe"].boolValue
                completionHandler(account, wipe, 0, "")
            }
        }
    }
    
    @objc public func setRemoteWipeCompletition(serverUrl: String, token: String, customUserAgent: String?, addCustomHeaders: [String:String]?, account: String, completionHandler: @escaping (_ account: String, _ errorCode: Int, _ errorDescription: String?) -> Void) {
        
        let endpoint = "index.php/core/wipe/success"
        
        guard let url = NCCommunicationCommon.shared.createStandardUrl(serverUrl: serverUrl, endpoint: endpoint) else {
            completionHandler(account , NSURLErrorUnsupportedURL, "Invalid server url")
            return
        }
        
        let method = HTTPMethod(rawValue: "POST")
        let headers = NCCommunicationCommon.shared.getStandardHeaders(addCustomHeaders, customUserAgent: customUserAgent)
        
        // request
        var urlRequest: URLRequest
        do {
            try urlRequest = URLRequest(url: url, method: method, headers: headers)
            urlRequest.httpBody = ("token=" + token).data(using: .utf8)
        } catch {
            completionHandler(account, error._code, error.localizedDescription)
            return
        }
        
        sessionManager.request(urlRequest).validate(statusCode: 200..<300).response { (response) in
            switch response.result {
            case .failure(let error):
                let error = NCCommunicationError().getError(error: error, httResponse: response.response)
                completionHandler(account, error.errorCode, error.description)
            case .success( _):
                completionHandler(account, 0, "")
            }
        }
    }
    
    //MARK: -
    
    @objc public func iosHelper(serverUrl: String, fileNamePath: String, offset: Int, limit: Int, customUserAgent: String?, addCustomHeaders: [String:String]?, account: String, completionHandler: @escaping (_ account: String, _ files: [NCCommunicationFile]?, _ errorCode: Int, _ errorDescription: String?) -> Void) {
        
        guard let fileNamePath = NCCommunicationCommon.shared.encodeString(fileNamePath) else {
            completionHandler(account, nil, NSURLErrorUnsupportedURL, "Invalid server url")
            return
        }
        
        let endpoint = "index.php/apps/ioshelper/api/v1/list?dir=" + fileNamePath + "&offset=\(offset)&limit=\(limit)"
        
        guard let url = NCCommunicationCommon.shared.createStandardUrl(serverUrl: serverUrl, endpoint: endpoint) else {
            completionHandler(account, nil, NSURLErrorUnsupportedURL, "Invalid server url")
            return
        }
               
        let method = HTTPMethod(rawValue: "GET")
        let headers = NCCommunicationCommon.shared.getStandardHeaders(addCustomHeaders, customUserAgent: customUserAgent)
        
        sessionManager.request(url, method: method, parameters:nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).validate(statusCode: 200..<300).responseJSON { (response) in
            switch response.result {
            case .failure(let error):
                let error = NCCommunicationError().getError(error: error, httResponse: response.response)
                completionHandler(account, nil, error.errorCode, error.description)
            case .success(let json):
                var files = [NCCommunicationFile]()
                let json = JSON(json)
                for (_, subJson):(String, JSON) in json {
                    let file = NCCommunicationFile()
                    
                    file.contentType = subJson["mimetype"].stringValue
                    file.directory = subJson["directory"].boolValue
                    file.etag = subJson["etag"].stringValue
                    file.favorite = subJson["favorite"].boolValue
                    file.fileId = String(subJson["fileId"].intValue)
                    file.fileName = subJson["name"].stringValue
                    file.hasPreview = subJson["hasPreview"].boolValue
                    if let modificationDate = subJson["modificationDate"].double {
                        let date = Date(timeIntervalSince1970: modificationDate) as NSDate
                        file.date = date
                    }
                    file.ocId = subJson["ocId"].stringValue
                    file.permissions = subJson["permissions"].stringValue
                    file.size = subJson["size"].doubleValue
                    
                    files.append(file)
                }
                completionHandler(account, files, 0, nil)
            }
        }
    }
}