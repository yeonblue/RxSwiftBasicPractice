import UIKit
import RxSwift
import RxCocoa

let disposeBag = DisposeBag()

Observable.just("RxSwift Test")
    .subscribe { str in
        print(str)
    }
    .disposed(by: disposeBag)
