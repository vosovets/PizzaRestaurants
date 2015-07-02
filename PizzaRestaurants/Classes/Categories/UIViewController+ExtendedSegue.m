//
//  UIViewController+ExtendedSegue.m
//
//  Created by Vadim Osovets on 9/2/14.
//  Copyright (c) 2014 Micro-B. All rights reserved.
//

// Categories
#import "UIViewController+ExtendedSegue.h"

// Other
#import <objc/objc-runtime.h>

@implementation UIViewController (ExtendedSegue)

#pragma mark - Public

- (void)performSegueWithIdentifier:(NSString *)segueIdentifier
                   prepareCallback:(PreparationBlock)preparationBlock {
    [self swizzlePrepareForSegueMethod];
    
    [self performSegueWithIdentifier:segueIdentifier
                              sender:preparationBlock];
}

#pragma mark - Runtime

- (void)swizzlePrepareForSegueMethod {
    Method swizzledMethod = class_getInstanceMethod([self class], @selector(swizzledPrepareForSegue:preparationBlock:));
    Method originalMethod = class_getInstanceMethod([self class], @selector(prepareForSegue:sender:));
    
    NSAssert(swizzledMethod, @"UIViewController+ExtendedSegue: Current category doesn't have swizzledPrepareForSegue:preparationBlock: method");
    NSAssert(originalMethod, @"UIViewController+ExtendedSegue: Caller doesn't have prepareForSegue:sender: method");

    method_exchangeImplementations(originalMethod, swizzledMethod);
}

#pragma mark - Private

- (void)swizzledPrepareForSegue:(UIStoryboardSegue *)segue
               preparationBlock:(PreparationBlock)preparationBlock {
    !preparationBlock ? : preparationBlock(segue.sourceViewController, segue.destinationViewController);
    
    [self swizzlePrepareForSegueMethod];
}

@end
