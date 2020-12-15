/* Copyright (c) 2011 Andrew Armstrong <phplasma at gmail dot com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "KQCBufferedNavigationController.h"

//#import "KQLoginViewController.h"

@implementation KQCBufferedNavigationController
@synthesize transitioning = _transitioning;
@synthesize stack = _stack;

- (void)dealloc {
    [self.stack removeAllObjects];
    self.stack = nil;
    [self setDelegate:nil];
}

- (id)init {
    self = [super init];
    if (self) {
        [self setDelegate:self];
        
        self.stack = [[NSMutableArray alloc] init];
        
//        [self setNavigationBarHidden:YES];
        
        /////////////////////* add by wjz  *//////////////////
//        KQLoginViewController* login = [[KQLoginViewController alloc] init];
//        [self pushViewController:login
//                        animated:YES];
        ///////////////////////////////////////////////////
    }
    
    return self;
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    @synchronized(self.stack) {
        if (self.transitioning) {
            void (^codeBlock)(void) = [^{
                [super popViewControllerAnimated:animated];
            } copy];
            
            [self.stack addObject:codeBlock];
            
            // We cannot show what viewcontroller is currently animated now
            return nil;
        } else {
            return [super popViewControllerAnimated:animated];
        }
    }
}

-(NSArray*)popToViewController:(UIViewController *)viewController
                      animated:(BOOL)animated{
    @synchronized(self.stack) {
        if (self.transitioning) {
            void (^codeBlock)(void) = [^{
                [super popToViewController:viewController
                                  animated:animated];
            } copy];
            
            [self.stack addObject:codeBlock];
            
            // We cannot show what viewcontroller is currently animated now
            return nil;
        } else {
            return [super popToViewController:viewController
                                     animated:animated];
        }
    }
}

-(NSArray*)popToRootViewControllerAnimated:(BOOL)animated{
    @synchronized(self.stack) {
        if (self.transitioning) {
            void (^codeBlock)(void) = [^{
                [super popToRootViewControllerAnimated:animated];
            } copy];
            
            [self.stack addObject:codeBlock];
            
            // We cannot show what viewcontroller is currently animated now
            return nil;
        } else {
            return [super popToRootViewControllerAnimated:animated];
        }
    }
}

- (void)setViewControllers:(NSArray *)viewControllers
                  animated:(BOOL)animated {
    @synchronized(self.stack) {
        if (self.transitioning) {
            // Copy block so its no longer on the (real software) stack
            void (^codeBlock)(void) = [^{
                [super setViewControllers:viewControllers
                                 animated:animated];
            } copy];
            
            // Add to the stack list and then release
            [self.stack addObject:codeBlock];
        } else {
            [super setViewControllers:viewControllers
                             animated:animated];
        }
    }
}

- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated {
    @synchronized(self.stack) {
        if (self.transitioning) {
            void (^codeBlock)(void) = [^{
                [super pushViewController:viewController
                                 animated:animated];
            } copy];
            
            [self.stack addObject:codeBlock];
        } else {
            [super pushViewController:viewController
                             animated:animated];
        }
    }
}

- (void) pushCodeBlock:(void (^)(void))codeBlock{
    @synchronized(self.stack) {
        [self.stack addObject:[codeBlock copy]];
        
        if (!self.transitioning)
            [self runNextBlock];
    }
}

- (void) runNextBlock {
    if (self.stack.count == 0)
        return;
    
    void (^codeBlock)(void) = [self.stack objectAtIndex:0];
    
    // Execute block, then remove it from the stack (which will dealloc)
    codeBlock();
    
    [self.stack removeObjectAtIndex:0];
}

#pragma mark -
#pragma mark UINavigationController delegate
- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    //DLog(@"willShowViewController:%@",viewController);
    
    @synchronized(self.stack) {
        self.transitioning = true;
    }
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    //DLog(@"didShowViewController:%@",viewController);
    
    @synchronized(self.stack) {
        self.transitioning = false;

        [self runNextBlock];
    }
}

#pragma mark -
#pragma mark AutorotateToInterfaceOrientation
/*
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return [self.topViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (BOOL)shouldAutorotate{
    return [self.topViewController shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations{
    return [self.topViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}
*/

#pragma mark--禁止横屏
-(BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}
@end
