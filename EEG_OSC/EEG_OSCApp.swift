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
    
    private let sleep_model = try! Sleep_CNN_40()
    
     
    // MARK: Mind Monitor OSC Streaming Items
    @Published var EEG: [Float] = [-1,-1,-1,-1]
    @Published var meanAlpha: [Float] = [-1]
    @Published var meanBeta: [Float] = [-1]
    @Published var meanTheta: [Float] = [-1]
    @Published var meanDelta: [Float] = [-1]

    // MARK: Data Storage
    var buffer = BufferType() // buffer object
    @Published var epoch_EEG: [[Float]] = []
    @Published var epoch_alpha: [Float] = []
    @Published var epoch_beta: [Float] = []
    @Published var epoch_delta: [Float] = []
    @Published var epoch_theta: [Float] = []
    
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
    
    // MARK: Data Buffers
    // Checks EEG buffer status and updates accordingly
    func buffer_filled(EEG : [Float]) -> Bool{
        // Not filled
        if(buffer.EEG.count < buffer.EEG_maxSamples){
            buffer.EEG.append(EEG)
            return false
        }
        // Filled
        else{
            return true
        }
    }
    
    // Checks band power buffer status and updates accordingly
    func buffer_filled(bandPower : [Float], band : String) -> Bool{
        switch band {
        case "alpha":
            // Not filled
            if(buffer.bP_alpha.count < buffer.bP_maxSamples){
                buffer.bP_alpha.append(meanAlpha[0])
                return false
            }
        case "beta":
            // Not filled
            if(buffer.bP_beta.count < buffer.bP_maxSamples){
                buffer.bP_beta.append(meanBeta[0])
                return false
            }
        case "delta":
            // Not filled
            if(buffer.bP_delta.count < buffer.bP_maxSamples){
                buffer.bP_delta.append(meanDelta[0])
                return false
            }
        case "theta":
            // Not filled
            if(buffer.bP_theta.count < buffer.bP_maxSamples){
                buffer.bP_theta.append(meanTheta[0])
                return false
            }
        default:
            print ("invalid band")
            return true
        }
        // Filled
        return true
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
                epoch_EEG = buffer.EEG
                print(epoch_EEG)
                buffer.EEG.removeAll() // Clear buffer
                while(buffer.EEG.count != 0) {}
                
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
            if buffer_filled(bandPower: meanAlpha, band: "alpha"){
                epoch_alpha = buffer.bP_alpha
                print(epoch_alpha)
                buffer.bP_alpha.removeAll() // Clear buffer
                while(buffer.bP_alpha.count != 0) {}
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
            if buffer_filled(bandPower: meanBeta, band: "beta"){
                epoch_beta = buffer.bP_beta
                print(epoch_beta)
                buffer.bP_beta.removeAll() // Clear buffer
                while(buffer.bP_beta.count != 0) {}
            }
        }
    }
    // MARK:  THETA POWER HANDLER
    func theta_handler(packet: OSCPacket) async{
        let osc_bundle = packet as? OSCBundle
        let message = osc_bundle?.elements[0] as? OSCMessage
        // Absolute Theta
        if(message?.addressPattern.fullPath == "/muse/elements/theta_absolute"){
            // Mean Theta
            self.meanTheta[0] = message?.arguments[0] as! Float
            // Extract data into epoch if buffer filled
            if buffer_filled(bandPower: meanTheta, band: "theta"){
                epoch_theta = buffer.bP_theta
              //  print(epoch_theta)
                buffer.bP_theta.removeAll() // Clear buffer
                while(buffer.bP_theta.count != 0) {}
            }
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
            // Extract data into epoch if buffer filled
            if buffer_filled(bandPower: meanDelta, band: "delta"){
                epoch_delta = buffer.bP_delta
               // print(epoch_delta)
                buffer.bP_delta.removeAll() // Clear buffer
                while(buffer.bP_delta.count != 0) {}
            }
        }
    }
    
    // MARK: Processing Data
    
    
    
    
    
}


// MARK: Receive data from OSC client
extension AppDelegate: OSCUdpServerDelegate, ObservableObject {
    
    func server(_ server: OSCUdpServer,didReceivePacket packet: OSCPacket,fromHost host: String, port: UInt16) {
       //  print("Server did receive packet from \(host):\(port)")
        Task{
            // call handler -> await item_handler(packet:packet)
            await EEG_handler(packet: packet)

            
            
            // await alpha_handler(packet: packet)
            // await beta_handler(packet: packet)
            // await theta_handler(packet: packet)
            // await alphaBeta_handler()
            // await thetaBeta_handler()
            
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

// MARK: Calculate average of array
extension Array where Element == Float {
    var mean: Double {
        let sum = self.reduce(0, { a, b in
            return a + b
        })
        let mean = Double(sum) / Double(self.count)
        return Double(mean)
    }
}




