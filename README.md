# CZSharedImage

On iOS, the __UIImage__ method ```imageNamed:``` optimizes image loading in two ways:

1. It caches recently loaded UIImage objects to avoid reloading them.
2. Multiple requests for the same named image get a reference to the same UIImage object.

The first optimization saves (loading) time at the cost of (memory) space.

For images that currently exist as UIImage objects in the running application, the second optimization saves both time and space;  there's no need to load or decode the image, and there aren't duplicate copies each occupying memory.

__CZSharedImage__ is a tiny library that provides the second optimization for images loaded using ```UIImage#imageWithContentsOfFile:``` and ```UIImage#imageWithData:```.

Note that __CZSharedImage__ is not a cache; it simply tracks live UIImage objects.  Its value is in cases where an image is used multiple times in a view (accessory images in a table view, for instance), or multiple times in a navigation hierarchy.

## Usage

__CZSharedImage__ requires ARC and iOS 6.0.  (It uses the NSMapTable class introduced in 6.0.)

Import the header file __CZSharedImage.h__.

For usage examples, see [CZSharedImageTests.m](https://github.com/mjmsmith/czsharedimage/blob/master/CZSharedImageTests/CZSharedImageTests.m) or the [example app](https://github.com/mjmsmith/czsharedimage/tree/master/CZSharedImageExample).

In the example app, 100 instances of a 500x500 image (each occupying approximately 1MB of memory when decoded) are displayed on the screen.  The resident size of the app when using  ```UIImage#imageWithContentsOfFile:``` is 99MB more than when using ```CZSharedImage#imageWithContentsOfFile:```.

## CZSharedImage class

Shared images are created using the __CZSharedImage__ class.

### Creating images

```objc
+ (UIImage *)imageWithContentsOfFile:(NSString *)path;
+ (UIImage *)imageWithData:(NSData *)data;
+ (UIImage *)imageWithData:(NSData *)data scale:(CGFloat)scale;
```

Simply replace calls to the above three __UIImage__ methods with the __CZSharedImage__ methods of the same name.  If the associated __UIImage__ object already exists in the running app, the method will immediately return a reference to that object.  If not, it will be loaded as usual by the corresponding __UIImage__ initializer.

```objc
UIImage *image = [CZSharedImage imageWithContentsOfFile:@"/path/to/image/file"];
```

Note that in the case of images loaded using ```imageWithData:```, subsequent requests are matched using an MD5 hash of the data.  A more efficient mechanism is to manually associate the image with a chosen path; see the next section for details.

### Associating images with paths

```objc
+ (UIImage *)imageForPath:(NSString *)path;
+ (void)setImage:(UIImage *)image forPath:(NSString *)path;
```

For cases where an image is loaded using some mechanism other than the three __imageWith...__ methods (for instance, over the network), it can still be manually associated with a path such as the URL for subsequent requests:

```objc
// Try to get a reference to this image.

NSString *path = @"http://example.com/foo.png";
UIImage *image = [CZSharedImage imageForPath:path];

// If not available, fetch the image and associate it with the URL.
// (Error handling not shown.)

if (!image) {
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
  [NSURLConnection sendAsynchronousRequest:request
                                     queue:[NSOperationQueue mainQueue]
                         completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
                         {
                             // While the fetched UIImage object below remains alive,
                             // CZSharedImage#imageForPath: will return a reference to it.

                             UIImage *image = [UIImage imageWithData:data];
                             [CZSharedImage setImage:image forPath:path];
                             ...
                         }];
}
...
```

Similarly, an image fetched from a database could be associated with a unique path corresponding to the database row (and column if necessary):

```objc
// Try to get a reference to this image.

int personid = <...get row ID...>;
NSString *path = [NSString stringWithFormat:@"db:/person/%d", personid];
UIImage *image = [CZSharedImage imageForPath:path];

// If not available, fetch the image and associate it with the path.
// (Error handling not shown.)

if (!image) {
  NSData *data = <...load image data...>;
  
  // While the fetched UIImage object below remains alive,
  // CZSharedImage#imageForPath: will return a reference to it.
  
  UIImage *image = [UIImage imageWithData:data];
  [CZSharedImage setImage:image forPath:path];
}
...
```
