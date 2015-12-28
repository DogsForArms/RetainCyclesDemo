//: Playground - noun: a place where people can play

//1
class Parent {
    var name: String
    var child: Child?
    init(name: String) {
        self.name = name
        
    }
    deinit {
        print("parent deinit")
    }
}
class Child {
    var name: String?
    var parent: Parent?
    init(name: String, parent: Parent) {
        self.name = name
        self.parent = parent
    }
    deinit {
        print("child deinit")
    }
}
var bigBob:Parent? = Parent(name: "Big Bob")
var littleBob:Child? = Child(name: "Little Bob", parent: bigBob!)

//### In demo i forgot to link them together, the line bellow was not in code
bigBob!.child = littleBob

bigBob = nil
littleBob = nil



//2
class RetainCycle {
    var closure: (() -> Void)!
    var string = "Hello"
    
    init() {
        closure = {
            //            [unowned self] in //fixes
            self.string = "a thing"
            
        }
    }
    
    deinit {
        print("deinit retainCycle")
    }
}

//Initialize the class and activate the retain cycle.
var retainCycleInstance:RetainCycle? = RetainCycle()
retainCycleInstance!.closure()
retainCycleInstance = nil


// real life case, in app
//3
class Cell {
    var cancelReservationBlock: (() -> ())?
    deinit {
        print("deinit cell")
    }
}


class SimilarTableViewController {
    
    var somePropertyUsedByCancelReservation: Any?
    //0. no way to say weak self in a function
    func cancelReservationRetainCycle(){
        //implicit use of self in this function, becomes a problem when cell owns it
        somePropertyUsedByCancelReservation = "Lol wahtever"
    }
    
    //    //1. use a lazy var block, which is able to use [weak self] capture list, unlike functions
    lazy var cancelReservationNoRetainCycle: (() -> ()) = {
        [weak self] in
        self?.somePropertyUsedByCancelReservation = "Lol wahtever"
    }
    
    //    //2. lincoln's idea.
    func getCancelReservationBlockNoRetainCycle() -> (() -> ())
    {
        weak var weakSelf = self
        let closure: () -> () = {
            guard let strongSelf = weakSelf else { return; }
            strongSelf.somePropertyUsedByCancelReservation = "thing"
        }
        
        return closure
    }
    
    var someTableViewCell:Cell
    
    init(){
        someTableViewCell = Cell()
        someTableViewCell.cancelReservationBlock = getCancelReservationBlockNoRetainCycle()
    }
    
    deinit {
        print("deinit SimilarTableViewController")
    }
}
var stvc:SimilarTableViewController? = SimilarTableViewController()
stvc = nil




//differences between funcs and blocks
class CrazyIdea
{
    var ownMyselfBlock:(() -> ())?
    
    func ownMyselfFunction()
    {
        self.ownMyselfFunction()
    }
    deinit
    {
        print("CrazyIdea deinit")
    }
}
var crazyIdea:CrazyIdea? = CrazyIdea()
crazyIdea!.ownMyselfBlock = crazyIdea!.ownMyselfFunction
crazyIdea = nil




// http://kelan.io/2015/the-weak-strong-dance-in-swift/
// extension of withExtendedLifetime to avoid having to deal with a weak self.
/*
extension Optional
{
    func withExtendedLifetime(body: T -> Void)
    {
        if let strongSelf = self
        {
            body(strongSelf)
        }
    }
}
*/


// SETTERS and GETTERS are exceptions
class A
{
    func doSomething(){}
    
    private var methodPropertyValue:Int = 5
    var methodProperty:Int
        {
        get {
            self.doSomething()
            return methodPropertyValue
        }
        set {
            self.doSomething()
            methodPropertyValue = newValue
        }
    }
    
    deinit {
        print("A deinit called")
    }
}

var a:A? = A()
a!.methodProperty = 10
//a = nil // uncomment this to show "A deinit called"







