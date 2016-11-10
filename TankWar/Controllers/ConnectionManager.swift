//
//  ConnectionManager.swift
//  TankWar
//
//  Created by 阿若 on 16/6/27.
//  Copyright © 2016年 阿若. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import CocoaAsyncSocket

public typealias PeerSocketBlock = ((mySocket: GCDAsyncSocket, peerSocket: GCDAsyncSocket) -> Void)
public typealias EventSocketBlock = ((peer: GCDAsyncSocket, event: String, object: AnyObject?) -> Void)
public typealias ObjectSocketBlock = ((peer: GCDAsyncSocket, object: AnyObject?) -> Void)

let socketPort: UInt16 = 8123

protocol MPCSerializable {
    var mpcSerialized: NSData { get }
    init(mpcSerialized: NSData)
}

enum Event: String {
    case StartGame = "StartGame",
    Location = "Location",
    Move = "Move",
    Fire = "Fire",
    ReLive = "ReLive",
    EndGame = "EndGame"
}

private let myName = UIDevice.currentDevice().name

class ConnectionManager: NSObject, NSNetServiceDelegate, NSNetServiceBrowserDelegate, GCDAsyncSocketDelegate {

    // MARK: Event Blocks
    var onConnecting: PeerSocketBlock?
    var onConnect: PeerSocketBlock?
    var onDisconnect: PeerSocketBlock?
    var onEvent: EventSocketBlock?
    var onEventObject: ObjectSocketBlock?
    var eventBlocks = [String: ObjectSocketBlock]()
    
    
    // MARK: Properties
    var isServer: Bool = true
    var listenSocket: GCDAsyncSocket!
    var connectedSockets: [GCDAsyncSocket]!
    var connectedSocketNames = [String]()
    var serverIP: String!
    var socketQueue: dispatch_queue_t!
    var serverService: NSNetService!
    var serverAddresses: [NSData]!
    var netService: NSNetService!
    var netServiceBrowser: NSNetServiceBrowser!
    
    private var peers: [GCDAsyncSocket] {
        return connectedSockets as [GCDAsyncSocket]? ?? []
    }

    var otherPlayers: [Player] {
        return connectedSocketNames.map { Player(peerName: $0) }
    }


    // MARK: Start

    func initSocket() {
        socketQueue = dispatch_queue_create("socketQueue", nil)
        GetIPAddress.deviceIPAdress()
        if isServer == true {
            NSLog("I am Server.\n")
            listenSocket = GCDAsyncSocket(delegate: self, delegateQueue: socketQueue)
            connectedSockets = []
            //isServer = true
        }
        else {
            NSLog("I am Client.\n")
            listenSocket = GCDAsyncSocket(delegate: self, delegateQueue: socketQueue)
            serverIP = GetIPAddress.routerIPAddress()
            NSLog("Server IP is: \(serverIP)")
            //isServer = false
        }
    }
    func start() {
        if isServer == true {
            do {
                NSLog("Start the Server...")
                try listenSocket.acceptOnPort(0)
                NSLog("did Start the Server on \(listenSocket.localHost):\(listenSocket.localPort)")
                let port = Int32(listenSocket.localPort)
                netService = NSNetService(domain: "local.", type: "_YourServiceName._tcp.", name: "TankWar", port: port)
                
                netService.delegate = self
                netService.publish()
            }
            catch _ {
                NSLog("fail to create the server")
            }
        }
        else {
            do {
                NSLog("Try to connect the Server...")
                
                netServiceBrowser = NSNetServiceBrowser()
                netServiceBrowser.delegate = self
                netServiceBrowser.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
                netServiceBrowser.searchForServicesOfType("_YourServiceName._tcp.", inDomain: "local.")
                
//                try listenSocket.connectToHost("0.0.0.0", onPort: socketPort)
//                if listenSocket.isConnected {
//                    NSLog("Send the Name")
//                    let data = NSKeyedArchiver.archivedDataWithRootObject(
//                        ["event": "Name", "object": myName])
//                    listenSocket.writeData(data, withTimeout: -1, tag: 0)
//                }
            }
        }
    }

    func stop() {
        listenSocket.disconnect()
        if isServer == true {
            for socket in connectedSockets {
                socket.disconnect()
            }
            connectedSockets.removeAll()
        }
        NSLog("did stop the server")
    }
    
    // MARK: Sending
    
    func sendEvent(event: Event, object: [String: MPCSerializable]? = nil, toPeers peers: [GCDAsyncSocket]?) {
        var anyObject: [String: NSData]?
        if let object = object {
            anyObject = [String: NSData]()
            for (key, value) in object {
                anyObject![key] = value.mpcSerialized
            }
        }
        sendEvent(event.rawValue, object: anyObject, toPeers: peers)
    }
    
    func sendEventForEach(event: Event, @noescape objectBlock: () -> ([String: MPCSerializable])) {
        if isServer == true {
            sendEvent(event, object: objectBlock(), toPeers: peers)
        }
        else {
            sendEvent(event, object: objectBlock(), toPeers: [listenSocket])
        }
    }
    
    func sendEvent(event: String, object: AnyObject? = nil, toPeers peers: [GCDAsyncSocket]?) {
        guard let peers = peers where !peers.isEmpty else {
            return
        }
        
        var rootObject: [String: AnyObject] = ["event": event]
        
        if let object: AnyObject = object {
            rootObject["object"] = object
        }
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(rootObject)
        sendData(data, toPeers: peers)
        
    }
    
    func sendData(data: NSData, toPeers: [GCDAsyncSocket]) {
        if isServer == true {
            for socket in peers {
                socket.writeData(data, withTimeout: -1, tag: 0)
       //         socket.readDataWithTimeout(-1, tag: 0)
            }
        }
        else {
            listenSocket.writeData(data, withTimeout: -1, tag: 0)
      //      listenSocket.readDataWithTimeout(-1, tag: 0)
        }
    }
    
    // Mark: NSNetServiceDelegate
    
    func netServiceWillPublish(sender: NSNetService) {
        NSLog("Bonjour Service Will Publish")
    }
    
    func netServiceDidPublish(sender: NSNetService) {
        NSLog("Bonjour Service Published: domain(\(sender.domain)) type(\(sender.type)) name(\(sender.name)) port(\(sender.port))")
    }
    
    func netServiceDidStop(sender: NSNetService) {
        NSLog("Service Did Stop")
    }
    
    func netService(sender: NSNetService, didNotPublish errorDict: [String : NSNumber]) {
        NSLog("Bonjour Service Failed to Published: domain(\(sender.domain)) type(\(sender.type)) name(\(sender.name)) port(\(sender.port))")
    }
    
    func netServiceWillResolve(sender: NSNetService) {
        NSLog("Bonjour Service Will Resolve")
    }
    
    // Mark: NSNetServiceBrowseDelegate
    
    func netServiceBrowserWillSearch(browser: NSNetServiceBrowser) {
        NSLog("Service Brower Will Search")
    }
    func netServiceBrowser(browser: NSNetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        NSLog("DidNotSearch: \(errorDict)")
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didFindService service: NSNetService, moreComing: Bool) {
        NSLog("DidFindService: \(service.name)")
        // Connect to the first service we find
        if (serverService == nil) {
            NSLog("Resolving...")
            serverService = service;
            serverService.delegate = self
            serverService.resolveWithTimeout(5.0)
        }
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveService service: NSNetService, moreComing: Bool) {
        NSLog("DidRemoveService: \(service.name)")
    }
    
    func netServiceBrowserDidStopSearch(browser: NSNetServiceBrowser) {
        NSLog("DidStopSearch")
    }
    
    func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
        NSLog("DidNotResolve")
    }
    
    func netServiceDidResolveAddress(sender: NSNetService) {
        NSLog("DidResolve: \(sender.addresses)")
        
        if (serverAddresses == nil) {
            serverAddresses = sender.addresses//[[sender addresses] mutableCopy];
        }
        
        connectToNextAddress()
    }
    
    func connectToNextAddress() {
        var done = false
        while (!done && (serverAddresses.count > 0)) {
            var addr: NSData? = nil
            // Note: The serverAddresses array probably contains both IPv4 and IPv6 addresses.
            //
            // If your server is also using GCDAsyncSocket then you don't have to worry about it,
            // as the socket automatically handles both protocols for you transparently.
            if (true) // Iterate forwards
            {
                addr = serverAddresses.removeFirst()
            }
//            else // Iterate backwards
//            {
//                addr = ConnectionManager.serverAddresses.removeLast()
//            }
            
            NSLog("Attempting connection to \(addr!.host()):\(addr!.port())")
            do {
                try listenSocket.connectToAddress(addr!)
                done = true
            }
            catch _ {
                NSLog("Unable to connect: \(addr)")
            }
            
        }
        if (!done) {
            NSLog("Unable to connect to any resolved address");
        }

    }


    // MARK: Event Handling
    func onConnect(run: PeerSocketBlock?) {
        onConnect = run
    }

    func onDisconnect(run: PeerSocketBlock?) {
        onDisconnect = run
    }

    func onEvent(event: Event, run: ObjectSocketBlock?) {
        if let run = run {
            NSLog("did setup on event \(event.rawValue)")
            eventBlocks[event.rawValue] = run
        } else {
            eventBlocks.removeValueForKey(event.rawValue)
        }
    }
    
    
    // Mark: GCDAsyncSocketDelegate
    
    func socket(sock: GCDAsyncSocket!, didAcceptNewSocket newSocket: GCDAsyncSocket!) {
        connectedSockets.append(newSocket)
        NSLog("did Accept new Socket on \(newSocket.connectedHost):\(newSocket.connectedPort)")
        let data = NSKeyedArchiver.archivedDataWithRootObject(
            ["event": "Name", "object": myName])
        newSocket.delegate = self
        newSocket.delegateQueue = dispatch_get_main_queue()//sock.delegateQueue
        for _ in 1..<10 {
            newSocket.writeData(data, withTimeout: -1, tag: 0)
        }
        newSocket.readDataWithTimeout(-1, tag: 0)
    }
    
    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        if let index = connectedSockets.indexOf(sock) {
            connectedSockets.removeAtIndex(index)
        }
        NSLog("Connection Error occured: \(err)")
    }
    
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        NSLog("did Connect to Host:\(host):\(port)")
        let data = NSKeyedArchiver.archivedDataWithRootObject(
                                    ["event": "Name", "object": myName])
        for _ in 1..<10 {
            sock.writeData(data, withTimeout: -1, tag: 0)
        }
        sock.readDataWithTimeout(-1, tag: 0)
    }
    
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        if let dict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String: AnyObject],
            let event = dict["event"] as? String,
            let object: AnyObject? = dict["object"] {
            if isServer == true {
                for socket in connectedSockets {
                    if sock == socket { continue }
                    socket.writeData(data, withTimeout: -1, tag: 0)
                    //    socket.readDataWithTimeout(-1, tag: 0)
                }
            }
            if event == "Name" {
                NSLog("receive name \(object!)")
                if connectedSocketNames.indexOf(object as! String) == nil {
                    connectedSocketNames.append(object as! String)
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                if let onEvent = self.onEvent {
                    onEvent(peer: sock, event: event, object: object)
                }
                if let eventBlock = self.eventBlocks[event] {
                    eventBlock(peer: sock, object: object)
                }
            }
        }
        sock.readDataWithTimeout(-1, tag: 0)
    }
    
    func socket(sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        NSLog("Socket did write data withTag \(tag)")
        sock.readDataWithTimeout(-1, tag: 0)
    }
    
}
