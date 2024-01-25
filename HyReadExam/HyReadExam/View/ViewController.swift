//
//  ViewController.swift
//  HyReadExam
//
//  Created by 1 on 2024/1/23.
//

import UIKit
import RxSwift

class ViewController: UIViewController {

    var collectionView: UICollectionView!
    var viewModel: BooksViewModel!
    private let disposeBag = DisposeBag()
    

    private var books: [Book] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        let booksService = BooksService()
        viewModel = BooksViewModel(booksService: booksService)
        setupCollectionView()
        bindViewModel()
    }

    private func setupCollectionView() {

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(BookCollectionViewCell.self, forCellWithReuseIdentifier: BookCollectionViewCell.identifier)

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    private func bindViewModel() {
        viewModel.books
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] newBooks in
                self?.books = newBooks
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        viewModel.errors
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] errorMessage in
                        self?.showErrorAlert(message: errorMessage)
                    })
                    .disposed(by: disposeBag)
        viewModel.fetchBooks()
    }
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Dequeue and configure the cell
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookCollectionViewCell.identifier, for: indexPath) as? BookCollectionViewCell else {
            fatalError("Unable to dequeue BookCollectionViewCell")
        }
        let book = books[indexPath.row]
        let isFavorite = viewModel.isFavorite(uuid: book.uuid)
        cell.configure(with: book, isFavorite: isFavorite)

        // Set the cell's closure to handle favorite toggle
        cell.onFavoriteToggle = { [weak self] uuid in
            self?.viewModel.toggleFavorite(uuid: uuid)
            self?.collectionView.reloadItems(at: [indexPath])
        }
        return cell
        }
}

extension ViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let padding: CGFloat = 20 * 2
            let minimumItemSpacing: CGFloat = 10 * (3 - 1)
            let availableWidth = collectionView.frame.width - padding - minimumItemSpacing
            let widthPerItem = availableWidth / 3

        let heightPerItem = widthPerItem * 1.8

            return CGSize(width: widthPerItem, height: heightPerItem)
        }
}

extension ViewController: UICollectionViewDelegate {

}



