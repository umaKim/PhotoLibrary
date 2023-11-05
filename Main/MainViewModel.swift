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
    
    private let imageRequestOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        return options
    }()
    
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
    
    func getImage(fromAssetAt index: Int, completion: @escaping (UIImage) -> Void) {
        imageManager.requestImage(
            for: assets[index],
            targetSize: CGSize(width: 300, height: 300),
            contentMode: .aspectFill,
            options: imageRequestOptions
        ) { (image, _) in
            completion(image ?? UIImage())
        }
    }
}

//MARK: - Private Methods
extension MainViewModel {
    private func fetchPhotosInRange() {
        repository.dataPublisher
            .sink(receiveCompletion: {[weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    self.mainViewModelSubject.send(.updateData)
                case .failure(let errorType):
                    let errorMsg: String
                    switch errorType {
                    case .restricted: errorMsg = "Access restricted"
                    case .notDetermined: errorMsg = "Access not determined"
                    case .denied: errorMsg = "Access denied"
                    }
                    self.mainViewModelSubject.send(.showAlert(errorMsg))
                }
            }, receiveValue: {[weak self] dataType in
                switch dataType {
                case .phAsset(let asset):
                    self?.assets.append(asset)
                }
            })
            .store(in: &cancellables)
    }
}
