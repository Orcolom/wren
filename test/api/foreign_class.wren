class ForeignClass {
  foreign static finalized
}

// Class with a default constructor.
foreign class Counter {
  construct new() {}
  foreign increment(amount)
  foreign value

  foreign instanceUserData
}

var counter = Counter.new()
System.print(counter.value) // expect: 0
counter.increment(3.1)
System.print(counter.value) // expect: 3.1
counter.increment(1.2)
System.print(counter.value) // expect: 4.3

// Foreign classes can inherit a class as long as it has no fields.
class PointBase {
  inherited() {
    System.print("inherited method")
  }
}

// Class with non-default constructor.
foreign class Point is PointBase {
  construct new() {
    System.print("default")
  }

  construct new(x, y, z) {
    System.print("%(x), %(y), %(z)")
  }

  foreign translate(x, y, z)
  foreign toString

  foreign instanceUserData
  foreign static finalizeResult
}

System.print(Point.finalizeResult)  // expect: 404
var p = Point.new(1, 2, 3) // expect: 1, 2, 3
System.print(p) // expect: (1, 2, 3)
p.translate(3, 4, 5)
System.print(p) // expect: (4, 6, 8)

p = null
System.gc()
System.print(Point.finalizeResult)  // expect: 100200

p = Point.new() // expect: default
System.print(p) // expect: (0, 0, 0)

p.inherited() // expect: inherited method

var error = Fiber.new {
  class Subclass is Point {}
}.try()
System.print(error) // expect: Class 'Subclass' cannot inherit from foreign class 'Point'.

// Class with a finalizer.
foreign class Resource {
  construct new() {}
}

var resources = [
  Resource.new(),
  Resource.new(),
  Resource.new()
]

System.gc()
System.print(ForeignClass.finalized) // expect: 0

resources.removeAt(-1)

System.gc()
System.print(ForeignClass.finalized) // expect: 1

resources.clear()

System.gc()
System.print(ForeignClass.finalized) // expect: 3

// Class that aborts fiber
foreign class BadClass {
  construct new() {}
}

error = Fiber.new {
  BadClass.new()
}.try()
System.print(error) // expect: Something went wrong

System.print(counter.instanceUserData) // expect: 12345
System.print(p.instanceUserData) // expect: 100200
