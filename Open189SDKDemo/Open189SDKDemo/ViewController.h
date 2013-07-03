//
//  ViewController.h
//  Open189SDKDemo
//
//  Created by user on 13-6-30.
//  Copyright (c) 2013年 jiangshiyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Open189Engine.h"


@interface ViewController : UIViewController <Open189EngineDelegate, UIAlertViewDelegate>{

    Open189Engine *openEngine;
    UITextView      *textView;
}

@property (nonatomic, retain) Open189Engine *openEngine;

@property (nonatomic, retain) UITextView   *textView;
@end
