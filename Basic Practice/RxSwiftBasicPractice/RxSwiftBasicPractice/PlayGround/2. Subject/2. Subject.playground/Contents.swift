import UIKit
import RxSwift
import RxCocoa

// Subject
// Observable이면서 Observer
/// 1. PublishSubject - 초기값 X
/// 2. BehaviorSubject - 초기값 O
/// 3. ReplaySubject - 버퍼를 두고 전달, 너무 키우면 안됨
/// 4. AsyncSubject - onCompleted 시점에 마지막 onNext 전달
///
///  Relay - onNext만 받고 error, completed를 받지는 않음
///  이는 UI 관련 이벤트 처리에 유리, UI 관련 이벤트가 종료가 발생하면 안됨

let disposeBag = DisposeBag()

struct MyError: Error {
    var description: String
}

// 1. PublishSubject - 초기값이 X
let publishSubject = PublishSubject<String>()
publishSubject.onNext("1. First")

let p_ob1 = publishSubject
    .subscribe { event in
        print("p_ob1", event)
    }

publishSubject.onNext("2. Second")

let p_ob2 = publishSubject
    .subscribe { event in
        print("p_ob2", event)
    }

publishSubject.onNext("3. Third")
publishSubject.onCompleted()

// Result
//p_ob1 next(2. Second) 구독 이후에 emit된 값만 받을 수 있음
//p_ob1 next(3. Third)
//p_ob2 next(3. Third)
//p_ob1 completed
//p_ob2 completed
//===========

print("===========")
// 2. BehaviorSubject - 생성할 때 초기값을 지정
let behaviorSubject = BehaviorSubject<String>(value: "Init String")

let b_ob1 = behaviorSubject
    .subscribe { event in
        print("b_ob1", event)
    }

behaviorSubject.onNext("1. First")

let b_ob2 = behaviorSubject
    .subscribe { event in
        print("b_ob2", event)
    }

behaviorSubject.onNext("2. Second")
behaviorSubject.onCompleted()

// onCompleted이후 구독될 경우 해당 값은 의미가 없음.

// result
// b_ob1 next(Init String)
// b_ob1 next(1. First)
// b_ob2 next(1. First)
// b_ob1 next(2. Second)
// b_ob2 next(2. Second)
// b_ob1 completed
// b_ob2 completed

print("===========")
// 3. ReplaySubject - 버퍼를 두고 이벤트를 보낼 수 있음, 생성할 때 create를 사용, 버퍼크기만큼 최신이벤트를 가질 수 있음.

let replaySubject = ReplaySubject<Int>.create(bufferSize: 2)

(1...5).forEach { val in
    replaySubject.onNext(val)
}

replaySubject.subscribe { val in
    print(val)
}.disposed(by: disposeBag)

replaySubject.onCompleted()

// 버퍼가 2므로 마지막 4, 5 가 emit
// next(4)
// next(5)

print("===========")
// 4. AsyncSubject - 위의 3개는 즉시 전달했으나, completed 이벤트가 전달될 경우 그 직전 event를 emit

let asyncSubject = AsyncSubject<Int>()
asyncSubject
    .subscribe { event in
        print(event)
    }.disposed(by: disposeBag)

asyncSubject.onNext(1)
asyncSubject.onNext(2)
asyncSubject.onNext(3)
asyncSubject.onCompleted()
 
 // completed 직전 이벤트인 3만 emit, error인 경우는 error만 전달되고 종료
 // next(3)
 // completed
