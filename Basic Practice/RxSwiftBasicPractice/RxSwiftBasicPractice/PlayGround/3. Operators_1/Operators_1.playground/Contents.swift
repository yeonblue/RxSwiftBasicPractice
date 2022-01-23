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
let data = [1,2,3,4,5]

print("---------------------")
// 1. ignoreElements - completed와 error만을 반환
Observable<Int>
    .from(data)
    .ignoreElements()
    .subscribe { event in
        print(event)
    }
    .disposed(by: disposeBag)
print("---------------------")
// 2. elementAt - 특정 index만 emit하고 completed
Observable<Int>
    .from(data)
    .elementAt(2)
    .subscribe({
        print($0)
    })
    .disposed(by: disposeBag)

// next(3)
// completed

print("---------------------")
// 3. filter - 조건문에 맞는 것만 값을 emit
Observable<Int>
    .from(data)
    .filter { value in
        return value % 2 == 0
    }
    .subscribe({
        print($0)
    })
    .disposed(by: disposeBag)

// next(2)
// next(4)
// completed

print("---------------------")
// 4. skip - 지정한 개수만큼 무시하고 그 다음 것부터 emit, 이 경우는 2므로 1,2는 스킵되고 3,4,5만 emit
Observable<Int>
    .from(data)
    .skip(2)
    .subscribe({
        print($0)
    })
    .disposed(by: disposeBag)

print("---------------------")
// 5. skip - until : 다른 Observable을 받음(트리거)
var trigger = PublishSubject<Int>()
var numPublishSubject = PublishSubject<Int>()

numPublishSubject
    .skip(until: trigger)
    .subscribe({
        print($0)
    })
    .disposed(by: disposeBag)

numPublishSubject.onNext(1) // 아직 trigger가 emit안했으므로 무시
trigger.onNext(99) // 무슨 값을 emit해도 상관없음

numPublishSubject.onNext(2)
numPublishSubject.onNext(3)

// next(2)
// next(3)

print("---------------------")
// 6. skit - while
Observable<Int>
    .from(data)
    .skipWhile { value in
        return value < 3 // 트루가 될 때까지 계속 skip, false가 되면 emit시작
    }
    .subscribe({
        print($0)
    })
    .disposed(by: disposeBag)

// next(3)
// next(4)
// next(5)
// completed

print("---------------------")
// 7. skip - duration
Observable<Int>
    .interval(.milliseconds(100), scheduler: MainScheduler.instance)
    .take(20)
    .skip(.milliseconds(1000), scheduler: MainScheduler.instance)
    .subscribe({
        print("skip - duration: ", $0)
    })
    .disposed(by: disposeBag)

// skip - duration:  next(9)
// skip - duration:  next(10)
// skip - duration:  next(11)
// skip - duration:  next(12)
// skip - duration:  next(13)
// skip - duration:  next(14)
// skip - duration:  next(15)
// skip - duration:  next(16)
// skip - duration:  next(17)
// skip - duration:  next(18)
// skip - duration:  next(19)
// skip - duration:  completed

// 일정 기간동안 skip을 하는 연산자
// 시간이 약간의 오차는 발생할 수 있음, 코드상으로만 보면 10부터 방출되어야 하나 약간의 시간 차이가 발생

print("---------------------")
// 8. take: skip과 반대
Observable<Int>
    .from(data)
    .take(3)
    .subscribe({
        print($0)
    })
    .disposed(by: disposeBag)

// next(1)
// next(2)
// next(3)
// completed

print("---------------------")
// 9. take - while

Observable<Int>
    .from(data)
    .take(while: { $0 < 3 }, behavior: .exclusive)
        // exclusive가 기본값, inclusive는 조건이 마지막에서 false여도 방출
    .subscribe({
        print($0)
    })
    .disposed(by: disposeBag)

// next(1)
// next(2)
// completed

print("---------------------")
// 10. take - until: trigger가 오기 전까지 받고, 이후는 무시
trigger = PublishSubject<Int>()
numPublishSubject = PublishSubject<Int>()

numPublishSubject
    .take(until: trigger)
    .subscribe({ print("take - until1: ", $0)})
    .disposed(by: disposeBag)

numPublishSubject.onNext(1)
trigger.onNext(1)
numPublishSubject.onNext(2)
numPublishSubject.onNext(3)

// take - until1:  next(1)
// take - until1:  completed

trigger = PublishSubject<Int>()
numPublishSubject = PublishSubject<Int>()

numPublishSubject
    .take(until: {
        return $0 > 3 // false가 되는 동안 emit, true가 되면 completed를 내보냄
    })
    .subscribe({ print("take until2:", $0)})
    .disposed(by: disposeBag)

numPublishSubject.onNext(1)
numPublishSubject.onNext(2)
numPublishSubject.onNext(3)
numPublishSubject.onNext(4)

// take until2: next(1)
// take until2: next(2)
// take until2: next(3)
// take until2: completed

print("---------------------")
// 11. takeLast
// onCompleted되기 전까지 emit을 defer 해놓음
// onCompleted가 불리면 그 때 마지막 3개를 emit
// onError가 불렸으면 버퍼에 있던 값은 무시하고 error만 방출

numPublishSubject = PublishSubject<Int>()
numPublishSubject
    .takeLast(3)
    .subscribe({ print($0)})
    .disposed(by: disposeBag)

numPublishSubject.onNext(1)
numPublishSubject.onNext(2)
numPublishSubject.onNext(3)
numPublishSubject.onNext(4)
numPublishSubject.onNext(5)
numPublishSubject.onCompleted()

// next(3)
// next(4)
// next(5)
// completed

print("---------------------")
// 12. take - for
Observable<Int>
    .interval(.seconds(1), scheduler: MainScheduler.instance)
    .take(for: .seconds(3), scheduler: MainScheduler.instance)
    .subscribe( { print("take for:", $0) })
    .disposed(by: disposeBag)

// take for: next(0)
// take for: next(1)
// take for: completed

print("---------------------")
// 13. single: 한개만 emit
Observable
    .just(1)
    .asSingle()
    .subscribe({print("single:", $0)})
    .disposed(by: disposeBag)

// single: success(1) - 한개일때는 정상적으로 success 방출

Observable
    .from([1,2])
    .asSingle()
    .subscribe({print("single:", $0)})
    .disposed(by: disposeBag)

// single: failure(Sequence contains more than one element.)

let p = PublishSubject<Int>()

p.asSingle()
    .subscribe({print($0)})
    .disposed(by: disposeBag)

p.onNext(1) // 이 때 바로 success가 되는 것은 아님, 이후 또 방출 될수 있으므로
p.onCompleted() // onCompleted가 호출되야 여러개가 방출되지 않았음을 보장할 수 있으므로 이 때 방출됨

print("---------------------")
// 14. distinctUntilChanged
let numArr2 = [1,1,2,2,2,3,3,3,3,4,5,1,2,3]
Observable<Int>
    .from(numArr2)
    .distinctUntilChanged()
    .subscribe({print("distinctUntilChanged:", $0)})
    .disposed(by: disposeBag)

// distinctUntilChanged: next(1)
// distinctUntilChanged: next(2)
// distinctUntilChanged: next(3)
// distinctUntilChanged: next(4)
// distinctUntilChanged: next(5)
// distinctUntilChanged: next(1)
// distinctUntilChanged: next(2) 이전에 emit됬는지 여부는 따지지 않음.
// distinctUntilChanged: next(3) 직전값이 연속인지만 확인, 검색값 같은 것이 동일한게 연속 보내지지 않게 하면 좋을 것 같음.
// distinctUntilChanged: completed

let numArr3 = [1,2,4,5,7,8,9,10,12,14,15,16,18]
Observable<Int>
    .from(numArr3)
    .distinctUntilChanged { val1, val2 in // 두 개 값을 받아 직접 조건을 줄 수 있음
        return val1 % 2 == val2 % 2 // return 값이 true일 경우 같은 값으로 보고 skip
    }
    .subscribe({ print("distinctUntilChanged 홀수 연속 불가:", $0)})
    .disposed(by: disposeBag)

// distinctUntilChanged 홀수 연속 불가: next(1)
// distinctUntilChanged 홀수 연속 불가: next(2)
// distinctUntilChanged 홀수 연속 불가: next(5)
// distinctUntilChanged 홀수 연속 불가: next(8)
// distinctUntilChanged 홀수 연속 불가: next(9)
// distinctUntilChanged 홀수 연속 불가: next(10)
// distinctUntilChanged 홀수 연속 불가: next(15)
// distinctUntilChanged 홀수 연속 불가: next(16)
// distinctUntilChanged 홀수 연속 불가: completed

let tupleArr = [(1,1), (1,2), (1,3)]
Observable
    .from(tupleArr)
    .distinctUntilChanged({$0.0}) // 튜플의 첫번째 인자만을 가지고 구분, 이경우는 다 1이니 맨 앞에 한개만 emit
    .subscribe({print($0)})
    .disposed(by: disposeBag)

print("---------------------")
// 15. debounce - 지정한 기간 동안 가장 최신의 데이터를 방출, 그 사이에 새로운 이벤트가 오면 타이머를 초기화
// 검색창 같은 것을 구현할 때 사용하면 적합할 것으로 보임(지정한 기간 이벤트가 발생하지 않으면 최신의 데이터를 방출)

// 16. throttle: 지정한 주기동안 값을 1개씩만 전달(debounce와 달리 지정한 주기마다 이벤트가 있으면 반드시 1개를 방출)
// 버튼 이벤트 클릭에 처리에 적합

