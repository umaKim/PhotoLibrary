//
//  MainViewModel.swift
//  PhotoLibrary
//
//  Created by 김윤석 on 2023/10/31.
//
import UIKit
import Photos
import Combine

enum CellStatus: Int {
    case three = 3
    case four = 4
    case five = 5
}

enum MainViewModelNotificationType {
    case updateData
    case showAlert(String)
}

final class MainViewModel {
    private(set) lazy var mainViewModelPublisher = mainViewModelSubject.eraseToAnyPublisher()
    private let mainViewModelSubject = PassthroughSubject<MainViewModelNotificationType, Never>()
    private(set) var assets: [PHAsset] = []
    private(set) var imageManager = PHCachingImageManager()
    private(set) var cellStatus: CellStatus = .three
    private let repository: Repository
    private var cancellables: Set<AnyCancellable>
    
    init(_ repository: Repository) {
        self.repository = repository
        self.cancellables = .init()
        fetchPhotosInRange()
    }
}

//MARK: - Public Methods
extension MainViewModel {
    func setCellStatus(_ status: CellStatus) {
        self.cellStatus = status
    }
    
    func convertToImage(
        fromAssetAt index: Int,
        completion: @escaping(UIImage) -> Void
    ) {
        getUIImageFromPHAsset(
            asset: assets[index],
            completion: completion
        )
    }
    
    func imageOfAsset(
        at index: Int,
        completion: @escaping (UIImage) -> Void
    ) {
        let targetSize = CGSize(
            width: UIScreen.main.bounds.width/CGFloat(cellStatus.rawValue),
            height: UIScreen.main.bounds.width/CGFloat(cellStatus.rawValue)
        )
        imageManager.requestImage(
            for: assets[index],
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: nil
        ) { (image, _) in
            completion(image ?? UIImage())
        }
    }
}

//MARK: - Private Methods
extension MainViewModel {
    private func fetchPhotosInRange() {
        repository
            .dataPublisher
            .sink(receiveCompletion: {[weak self] completion in
                switch completion {
                case .finished:
                    self?.mainViewModelSubject.send(.updateData)
                    
                case .failure(let errorType):
                    switch errorType {
                    case .restricted, .notDetermined, .denied: 
                        self?.mainViewModelSubject.send(.showAlert("Error"))
                    }
                }
            }, receiveValue: {[weak self] dataType in
                switch dataType {
                case .phAsset(let asset):
                    self?.assets.append(asset)
                }
            })
            .store(in: &cancellables)
    }
    
    private func getUIImageFromPHAsset(
        asset: PHAsset,
        completion: @escaping (UIImage) -> Void
    ) {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = false
        option.deliveryMode = .highQualityFormat
        
        manager.requestImage(
            for: asset,
            targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
            contentMode: .aspectFill,
            options: option,
            resultHandler: {
                (result, info) -> Void in
                guard let result else { return }
                completion(result)
            }
        )
    }
}
