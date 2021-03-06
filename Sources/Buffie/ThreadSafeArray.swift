import Foundation

internal class ThreadSafeArray<T>: Collection {
    
    var startIndex: Int = 0
    var endIndex: Int {
        return self.count
    }
    
    private var array: [T] = []
    private let q = DispatchQueue(label: "threadSafeArray.q",
                                  qos: .default,
                                  attributes: .concurrent,
                                  autoreleaseFrequency: .inherit,
                                  target: nil)
    
    internal func append(_ newElement: T) {
        q.async(flags: .barrier) { self.array.append(newElement) }
    }
    
    internal func append(contentsOf: [T]) {
        q.async(flags: .barrier) { self.array.append(contentsOf: contentsOf) }
    }
    
    internal func remove(at index: Int) {
        q.async(flags: .barrier) { self.array.remove(at: index) }
    }
    
    internal func removeFirst(n: Int) {
        q.async(flags: .barrier) { self.array.removeFirst(n) }
    }
    
    internal func removeLast() {
        q.async(flags: .barrier) { self.array.removeLast() }
    }
    
    internal func removeLast(n: Int) {
        q.async(flags: .barrier) { self.array.removeLast(n) }
    }
    
    internal var count: Int {
        var count = 0
        q.sync { count = self.array.count }
        return count
    }
    
    internal var first: T? {
        var element: T?
        q.sync { element = self.array.first }
        return element
    }
    
    internal func prefix(_ maxLength: Int) -> [T]? {
        var result: [T]?
        q.sync { result = Array(self.array.prefix(maxLength)) }
        return result
    }
    
    internal var last: T? {
        var element: T?
        q.sync { element = self.array.last }
        return element
    }
    
    func index(after i: Int) -> Int {
        var index: Int = 0
        q.sync { index = self.array.index(after: i) }
        return index
    }
        
    internal subscript(index: Int) -> T {
        set {
            q.async(flags: .barrier) { self.array[index] = newValue }
        }
        
        get {
            var element: T!
            q.sync { element = self.array[index] }
            return element
        }
    }
    
}
