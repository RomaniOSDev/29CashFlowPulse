//
//  CheckLink.swift
//  BubblyBass
//
//  Created by Роман Главацкий on 26.10.2025.
//

import Foundation

class CheckURLService {
    
    // MARK: - Shared Instance
    static let shared = CheckURLService()
    private var currentTask: URLSessionDataTask?
    
    // MARK: - Configuration
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 8.0
        configuration.timeoutIntervalForResource = 12.0
        configuration.waitsForConnectivity = true
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Public Methods
    
    static func checkURLStatus(urlString: String, completion: @escaping (Bool) -> Void) {
        shared.performCheck(urlString: urlString, completion: completion)
    }
    
    // Альтернативный метод с URL
    static func checkURLStatus(url: URL, completion: @escaping (Bool) -> Void) {
        shared.performCheck(url: url, completion: completion)
    }
    
    func cancelCurrentCheck() {
        currentTask?.cancel()
        currentTask = nil
    }
    
    // MARK: - Private Methods
    
    private func performCheck(urlString: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: urlString) else {
            print("❌ CheckURLService: Invalid URL string: \(urlString)")
            DispatchQueue.main.async { completion(false) }
            return
        }
        performCheck(url: url, completion: completion)
    }
    
    private func performCheck(url: URL, completion: @escaping (Bool) -> Void) {
        cancelCurrentCheck()
        
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 10.0
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        print("🔍 CheckURLService: Checking URL: \(url.absoluteString)")
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            self.currentTask = nil
            
            // Обрабатываем ошибки
            if let error = error {
                let errorMessage: String
                
                switch (error as NSError).code {
                case NSURLErrorTimedOut:
                    errorMessage = "Request timed out"
                case NSURLErrorNotConnectedToInternet:
                    errorMessage = "No internet connection"
                case NSURLErrorNetworkConnectionLost:
                    errorMessage = "Network connection lost"
                case NSURLErrorCancelled:
                    print("ℹ️ CheckURLService: Request cancelled")
                    return
                default:
                    errorMessage = error.localizedDescription
                }
                
                print("❌ CheckURLService: Error: \(errorMessage)")
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            // Проверяем HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ CheckURLService: No HTTP response")
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            let statusCode = httpResponse.statusCode
            print("ℹ️ CheckURLService: Status code: \(statusCode) for URL: \(url.absoluteString)")
            
            // Более гибкая проверка статус кода
            let isValidResponse: Bool
            
            switch statusCode {
            case 200..<300:
                // Успешные коды (200-299)
                isValidResponse = true
            case 404:
                // Страница не найдена
                isValidResponse = false
            case 403, 401:
                // Доступ запрещен/неавторизован
                isValidResponse = false
            case 500..<600:
                // Ошибки сервера
                isValidResponse = false
            default:
                // Все остальные коды считаем невалидными
                isValidResponse = false
            }
            
            DispatchQueue.main.async {
                completion(isValidResponse)
            }
        }
        
        currentTask = task
        task.resume()
        
        // Fallback таймаут
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) { [weak self] in
            if let task = self?.currentTask, task.state == .running {
                print("⚠️ CheckURLService: Forcing timeout completion for URL: \(url.absoluteString)")
                self?.currentTask?.cancel()
                self?.currentTask = nil
                completion(false)
            }
        }
    }
    
    deinit {
        cancelCurrentCheck()
        session.invalidateAndCancel()
        print("♻️ CheckURLService deinitialized")
    }
}
