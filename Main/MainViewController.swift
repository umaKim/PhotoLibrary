//
//  ViewController.swift
//  PhotoLibrary
//
//  Created by 김윤석 on 2023/10/31.
//

import Combine
import Photos
import UIKit

final class MainViewController: UIViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, PHAsset>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, PHAsset>
    
    enum Section { case main }
    
    private var diffableDataSource: DataSource?
    private let contentView = MainView()
    private let viewModel: MainViewModel
    private var cancellables: Set<AnyCancellable>
    
    init(_ viewModel: MainViewModel) {
        self.viewModel = viewModel
        self.cancellables = .init()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view = contentView
    }
    
    private var statusButton: [UIAction] {
        [
            UIAction(title: "3") { [weak self] _ in
                self?.viewModel.setCellStatus(.three)
                self?.updateData()
            },
            UIAction(title: "4") { [weak self] _ in
                self?.viewModel.setCellStatus(.four)
                self?.updateData()
            },
            UIAction(title: "5") { [weak self] _ in
                self?.viewModel.setCellStatus(.five)
                self?.updateData()
            }
        ]
    }
}

// MARK: - Life Cycle
extension MainViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItem()
        configureDiffableDataSource()
        bind()
    }
}

// MARK: - Navigation Bar
extension MainViewController {
    private func configureNavigationItem() {
        let menuButton = UIBarButtonItem(
            title: "",
            image: UIImage(systemName: "slider.horizontal.3"),
            primaryAction: nil,
            menu: UIMenu(title: "", children: statusButton)
        )
        navigationItem.rightBarButtonItems = [menuButton]
    }
}

// MARK: - Binding with ViewModel
extension MainViewController {
    private func bind() {
        contentView.collectionView.delegate = self
        viewModel.mainViewModelPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] type in
                switch type {
                case .updateData:
                    self?.updateData()
                case .showAlert(let message):
                    self?.showAlert(of: message)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Alert Presentation
extension MainViewController {
    private func showAlert(of message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .destructive))
        present(alertController, animated: true)
    }
}

// MARK: - Diffable DataSource
extension MainViewController {
    private func configureDiffableDataSource() {
        diffableDataSource = DataSource(
            collectionView: contentView.collectionView,
            cellProvider: {[weak self] collectionView, indexPath, _ in
                guard
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: PhotoCell.identifier,
                        for: indexPath
                    ) as? PhotoCell,
                    let self
                else { return UICollectionViewCell() }
                self.viewModel.getImage(fromAssetAt: indexPath.item) { image in
                    cell.configure(image: image)
                }
                return cell
            }
        )
    }
    
    private func updateData() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.assets)
        diffableDataSource?.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - UICollectionViewDelegate
extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.getImage(fromAssetAt: indexPath.item) { [weak self] image in
            self?.contentView.setSelectedImage(image)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let dimension = UIScreen.main.bounds.width / CGFloat(viewModel.cellStatus.rawValue)
        return CGSize(width: dimension, height: dimension)
    }
}
