//
//  Repository.swift
//  PhotoLibrary
//
//  Created by 김윤석 on 2023/10/31.
//

import Photos
import UIKit
import Combine

protocol Repository: AnyObject {
    var dataPublisher: AnyPublisher<RepositoryDataType, RepositoryErrorType> { get }
}

final class RepositoryImp: Repository {
    private(set) lazy var dataPublisher = dataSubject.eraseToAnyPublisher()
    private let dataSubject = PassthroughSubject<RepositoryDataType, RepositoryErrorType>()
    
    init() {
        self.fetchImage()
    }
    
    private func fetchImage() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) {[weak self] status in
            guard let self = self else { return }
            switch status {
            case .authorized:
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                for i in 0 ..< fetchResult.count {
                    let asset = fetchResult.object(at: i)
                    self.dataSubject.send(.phAsset(asset))
                }
                self.dataSubject.send(completion: .finished)
            case .denied, .restricted:
                self.dataSubject.send(completion: .failure(.denied))
            case .notDetermined:
                self.dataSubject.send(completion: .failure(.notDetermined))
            case .limited: fallthrough
            @unknown default:
                fatalError()
            }
        }
    }
}
