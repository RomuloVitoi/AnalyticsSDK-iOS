//
//  session.swift
//  AnalyticsSDK
//
//  Created by Chris Wisecarver on 5/17/18.
//  Copyright © 2018 Parse.ly. All rights reserved.
//

import Foundation
import UIKit

class SessionManager {
    // consolidate to the version in Storage, not just here
    // use a struct, not a dictionary
    private var session: Dictionary<String, Any?> = [:]
    private let SESSION_TIMEOUT: TimeInterval = 30 * 60.0 // 30 minutes
    // should use shared Storage instance, since each one instantiates access to the user defaults
    private let storage: Storage = Storage()
    // make this longer and more random
    private let sessionKey = "_parsely_session"
    private let visitorManager = Parsely.sharedInstance.visitorManager
    // knows how to start, stop, store, and restore a session
    // struct should represent datatype
    // - sid — session ID == session_count
    // - surl  — initial URL (postID?) of the session
    // - sref — initial referrer of the session
    // - sts — Unix timestamp (milis) of when the session was created
    // - slts — Unix timestamp (milis) of the last session the user had, 0 if this is the user’s first session
    init() {
        
    }

    public func get(url: String, urlref: String, shouldExtendExisting: Bool = false) -> Dictionary<String, Any?> {
        if !self.session.isEmpty {
           return self.session
        }
        // todo: think through referrers logic. What should happen if we try to get a session for a url/ref?
        var session = self.storage.get(key: self.sessionKey) ?? [:]

        if session.isEmpty {
            var visitorInfo = visitorManager.getVisitorInfo()
            visitorInfo["session_count"] = visitorInfo["session_count"] as! Int + 1
            
            session = [:]
            session["session_id"] = visitorInfo["session_count"]
            session["session_url"] = url
            session["session_referrer"] = urlref
            session["session_ts"] = Int(Date().timeIntervalSince1970)
            session["last_session_ts"] = visitorInfo["last_session_ts"]
            // this should be extracted into separate method
            self.storage.set(key: self.sessionKey, value: session as Dictionary<String, Any>, expires: Date.init(timeIntervalSinceNow: self.SESSION_TIMEOUT))
            
            visitorInfo["last_session_ts"] = session["session_ts"]
            visitorManager.setVisitorInfo(visitorInfo: visitorInfo)
        } else if shouldExtendExisting {
            self.extendSessionExpiry()
        }
        self.session = session
        return self.session
    }
    
    public func extendSessionExpiry() {
        self.storage.extendExpiry(key: self.sessionKey, expires: Date.init(timeIntervalSinceNow: self.SESSION_TIMEOUT))
    }
}
