//
//  AlertaTrade.swift
//  FunctionsIBM
//
//  Created by Felipe Menezes on 28/01/19.
//

import Foundation

struct Output: Codable {
    let result: Bool
    let msg: String
}

let urlAtivosList = "https://tradewallet.mybluemix.net/api/NotificationApi/silent"


let defaultSession = URLSession(configuration: .default)
var dataTask: URLSessionDataTask?

func main(completion: @escaping (Output?, Error?) -> Void) -> Void {

    var output: Output? = Output(result: false, msg: "ocorreu um erro")
    list() { result, msg in
        if result {
            output = Output(result: true, msg: "alerta gerado")
            completion(output, nil)
        } else { completion(Output(result: false, msg: "ocorreu um erro:" + (msg ?? "")), nil) }
    }
}

/// list Ativos
func list(onComplete: @escaping (_ result: Bool, _ error: String?) -> Void) {
    guard let url = URL(string: urlAtivosList) else {
        onComplete(false, nil)
        return
    }
    var request = URLRequest(url: url)
    
    let postString = "action=alertTrade"
    request.httpBody = postString.data(using: String.Encoding.utf8)
    //print("Data \(json)")
    request.setValue("Basic YWRtaW46ZGVsdGEjQCE0MDB2eA==",
                     forHTTPHeaderField: "Authorization")
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    request.networkServiceType = .default
    request.cachePolicy = .useProtocolCachePolicy
    dataTask?.cancel()

    dataTask = defaultSession.dataTask(with: request) { data, response, error in
        defer { dataTask = nil }
        //print("Response \(response)")
        if let error = error {
            let errorMessage = "DataTask error: " + error.localizedDescription + "\n"
            onComplete(false, errorMessage)
            return
        } else if let dat = data,
            let response = response as? HTTPURLResponse,
            response.statusCode == 200 {
            //print("\(form)")
            onComplete(true, nil)
            return
        }
        onComplete(false, "\(response.debugDescription) \(error.debugDescription)")
    }
    dataTask?.resume()
}
