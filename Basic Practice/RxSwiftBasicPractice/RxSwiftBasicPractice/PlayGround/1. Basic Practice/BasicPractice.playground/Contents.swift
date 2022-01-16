import UIKit
import RxSwift
import RxCocoa

var disposeBag = DisposeBag()

Observable.just("RxSwift Test")
    .subscribe { str in
        print(str)
    }
    .disposed(by: disposeBag)


// showAlert 등 함수 구현 시 Observable.create 이용, 새로운 이벤트 생성
print("=====")
Observable<Int>.create { observer in
    observer.onNext(0)
    observer.onNext(1)
    observer.onCompleted()
    return Disposables.create()
}.subscribe { event in
    print(event) // next(0), next(1)이 나옴
    print(event.element)
}

// 이벤트 방출, just, from, of
// just는 1개, from은 배열을 받아 한개씩, of는 배열을 보내면 배열로 반환
// event는 한번에 한개씩만 emit
// OnCompleted, OnError는 emit이 아닌 notification

print("=====")
Observable<Int>.from([0, 1])
    .subscribe(onNext: { event in
        print(event) // 0, 1이 나옴
    })

// infallible(rxswift6, legacy의 경우는 rxswift5를 여전히 많이 사용하므로 주의)
// observable은 next, error, completed를 방출
// infallible은 next, completed를 방출, error는 방출하지 않음. 항상 성공만을 보장
// trait은 mainthread에서 돌아감을 보장, infallible은 그렇지는 않다는 차이가 존재

print("=====")
struct MyError: Error {
    var description: String
}

Infallible<String>.create { observer in
    observer(.next("Hello")) // next와 completed만 일어남을 보장함
    observer(.completed)
    
    //  아래와 같이는 불가능
    //  observer.onNext("Start")
    //  observer.onError(MyError(description: "Error 발생"))
    //  observer.onCompleted()
    
    return Disposables.create()
}.subscribe { str in
    print(str)
}

print("=====")

Observable<Int>
    .interval(.milliseconds(500), scheduler: MainScheduler.instance)
    .subscribe { value in
        print(value)
        
        if value == 5 {
            print("dispose reset")
            
            // 타이머를 통해 이벤트가 방출될 경우 이렇게 중단 가능, 단순히 of로 [1,2,3, .... 100] 보냈으면 중단 불가
            // 이 경우 onCompleted는 방출되지 않음.
            // disposeBag을 동일하게 써서 특정 이벤트가 일정기간 emit되지 않으면 실행되게도 가능
            
            disposeBag = DisposeBag()
        }
    } onError: { error in
        print(error.localizedDescription)
    } onCompleted: {
        print("completed")
    } onDisposed: {
        print("disposed!")
    }
    .disposed(by: disposeBag)

print("=====")
// RxCocoa에서 지원하는 relay
/// 1. PublishRelay   onNext 대신 accept를 사용
/// 2. BehavirRelay
/// 3. ReplayRelay  -> RxSwift 6에서 추가
/// only next 이벤트만 전달. dispose 되기 전까지 이벤트를 처리, UI 이벤트 위주로 사용.

let publishRelay = PublishRelay<Int>()

publishRelay.subscribe { event in
    print(event)
}.disposed(by: disposeBag)

publishRelay.accept(1) // onNext대신 accept
publishRelay.accept(2)

let behaviorRelay = BehaviorRelay<Int>(value: 1)

behaviorRelay.subscribe { event in
    print(event)
}

behaviorRelay.accept(2)
print(behaviorRelay.value) // 가장 마지막 이벤트를 조회하긴 read-only property

let replayRelay = ReplayRelay<Int>.create(bufferSize: 2)
(1...5).forEach { val in
    replayRelay.accept(val)
}

replayRelay.subscribe(onNext: {
    print($0) // 가장 최근 이벤트인 4, 5가 출력
})
