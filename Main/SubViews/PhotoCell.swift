//
//  PhotoCell.swift
//  PhotoLibrary
//
//  Created by 김윤석 on 2023/10/31.
//

import UIKit

final class PhotoCell: UICollectionViewCell {
    static let identifier = String(describing: PhotoCell.self)
    
    private lazy var imageView: UIImageView = {
        let uv = UIImageView()
        uv.contentMode = .scaleAspectFill
        return uv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Public Method
extension PhotoCell {
    func configure(image: UIImage) {
        self.imageView.image = image
    }
}

//MARK: - Private Method
extension PhotoCell {
    private func setupUI() {
        layer.masksToBounds = true
        
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
}
