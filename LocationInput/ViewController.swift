//
//  ViewController.swift
//  LocationInput
//
//  Created by Ruoyu Fu on 2019/5/2.
//  Copyright © 2019 Tappollo. All rights reserved.
//

import UIKit
import GooglePlaces
import RxCocoa
import RxSwift

class ViewController: UIViewController {

    let disposeBag = DisposeBag()
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var pickupResults: UITableView!
    @IBOutlet weak var dropoffResults: UITableView!
    @IBOutlet weak var pickupField: UITextField!
    @IBOutlet weak var dropoffField: UITextField!
    let pickupSource = GMSAutocompleteTableDataSource()
    let dropoffSource = GMSAutocompleteTableDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindModels(textField: pickupField, table: pickupResults, source: pickupSource)
        bindModels(textField: dropoffField, table: dropoffResults, source: dropoffSource)
    }
    func setupView() {
        header.layer.masksToBounds = false
        header.layer.shadowOffset = CGSize(width: 1, height: 1)
        header.layer.shadowRadius = 3
        header.layer.shadowOpacity = 0.3
    }
    func bindModels(textField: UITextField, table: UITableView, source: GMSAutocompleteTableDataSource) {
        table.delegate = source
        table.dataSource = source
        Observable.merge([
            textField.rx.controlEvent([.editingDidBegin]).map({false}),
            textField.rx.controlEvent([.editingDidEnd]).map({true})
            ])
            .bind(to: table.rx.isHidden)
            .disposed(by: disposeBag)
        textField.rx.text
            .bind(to: source.rx.sourceText)
            .disposed(by: disposeBag)
        source.rx.didUpdateAutocompletePredictions
            .bind {table.reloadData()}.disposed(by: disposeBag)
        source.rx.didAutocompletePlace
            .filter({$0 != nil})
            .map({$0!.name})
            .do(onNext: {_ in textField.resignFirstResponder()})
            .bind(to: textField.rx.text)
            .disposed(by: disposeBag)
    }

}
