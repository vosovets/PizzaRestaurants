//
//  UIViewController+ExtendedSegue.h
//
//  Created by Vadim Osovets on 9/2/14.
//  Copyright (c) 2014 Micro-B. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PreparationBlock) (id sourceController, id destinationController);

/** 
 *  Category to extend segues functionality.
 *  It allows to get rid of nasty if-else constructs in each controller in prepareForSegue:sender:
 *  prepareForSegue:sender: won't be called if you use that category method. 
 *  Usual usage of 
 */
@interface UIViewController (ExtendedSegue)

/** Gives ability to setup data for destination controller via block-based style and performs segue. */
- (void)performSegueWithIdentifier:(NSString *)segueIdentifier
                   prepareCallback:(PreparationBlock)preparationBlock;

@end
