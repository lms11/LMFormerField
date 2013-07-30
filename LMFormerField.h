//
//  LMFormerField.h
//  DailyBaby
//
//  Created by Lucas Moreira on 03/07/13.
//  Copyright (c) 2013 Lucas Moreira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef struct {
    NSInteger min;
    NSInteger max;
} BetweenLengths;

@interface LMFormerField : UITextField <UITextFieldDelegate>

@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSString *fieldIdentifier;
@property (nonatomic, strong) NSDictionary *validations;
@property (nonatomic, strong) NSArray *errors;
@property (nonatomic, strong) NSMutableDictionary *validatingCache; // Cache to avoid validate every single time
@property (nonatomic, weak) id <UITextFieldDelegate> formerDelegate;

- (NSString *)value;
- (BOOL)isValid;
- (NSString *)fieldError:(NSString *)key withSubtitute:(NSString *)error; // Helper with error description
- (void)performValidationChanges:(BOOL)isValid; // Change colors in UITextField (UI)


@end


/*
    I know that it shouldn't be here, but I don't like to put this with the code (get too polluted)
    Here's how to use validations's dictionary:

    # => VALIDATIONS (example)
 
    {
        presence: { message: "Blabla" }
        minlength: { message: "Blabla", value: @(3) },
        maxlength: { message: "Blabla", value: @(3) },
        in: { message: "Blabla", value: BetweenLengths(3, 6) },
        format: { message: "Blabla", value: "some_crazy_regex" }
    }
 */