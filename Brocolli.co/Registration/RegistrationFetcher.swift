//
//  RegistrationFetcher.swift
//  Brocolli.co
//
//  Created by Jason Chan on 5/8/21.
//

import Foundation
import RxSwift

enum RegistrationError: Error {
    case server(String)
    case network
    case `internal`
}

struct RegistrationFailure: Decodable {
    let errorMessage: String
}

final class RegistrationFetcher {

    private func makeRequest(url: URL, data: Data) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        return request
    }

    private func performRequest(_ request: URLRequest, session: URLSession) -> Single<Data> {
        Single.create { observer in
            let task = session.dataTask(
                with: request,
                completionHandler: { data, urlResponse, error in
                    let successRange = 200..<300
                    if let response = urlResponse as? HTTPURLResponse,
                       successRange.contains(response.statusCode),
                       let data = data
                    {
                        observer(.success(data))
                    } else if let error = error {
                        observer(.failure(error))
                    } else if
                        let data = data,
                        let failure = try? JSONDecoder().decode(RegistrationFailure.self, from: data)
                    {
                        observer(.failure(RegistrationError.server(failure.errorMessage)))
                    } else {
                        observer(.failure(RegistrationError.network))
                    }
                }
            )

            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
}

extension RegistrationFetcher: RegistrationFetching {

    func register(registration: Registration) -> Single<Registration> {
        guard
            let url = URL(string: "https://us-central1-blinkapp-684c1.cloudfunctions.net/fakeAuth"),
            let data = try? JSONEncoder().encode(registration)
        else {
            return .error(RegistrationError.internal)
        }

        let request = makeRequest(url: url, data: data)
        return performRequest(request, session: .shared).map { _ in registration }
    }
}
