import UIKit
import RxSwift
import RxCocoa

let disposeBag = DisposeBag()

struct MyError: Error {
    var description: String
}

print("---------------------")
// 1. Create Operators
Observable
    .just([1,2])
    .subscribe { event in
        print(event)
    }.disposed(by: disposeBag)

print("---------------------")
Observable
    .of([1,2]) // 베열을 그대로 emit
    .subscribe { event in
        print(event)
    }.disposed(by: disposeBag)

print("---------------------")
Observable
    .of(1,2)
    .subscribe { event in
        print(event)
    }.disposed(by: disposeBag)

print("---------------------")
Observable
    .from([1,2])
    .subscribe { event in
        print(event)
    }.disposed(by: disposeBag)

// ---------------------
// next([1, 2])
// completed
// ---------------------
// next([1, 2])
// completed
// ---------------------
// next(1)
// next(2)
// completed
// ---------------------
// next(1)
// next(2)
// completed

print("---------------------")

// 2. range, generate
Observable
    .range(start: 1,
           count: 5,
           scheduler: MainScheduler.instance) // 정수값을 순서대로 방출, 증가하는 수만 가능
    .subscribe { val in
        print(val)
    }.disposed(by: disposeBag)

// next(1)
// next(2)
// next(3)
// next(4)
// next(5)
// completed

print("---------------------")
Observable
    .generate(initialState: 5, // 초기값은 정수가 아니어도 상관없음
              condition: { $0 < 10}, // false가 되면 바로 onCompleted
              iterate: { $0 + 1 }    // 리턴할 값, reduce와 비슷
    ).subscribe(onNext: {
        print($0)
    }).disposed(by: disposeBag)

// 5부터 9가 출력

print("---------------------")
// 3. repeatElement - 반복적으로 방출, 개수 제한이 필요.

Observable
    .repeatElement("Emit")
    .take(2)
    .subscribe({ print($0) })
    .disposed(by: disposeBag)

// next(Emit)
// next(Emit)
// completed

print("---------------------")

// 4. deferred

let odd = [1,3,5]
let even = [2,4,6]
var flag = false

let defered: Observable<Int> = Observable
    .deferred {
        flag.toggle()
        
        if flag {
            return Observable.from(even)
        } else {
            return Observable.from(odd)
        }
    }

defered
    .subscribe({ print($0) })
    .disposed(by: disposeBag)

defered
    .subscribe({ print($0) })
    .disposed(by: disposeBag)

defered
    .subscribe({ print($0) })
    .disposed(by: disposeBag)

// next(2)    defered에 의해 flag에 따라 emit되는 data가 바뀜
// next(4)
// next(6)
// completed
// next(1)
// next(3)
// next(5)
// completed
// next(2)
// next(4)
// next(6)
// completed

print("---------------------")

// 5. create
Observable<String>.create { observer in
        
        guard let url = URL(string: "https://google.com") else {
            observer.onError(MyError(description: "BadURL"))
            return Disposables.create()
        }
        
        guard let data = try? String(contentsOf: url, encoding: .utf8) else {
            observer.onError(MyError(description: "Encoding Error"))
            return Disposables.create()
        }
        observer.onNext(data)
        observer.onCompleted()
        return Disposables.create()
    }
    .subscribe({ print($0) })
    .disposed(by: disposeBag)

print("---------------------")

// 6. empty, error

Observable<Void>
    .empty()
    .subscribe({
        print($0)
    }).disposed(by: disposeBag)

// onCompleted만 호출되고 종료, 옵저버가 별도 작업없이 종료될 경우 보통 사용

Observable<Void>
    .error(MyError(description: "Error"))
    .subscribe({ print($0) })
    .disposed(by: disposeBag)


// Filtering Operators


