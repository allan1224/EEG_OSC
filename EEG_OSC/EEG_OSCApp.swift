//
//  EEG_OSCApp.swift
//  EEG_OSC
//  An interface for BCI/Neurofeedback applications using OSC stream from Mind Monitor App
//
//  Created by Allan Frederick on 5/10/22.
//

import SwiftUI
import OSCKit
import Combine

@main
struct EEG_OSCApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    init(){
    }
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate{
    
    // MARK: Mind Monitor Streaming Items
    @Published var EEG: [Float] = [-1,-1,-1,-1]
    @Published var meanAlpha: [Float] = [-1]
    @Published var meanBeta: [Float] = [-1]
    @Published var meanTheta: [Float] = [-1]
    @Published var meanDelta: [Float] = [-1]
    
    var buffer = BufferType() // buffer object
    
    // MARK: Configuration
    private let server = OSCUdpServer(port: 5000)
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        server.delegate = self // server
        return true
    }
    
    func startListen(){
        do {
            try server.startListening()
            print("listening")
        } catch {
            print(error.localizedDescription)
        }
    }
    func stopListen(){
        server.stopListening()
    }
    
    // MARK: Data Processing


    
    
    // Checks EEG buffer status and updates accordingly
    func buffer_filled(EEG : [Float]) -> Bool{
        // Not filled
        if(buffer.EEG.count < buffer.EEG_maxSamples){
            buffer.EEG.append(EEG[0])
            return false
        }
        // Filled
        else{
            return true
        }
    }
    // Checks band power buffer status and updates accordingly
    func buffer_filled(bandPower : [Float]) -> Bool{
        // Not filled
        if(buffer.bP_alpha.count < buffer.bP_maxSamples){
            buffer.bP_alpha.append(EEG[0])
            return false
        }
        // Filled
        else{
            return true
        }
    }
    
    // MARK:  EEG HANDLER
    func EEG_handler(packet: OSCPacket) async{
        let osc_bundle = packet as? OSCBundle
        let message = osc_bundle?.elements[0] as? OSCMessage
        // Raw EEG
        if(message?.addressPattern.fullPath == "/muse/eeg"){
            // Tp9
            self.EEG[0] = message?.arguments[0] as! Float
            // AF7
            self.EEG[1] = message?.arguments[1] as! Float
            // AF8
            self.EEG[2] = message?.arguments[2] as! Float
            // Tp10
            self.EEG[3] = message?.arguments[3] as! Float
            // Extract data into epoch if buffer filled
            if buffer_filled(EEG: EEG){
                var data_epoch = EEG_buffer
                print(data_epoch)
                EEG_buffer.removeAll()
                while(EEG_buffer.count != 0) {}
            }
        }
    }
    // MARK:  ALPHA POWER HANDLER
    func alpha_handler(packet: OSCPacket) async{
        let osc_bundle = packet as? OSCBundle
        let message = osc_bundle?.elements[0] as? OSCMessage
        // Absolute Alpha
        if(message?.addressPattern.fullPath == "/muse/elements/alpha_absolute"){
            // Mean alpha
            self.meanAlpha[0] = message?.arguments[0] as! Float
            // Extract data into epoch if buffer filled
            if buffer_filled(bandPower: meanAlpha){
                var data_epoch = bP_buffer_alpha
                print(data_epoch)
                bP_buffer_alpha.removeAll()
                while(bP_buffer_alpha.count != 0) {}
            }
        }
    }
    // MARK:  BETA POWER HANDLER
    func beta_handler(packet: OSCPacket) async{
        let osc_bundle = packet as? OSCBundle
        let message = osc_bundle?.elements[0] as? OSCMessage
        // Absolute Beta
        if(message?.addressPattern.fullPath == "/muse/elements/beta_absolute"){
            // Mean Beta
            self.meanBeta[0] = message?.arguments[0] as! Float
            // Extract data into epoch if buffer filled
            if buffer_filled(bandPower: meanBeta){
                var data_epoch = bP_buffer_beta
                print(data_epoch)
                bP_buffer_beta.removeAll()
                while(bP_buffer_beta.count != 0) {}
            }
        }
    }
    // MARK:  THETA POWER HANDLER
    func theta_handler(packet: OSCPacket) async{
        let osc_bundle = packet as? OSCBundle
        let message = osc_bundle?.elements[0] as? OSCMessage
        // Absolute Theta
        if(message?.addressPattern.fullPath == "/muse/elements/theta_absolute"){
            // Mean Beta
            self.meanTheta[0] = message?.arguments[0] as! Float
        }
    }
    // MARK:  DELTA POWER HANDLER
    func delta_handler(packet: OSCPacket) async{
        let osc_bundle = packet as? OSCBundle
        let message = osc_bundle?.elements[0] as? OSCMessage
        // Absolute Delta
        if(message?.addressPattern.fullPath == "/muse/elements/delta_absolute"){
            // Mean Delta
            self.meanDelta[0] = message?.arguments[0] as! Float
        }
    }
    
   
    

    
}

// MARK: Receive data from OSC client
extension AppDelegate: OSCUdpServerDelegate, ObservableObject {
    
    func server(_ server: OSCUdpServer,didReceivePacket packet: OSCPacket,fromHost host: String, port: UInt16) {
       //  print("Server did receive packet from \(host):\(port)")
        Task{
            // call handler -> await item_handler(packet:packet)
            await EEG_handler(packet: packet)
            await alpha_handler(packet: packet)
            await beta_handler(packet: packet)
        }
    }

    func server(_ server: OSCUdpServer,
                socketDidCloseWithError error: Error?) {
        if let error = error {
           print("Server did stop listening with error: \(error.localizedDescription)")
        } else {
           print("Server did stop listening")
        }
    }
    
    func server(_ server: OSCUdpServer,
                didReadData data: Data,
                with error: Error) {
        print("Server did read data with error: \(error.localizedDescription)")
    }
    
}




