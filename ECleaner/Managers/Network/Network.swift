//
//  Network.swift
//  ECleaner
//
//  Created by alexey sorochan on 09.07.2022.
//

import Connectivity

enum NetworkStatus {
	case connedcted
	case unreachable
}

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
	
	static func theyLive(_ completion: @escaping(_ status: NetworkStatus) -> Void) {
	
		connectivity.checkConnectivity { (checkedConnectivity) in
			switch checkedConnectivity.status {
				case .connected:
					debugPrint("connected")
					debugPrint("this is the way")
					completion(.connedcted)
				case .connectedViaCellular:
					debugPrint("connectedViaCellular")
					debugPrint("this is the way")
					completion(.connedcted)
				case .connectedViaCellularWithoutInternet:
					debugPrint("connectedViaCellularWithoutInternet")
					debugPrint("i've got a bad feellings about this")
					completion(.unreachable)
				case .connectedViaWiFi:
					debugPrint("connectedViaWiFi")
					debugPrint("this is the way")
					completion(.connedcted)
				case .connectedViaWiFiWithoutInternet:
					debugPrint("connectedViaWiFiWithoutInternet")
					debugPrint("i've got a bad feellings about this")
					completion(.unreachable)
				case .determining:
					debugPrint("keep going")
					debugPrint("determining")
				case .notConnected:
					debugPrint("i've got a bad feellings about this")
					debugPrint("notConnected")
					completion(.unreachable)
			}
		}
	}
}
