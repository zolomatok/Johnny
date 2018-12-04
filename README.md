![Logo](/Johnny/johnny-logo.png?raw=true)

![platform](https://cdn.rawgit.com/zolomatok/Johnny/master/platform.svg)
![license](https://cdn.rawgit.com/zolomatok/Johnny/master/license.svg)

Johnny is a generic caching library written for Swift 4.

## Features
**Johnny can cache any model object that conforms to the `Cachable` protocol.**

- [x] Out-of-the-box support:
  - String, Bool, Int, UInt, Int64, UInt64, Float, Double
  - URL, Data, Date
  - UIImage, UIColor **by wrapping them in an Image or Color wrapper class respectively**
  - Arrays, Dictionaries and Sets of the above
- [x] Multiplatform, supporting iOS, macOS, tvOS & watchOS
- [x] First-level memory cache using `NSCache`
- [x] Second-level LRU disk cache
- [x] Disk access in background thread (always when saving, optionally when fetching)
- [x] Syncronous & Asynchronous API support
- [x] Automatic cache eviction on memory warnings & disk capacity reached
- [x] Unit tested
- [x] Concise, well-structured code to encourage contributions

Extra ❤️ for images:
- [x] `func setImageWithURL` extension on UIImageView, UIButton & NSImageView, optimized for cell reuse

## Usage

###Caching###
```swift
Johnny.cache(user, key: "LocalUser")

let imgage = UIImage(named: "awesomeness")
Johnny.cache(Image(image), key: "Image") // Caching a UIImage. UIColor objects must be wrapped in the Color wrapper class the same way.

// You can flag a value to be stored in the Library instead of the Caches folder if you don't want it to be automatically purged:
Johnny.cache(Date(), key: "FirstStart", library: true)
```

###Pulling###

```swift
// The type of the retrived value must be explicitly stated for the compiler.
let date: Date? = Johnny.pull("FirstStart")

// If you know you are retrieving a large object (> 1.5 MB) you can do it asynchronously
Johnny.pull("4KImage") { (image: Image?) in
    let img = image.uiImage()
}
```

###Removing###
```swift
Johnny.remove("LocalUser")
```


## Examples

###Collections ###

You can cache any collection of items conforming to the Storable protocol (most standard library data types already do)

```swift
let array: [String] = ["Folsom", "Prison", "Blues"]
let stringSet: Set<String> = ["I've", "been", "everywhere"]
// In case of dictionaries, the value must explicitly conform to Storable (so [String: AnyObject] does not work, while [String: Double] does)
let dictionary: [String: String] = ["first": "Solitary", "second": "man"]

Johnny.cache(array, key: "folsom")
Johnny.cache(stringSet, key: "everywhere")
Johnny.cache(dictionary, key: "solitary")
```

## Requirements
- iOS 8.0+
- macOS 10.10+
- tvOS 9.0+
- watchOS 2.0+
- Swift 4.0

## Install

**CocoaPods**

```
pod 'Johnny'
```

**Carthage**

```
github "zolomatok/Johnny"
```

**Manual**
- Clone the project
- Select the scheme (platform) and build
- Drag Johnny.framework to your project
- In the project settings under your target's General tab, scroll down and add Johhny to the ```Embedded Binaries``` section if it's not already added.


## Attribution
I'd like to thank the creators of [Pantry](https://github.com/nickoneill/Pantry) and [Haneke](https://github.com/Haneke/HanekeSwift) as those projects provided much of the inspiration and some code. Johnny was dreamed up to be the best of both worlds.

## License
Johnny is released under the MIT license. See LICENSE for details.
