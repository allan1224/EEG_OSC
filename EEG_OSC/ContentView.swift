//
//  ContentView.swift
//  EEG_OSC
//
//  Created by Allan Frederick on 5/10/22.
//

import SwiftUI
import CoreData
import OSCKit
import Combine

struct ContentView: View {
    
    @EnvironmentObject private var appDelegate: AppDelegate
    @State var isStreaming : Bool = false
    
   //  @State var ratio_alphaBeta = (appDelegate.epoch_alpha.mean)/(appDelegate.epoch_beta.mean)
  //   @State var ratio_thetaBeta = (appDelegate.epoch_theta.mean)/(appDelegate.epoch_beta.mean)
    
    var body: some View {
    
        ZStack{
            // Background color
            LinearGradient(gradient: Gradient(colors: [.mint, .teal]),                  startPoint: UnitPoint.topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            VStack{
                Text("EEG Monitor")
                    .font(.system(size: 40, weight: .medium, design:.default))
                    .padding(34)
                HStack{
                    // Pass OSC data into UI
                     MonitorView(metric: "Tp9", imageName: "brain.head.profile", data: appDelegate.EEG[0])
                    // MonitorView(metric: "Tp10", imageName: "brain.head.profile", data: appDelegate.EEG[3])
                    // MonitorView(metric: "Af7", imageName: "brain.head.profile", data: appDelegate.EEG[1])
                    // MonitorView(metric: "Af8", imageName: "brain.head.profile", data: appDelegate.EEG[2])
                    // MonitorView(metric: "mean alpha", imageName: "brain.head.profile", data: appDelegate.meanAlpha[0])
                    // MonitorView(metric: "mean beta", imageName: "brain.head.profile", data: appDelegate.meanBeta[0])
                    // MonitorView(metric: "alpha/beta", imageName: "brain.head.profile", data: Float(appDelegate.epoch_alpha.mean)/Float((appDelegate.epoch_beta.mean)))
                    // MonitorView(metric: "theta/beta", imageName: "brain.head.profile", data: Float(appDelegate.epoch_theta.mean)/Float((appDelegate.epoch_beta.mean)))

                    
                }
                Spacer()
                Spacer()
                Spacer()
                /*
                VStack{
                    Image(systemName: "waveform.path.ecg.rectangle")
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 180, height: 180)
                        .aspectRatio(contentMode: .fit)
                        .padding(.bottom, 34)
                }
                 */
                // Start stream
                if(!isStreaming){
                    Button{
                        appDelegate.startListen()
                        isStreaming = true
                    } label: {
                        Text("Start Stream")
                            .foregroundColor(.white)
                            .buttonBorderShape(.roundedRectangle)
                            .frame(width: 280, height: 50)
                            .font(.system(size: 20, weight: .bold, design: .default))
                            .cornerRadius(40)
                    }
                }
                // Stop stream
                if(isStreaming){
                    Button{
                        appDelegate.stopListen()
                        isStreaming = false
                    } label: {
                        Text("Stop Stream")
                            .foregroundColor(.white)
                            .buttonBorderShape(.roundedRectangle)
                            .frame(width: 280, height: 50)
                            .font(.system(size: 20, weight: .bold, design: .default))
                            .cornerRadius(40)
                    }
                }
                Spacer()
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

struct MonitorView: View {
    var metric: String
    var imageName: String
    var data: Float
    var body: some View {
        VStack{
            Text(metric)
                .font(.system(size: 25, weight: .medium, design: .default))
                .padding()
            Image(systemName: imageName)
                .renderingMode(.original)
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
                .aspectRatio(contentMode: .fit)
            Text(data.clean)
                .bold()
                .font(.system(size: 25, weight: .medium, design: .default))
                .padding()
        }
    }
}

extension Float {
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

