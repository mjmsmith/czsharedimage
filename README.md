# CZSharedImage [unstable / in progress]

On iOS, the method ```UIImage#imageNamed:``` optimizes image loading in two ways:

1. It caches recently loaded UIImage objects to avoid reloading them.
2. Multiple requests for the same cached image get a reference to the same UIImage object.

The first optimization saves (loading) time at the cost of (memory) space.

For images that currently exist as UIImage objects in the running application, the second optimization saves both time and space;  there's no need to load or decode the image, and there aren't duplicate copies each occupying memory.

__CZSharedImage__ is a tiny library that provides the second optimization for images loaded using ```UIImage#imageWithContentsOfFile``` and ```UIImage#imageWithData```. 

## Usage

__CZSharedImage__ requires ARC and iOS 6.0.  (It uses the NSMapTable class introduced in 6.0.)

__CZSharedImage.h__ is the only header file that needs to be imported.

For usage examples, see [CZSharedImageTests.m](https://github.com/mjmsmith/gcdobjc/blob/master/GCDObjCTests/GCDObjCTests.m) or the [example app]().

In the example app, 100 instances of a 500x500 image (each occupying approximately 1MB of memory when decoded) are displayed on the screen.  The resident size of the app when using  ```UIImage#imageWithContentsOfFile:``` is 99MB more than when using ```CZSharedImage#imageWithContentsOfFile:```.

## CZSharedImage

Shared images are created using the __CZSharedImage__ class.

* creating images

```
+ (UIImage *)imageWithContentsOfFile:(NSString *)path;
+ (UIImage *)imageWithData:(NSData *)data;
+ (UIImage *)imageWithData:(NSData *)data scale:(CGFloat)scale;

```

Simply replace calls to the above three __UIImage__ methods with the __CZSharedImage__ methods of the same name.  If the associated __UIImage__ object already exists in the running app, the method will immediately return a reference to that object.  If not, it will be loaded as usual by the associated __UIImage__ initializer.

```
UIImage *image = [CZSharedImage imageWithContentsOfFile:@"/path/to/image/file"];
```

* adding images

```
+ (UIImage *)imageForPath:(NSString *)path;
+ (void)setImage:(UIIMage *)image forPath:(NSString *)path;
```

For cases where an image is loaded using some other mechanism than the three __imageWith...__ methods above (for instance, over the network), it can still be associated with a path:

```
NSString *path = @"http://example.com/foo.png";

// Try to get a reference to this image.

UIImage *image = [CZSharedImage imageForPath:path];

// If not available, fetch the image and tell CZSharedImage what its associated path is.
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
                         }];
}


```