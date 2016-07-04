![Alt text](/Johnny/johnny-logo.png?raw=true)
Johnny is a caching library written in Swift.

## Features
- [x] Multiplatform, supporting iOS, macOS, tvOS & watchOS
- [x] First-level memory cache using `NSCache`
- [x] Second-level LRU disk cache
- [x] Generic cache with out-of-the-box support for
  - Int, UInt, Int64, UInt64, Float, Double, String (+ Date, Data & URL in the `swift3 branch`)
  - NSData, NSDate
  - UIImage, UIColor
  - **Any** type that conforms to the `Storable` protocol
  - Arrays, Dictionaries or Sets of the above
- [x] Disk access in background thread (always when saving, optionally when fetching)
- [x] Syncronous & Asynchronous API support
- [x] Automatic cache eviction on memory warnings & disk capacity reached

Extra ❤️ for images:
- [x] `func setImageWithURL` extension on UIImageView, UIButton & NSImageView, optimized for cell reuse

## Usage

**Caching**
```swift
Johnny.cache(NSDate(), key: "FirstStart")

Johnny.cache(people, key: "People") 
// Where a 'people' consist of a type that conforms to Storable
```

*Note, that Johnny is not a queryable database. For that, use [Realm](https://github.com/realm/realm-cocoa) or CoreData*

**Retriving**

The type of the retrived value must be explicitly stated for the compiler.

```swift
let date: NSDate? = Johnny.pull("FirstStart")

// or if you know that you are retriving a large object (> 1.5 MB):

Johnny.pull("4KImage") { (value: UIImage?) in
    // 
}
```

## Requirements
- iOS 8.0+
- macOS 10.10+
- tvOS 9.0+
- watchOS 2.0+
- Swift 2.0 (there's also a swift3 branch)

## Install
### Cocoapods
`pod 'Johnny'`

## Attribution
I'd like to thank the creators of [Pantry](https://github.com/nickoneill/Pantry) and [Haneke](https://github.com/Haneke/HanekeSwift) as those projects provided much of the inspiration and some code. Johnny was dreamed up to be the best of both worlds.

## License
Johnny is released under the MIT license. See LICENSE for details.
