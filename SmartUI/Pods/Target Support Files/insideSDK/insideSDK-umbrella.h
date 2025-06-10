#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "InsideSDK.h"
#import "SDKTestVC.h"

FOUNDATION_EXPORT double insideSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char insideSDKVersionString[];

