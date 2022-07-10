//
//  Network.swift
//  ECleaner
//
//  Created by alexey sorochan on 09.07.2022.
//

import Connectivity

class Network {
	
	static var connectivity = Connectivity()
	
	enum Status: String {
		case unreachable, wifi, wwan
	}
	
	enum Error: Swift.Error {
		case failedToSetCallout
		case failedToSetDispatchQueue
		case failedToCreateWith(String)
		case failedToInitializeWith(sockaddr_in)
	}
	
	static func start() {
		connectivity.startNotifier()
	}
	
	static func theyLive(_ completion: @escaping(_ isAlive: Bool) -> Void) {
	
		connectivity.checkConnectivity { (checkedConnectivity) in
			switch checkedConnectivity.status {
				case .connected:
					debugPrint("connected")
					debugPrint("this is the way")
					completion(true)
				case .connectedViaCellular:
					debugPrint("connectedViaCellular")
					debugPrint("this is the way")
					completion(true)
				case .connectedViaCellularWithoutInternet:
					debugPrint("connectedViaCellularWithoutInternet")
					debugPrint("i've got a bad feellings about this")
					completion(false)
				case .connectedViaWiFi:
					debugPrint("connectedViaWiFi")
					debugPrint("this is the way")
					completion(true)
				case .connectedViaWiFiWithoutInternet:
					debugPrint("connectedViaWiFiWithoutInternet")
					debugPrint("i've got a bad feellings about this")
					completion(false)
				case .determining:
					debugPrint("keep going")
					debugPrint("determining")
				case .notConnected:
					debugPrint("i've got a bad feellings about this")
					debugPrint("notConnected")
					completion(false)
			}
		}
	}
}
