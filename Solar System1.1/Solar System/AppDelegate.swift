//
//  AppDelegate.swift
//  Solar System
//
//  Created by Admin on 25/05/17.
//  Copyright (c) 2017 AppCoda. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        window.acceptsMouseMovedEvents = true //now window will recieve mouse move events
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
}
