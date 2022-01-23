import UIKit
import RxSwift
import RxCocoa

let disposeBag = DisposeBag()

struct MyError: Error {
    var description: String
}

var data = [1,2,3,4,5]
var pbSubject = PublishSubject<Int>()
// Transform, Combine Operators

print("---------------------")
// 1. toArray
pbSubject
    .toArray() // 종료되기 전까지 onNext가 와도 이벤트가 바로바로 방출되지 않음.
    .subscribe({ print($0)})
    .disposed(by: disposeBag)

pbSubject.onNext(1)
pbSubject.onNext(1)
pbSubject.onNext(2)
pbSubject.onCompleted()

// success([1, 1, 2])

print("---------------------")
// 2.
