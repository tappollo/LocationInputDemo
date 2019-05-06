//
//  GMSRXExtensions.swift
//  LocationInput
//
//  Created by Ruoyu Fu on 2019/5/3.
//  Copyright © 2019 Tappollo. All rights reserved.
//

import RxSwift
import RxCocoa
import GooglePlaces

extension GMSAutocompleteTableDataSource: HasDelegate {
    public typealias Delegate = GMSAutocompleteTableDataSourceDelegate
}

open class RxGMSDataSourceDelegateProxy
    : DelegateProxy<GMSAutocompleteTableDataSource, GMSAutocompleteTableDataSourceDelegate>
    , DelegateProxyType
, GMSAutocompleteTableDataSourceDelegate {

    public weak private(set) var dataSource: GMSAutocompleteTableDataSource?
    
    public init(dataSource: ParentObject) {
        self.dataSource = dataSource
        super.init(parentObject: dataSource, delegateProxy: RxGMSDataSourceDelegateProxy.self)
    }
    public static func registerKnownImplementations() {
        register { RxGMSDataSourceDelegateProxy(dataSource: $0) }
    }

    var placeBehaviorSubject = BehaviorSubject<GMSPlace?>(value: nil)

    public func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWith place: GMSPlace) {
        placeBehaviorSubject.on(.next(place))
    }
    
    public func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: Error) {
    }

    deinit {
        placeBehaviorSubject.on(.completed)
    }
}

extension Reactive where Base == GMSAutocompleteTableDataSource{
    
    public var delegate: DelegateProxy<GMSAutocompleteTableDataSource, GMSAutocompleteTableDataSourceDelegate> {
        return RxGMSDataSourceDelegateProxy.proxy(for: base)
    }
    
    var sourceText:Binder<String?> {
        return Binder(self.base) { (dataSource, text: String?) in
            dataSource.sourceTextHasChanged(text)
        }
    }
    
    public var didUpdateAutocompletePredictions: ControlEvent<Void> {
        let source = delegate.methodInvoked(
            #selector(GMSAutocompleteTableDataSourceDelegate.didUpdateAutocompletePredictions(for:))).map{_ in}
        return ControlEvent(events: source)
    }
    
    public var didAutocompletePlace: ControlEvent<GMSPlace?> {
        return ControlEvent(events: (delegate as! RxGMSDataSourceDelegateProxy).placeBehaviorSubject)
    }
    
}
