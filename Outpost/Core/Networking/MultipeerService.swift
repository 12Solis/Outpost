//
//  MultipeerService.swift
//  Outpost
//
//  Created by Leonardo Solís on 27/12/25.
//

import Foundation
import MultipeerConnectivity
import SwiftUI

@Observable
class MultipeerService: NSObject{
    
    var securityCode: String = "1234" // Make user input
    
    var onDataReceived: ((Data, MCPeerID) -> Void)?
    
    //MARK: Properties
    private let serviceType = "outpost-p2p"
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    
    private var serviceAdvertiser : MCNearbyServiceAdvertiser
    private var serviceBrowser: MCNearbyServiceBrowser
    private var session: MCSession
    
    //MARK: Observable State
    var connectedPeers: [MCPeerID] = []
    var isBrwosing = false
    
    override init() {
        self.session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        
        super.init()
        
        self.session.delegate = self
        self.serviceAdvertiser.delegate = self
        self.serviceBrowser.delegate = self
    }
    
    //MARK: Public API
    func start(){
        print("Starting P2P Service...")
        self.serviceAdvertiser.startAdvertisingPeer()
        self.serviceBrowser.startBrowsingForPeers()
        self.isBrwosing = true
    }
    
    func stop(){
        print("Stopping P2P Service...")
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
        self.isBrwosing = false
    }
    
    func send(data:Data){
        //Add data sending
        guard !connectedPeers.isEmpty else { return }
        
        do{
            try session.send(data, toPeers: connectedPeers, with: .reliable)
        } catch{
            print("Error sending data: \(error.localizedDescription)")
        }
    }
    
}

//MARK: MCSessionDelegate
extension MultipeerService: MCSessionDelegate{
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                print("Connected to: \(peerID.displayName)")
                if !self.connectedPeers.contains(peerID) {
                    self.connectedPeers.append(peerID)
                }
            case .notConnected:
                print("Disconnected from: \(peerID.displayName)")
                if let index = self.connectedPeers.firstIndex(of: peerID) {
                    self.connectedPeers.remove(at: index)
                }
            case .connecting:
                print("Connecting to: \(peerID.displayName)...")
            @unknown default:
                break
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.onDataReceived?(data, peerID)
        }
        print("Received \(data.count) bytes from \(peerID.displayName)")
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
    
}

//MARK: AdvertiseDelegate
extension MultipeerService: MCNearbyServiceAdvertiserDelegate{
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        guard let context = context,
              let receivedCode = String(data: context, encoding: .utf8) else {
            print("Declining \(peerID.displayName): No security code provided.")
            invitationHandler(false, nil)
            return
        }
        
        if receivedCode == self.securityCode {
            print("Accepting \(peerID.displayName): Security code match.")
            invitationHandler(true, self.session)
        } else {
            print("Declining \(peerID.displayName): Invalid security code.")
            invitationHandler(false, nil)
        }
    }
}

//MARK: BrowserDelegate
extension MultipeerService: MCNearbyServiceBrowserDelegate{
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Found peer: \(peerID.displayName). Inviting with security code...")

        if let contextData = securityCode.data(using: .utf8) {
            browser.invitePeer(peerID, to: self.session, withContext: contextData, timeout: 10)
        }
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer: \(peerID.displayName)")
    }
}
