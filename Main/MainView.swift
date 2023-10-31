//
//  MainView.swift
//  PhotoLibrary
//
//  Created by 김윤석 on 2023/10/31.
//

import UIKit

final class MainView: UIView {
    //MARK: - UI Objects
    private lazy var messageLabel: UILabel = {
       let lb = UILabel()
        lb.text = "사진을 선택하세요."
        lb.textColor = .black
        return lb
    }()
    
    private lazy var selectedImageView: UIImageView = {
        let uv = UIImageView()
        uv.contentMode = .scaleAspectFit
        uv.backgroundColor = .white
        return uv
    }()
    
    private(set) lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.identifier)
        return cv
    }()
    
    //MARK: - Init
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Public Method
extension MainView {
    func setSelectedImage(_ image: UIImage) {
        self.selectedImageView.image = image
        self.messageLabel.isHidden = selectedImageView.image != nil
    }
}

//MARK: - Set Up UI
extension MainView {
    private func setupUI() {
        addSubviews(selectedImageView, messageLabel, collectionView)
        
        NSLayoutConstraint.activate([
            selectedImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            selectedImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            selectedImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            
            messageLabel.centerXAnchor.constraint(equalTo: selectedImageView.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: selectedImageView.centerYAnchor),
            
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: selectedImageView.bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height/CGFloat(2))
        ])
    }
}
