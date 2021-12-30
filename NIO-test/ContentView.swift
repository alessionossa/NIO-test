//
//  ContentView.swift
//  NIO-test
//
//  Created by Alessio Nossa on 30/12/21.
//

import SwiftUI
import NIO

struct ContentView: View {
    
    @State var message: String? {
        didSet {
            guard let newMessage = self.message else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
                if newMessage == self.message {
                    withAnimation {
                        self.message = nil
                    }
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            
            if message != nil {
                Text(message!)
                    .padding()
            }
            
            Button("Connect") {
                self.test()
            }
        }
    }
    
    func test() {
        do {
            let serverSocketAddress = try SocketAddress(ipAddress: "164.90.235.103", port: 5356)
            
            let loopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
            
            let result = ContentView.connect(on: loopGroup, address: serverSocketAddress)
            result.whenSuccess { _ in
                withAnimation {
                    self.message = "Connected succesfully"
                }
            }
            
            result.whenFailure { connectError in
                withAnimation {
                    self.message = connectError.localizedDescription
                }
            }
        } catch let error {
            withAnimation {
                self.message = error.localizedDescription
            }
        }
    }
    
    public static func connect(on group: EventLoopGroup, address: SocketAddress) -> EventLoopFuture<Channel> {

        let bootstrap = DatagramBootstrap(group: group)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEPORT), value: 1)

        let ipv4 = address.protocol.rawValue == PF_INET
        
        return bootstrap.bind(host: ipv4 ? "0.0.0.0" : "::", port: 0)
    }
}

/*
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
 */
