//
//  Network.swift
//  ECleaner
//
//  Created by alexey sorochan on 09.07.2022.
//

import Connectivity

class Network {

//	static var reachability: Reachability!
	
//	static var connectivity = Connectivity()
	
	enum Status: String {
		case unreachable, wifi, wwan
	}
	
	enum Error: Swift.Error {
		case failedToSetCallout
		case failedToSetDispatchQueue
		case failedToCreateWith(String)
		case failedToInitializeWith(sockaddr_in)
	}
	
//	static func networkingIsAlive() {
//
//		do {
//			try Network.reachability = Reachability(hostname: "serverstatus.apple.com")
//		}
//		catch {
//			switch error as? Network.Error {
//				case let .failedToCreateWith(hostname)?:
//					print("Network error:\nFailed to create reachability object With host named:", hostname)
//				case let .failedToInitializeWith(address)?:
//					print("Network error:\nFailed to initialize reachability object With address:", address)
//				case .failedToSetCallout?:
//					print("Network error:\nFailed to set callout")
//				case .failedToSetDispatchQueue?:
//					print("Network error:\nFailed to set DispatchQueue")
//				case .none:
//					print(error)
//			}
//		}
//	}
	
	static func start() {
//		connectivity.startNotifier()
	}
	
	static func theyLive(_ completion: @escaping(_ isAlive: Bool) -> Void) {
	completion(false)
//		connectivity.checkConnectivity { (checkedConnectivity) in
//			switch checkedConnectivity.status {
//				case .connected:
//					debugPrint("connected")
//					debugPrint("this is the way")
//					completion(true)
//				case .connectedViaCellular:
//					debugPrint("connectedViaCellular")
//					debugPrint("this is the way")
//					completion(true)
//				case .connectedViaCellularWithoutInternet:
//					debugPrint("connectedViaCellularWithoutInternet")
//					debugPrint("i've got a bad feellings about this")
//					completion(false)
//				case .connectedViaWiFi:
//					debugPrint("connectedViaWiFi")
//					debugPrint("this is the way")
//					completion(true)
//				case .connectedViaWiFiWithoutInternet:
//					debugPrint("connectedViaWiFiWithoutInternet")
//					debugPrint("i've got a bad feellings about this")
//					completion(false)
//				case .determining:
//					debugPrint("keep going")
//					debugPrint("determining")
//				case .notConnected:
//					debugPrint("i've got a bad feellings about this")
//					debugPrint("notConnected")
//					completion(false)
//			}
//		}
	}
	
//	static func liveConnection() -> Bool {
//
//		switch Network.reachability.status {
//			case .unreachable:
//				return false
//			case .wifi:
//				return true
//			case .wwan:
//				return true
//		}
//	}
}
