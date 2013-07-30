//
//  LMFormerField.m
//  DailyBaby
//
//  Created by Lucas Moreira on 03/07/13.
//  Copyright (c) 2013 Lucas Moreira. All rights reserved.
//

#import "LMFormerField.h"

#import <QuartzCore/QuartzCore.h>

@implementation LMFormerField
@synthesize label, fieldIdentifier, validations, errors, validatingCache, formerDelegate;

- (id)init
{   
    if (self = [super initWithFrame:CGRectMake(0, 5, IS_PHONE ? 170.0 : 350.0, 35)]) {
        self.textColor = [UIColor blackColor];
        self.borderStyle = UITextBorderStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.font = [UIFont systemFontOfSize:13.0];
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.text = @"";
        
        self.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
        self.leftViewMode = UITextFieldViewModeAlways;
        self.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
        self.leftViewMode = UITextFieldViewModeAlways;
        
        [self addTarget:self action:@selector(isValid) forControlEvents:UIControlEventEditingChanged];
        
    }
    return self;
}

- (NSString *)value
{
    return self.text;
}

- (BOOL)isCached:(NSString *)string
{
    return (self.validatingCache[string] != nil);
}

- (void)cache:(NSString *)string succeeded:(NSNumber *)succeeded withMessage:(NSArray *)newErrors
{
    [self.validatingCache setObject:@{ @"success": succeeded, @"errors": newErrors } forKey:string];
}

- (BOOL)isValid
{
    // Verifica se há validações a serem feita
    
    if (self.validations == nil || self.validations.allKeys.count == 0) {
        self.errors = nil;
        
        [self performValidationChanges:YES];
        
        return YES;
    }
    
    // NSLog(@"COMEÇANDO A VALIDAÇÃO");
    
    // Começa a validação
    
    BOOL valid = YES;
    
    if ([self isCached:self.text]) {
        
        // NSLog(@"CACHE DISPONIVEL");
        
        NSArray *newErrors = self.validatingCache[self.text][@"errors"];
        
        if (newErrors.count > 0)
            self.errors = [[NSArray alloc] initWithArray:newErrors];
        else
            self.errors = nil;
        
        valid = [self.validatingCache[self.text][@"success"] boolValue];
        
        // NSLog(@"CACHE UTILIZADO");
        
    } else {
        NSMutableArray *newErrors = [NSMutableArray array];
        
        // NSLog(@"VALIDANDO...");
        
        for (NSString *key in validations.allKeys) {
            
            if ([key.lowercaseString isEqualToString:@"presence"]) {
                // NSLog(@"VALIDANDO PRESENÇA");
                
                if (self.text == nil || [[self.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
                    valid = NO;
                    
                    NSString *error = [self fieldError:key withSubtitute:[NSString stringWithFormat:@"O campo \"%@\" não foi preenchido", self.fieldIdentifier.lowercaseString]];
                    [newErrors addObject:error];
                }
                
                
            } else if ([key.lowercaseString isEqualToString:@"minlenght"]) {
                // NSLog(@"VALIDANDO MENOR VALOR");
                
                NSNumber *value = self.validations[key][@"value"];
                
                if (value != nil) {
                    if (self.text != nil && ![self.text isEqualToString:@""] && self.text.length < [value integerValue]) {
                        valid = NO;
                        
                        NSString *error = [self fieldError:key withSubtitute:[NSString stringWithFormat:@"O campo \"%@\" é muito curto (mínimo de %d caracteres)", self.fieldIdentifier.lowercaseString, value.integerValue]];
                        [newErrors addObject:error];
                    }
                }
                
                
            } else if ([key.lowercaseString isEqualToString:@"maxlength"]) {
                // NSLog(@"VALIDANDO MAIOR VALOR");
                
                NSNumber *value = self.validations[key][@"value"];
                
                if (value != nil) {
                    if (self.text != nil && ![self.text isEqualToString:@""] && self.text.length > [value integerValue]) {
                        valid = NO;
                        
                        NSString *error = [self fieldError:key withSubtitute:[NSString stringWithFormat:@"O campo \"%@\" é muito longo (máximo de %d caracteres)", self.fieldIdentifier.lowercaseString, value.integerValue]];
                        [newErrors addObject:error];
                    }
                }
                
            } else if ([key.lowercaseString isEqualToString:@"in"]) { // Length should be IN A and B
                // NSLog(@"VALIDANDO VALOR ENTRE");
                
                if (self.validations[key][@"value"] != nil) {
                    BetweenLengths between_in;
                    [(NSValue *)self.validations[key][@"value"] getValue:&between_in];
                    
                    if (self.text != nil && ![self.text isEqualToString:@""] && (self.text.length < between_in.min || self.text.length > between_in.max)) {
                        valid = NO;
                        
                        if (self.text.length < between_in.min) {
                            NSString *error = [self fieldError:key withSubtitute:[NSString stringWithFormat:@"O campo \"%@\" é muito curto (mínimo de %d caracteres)", self.fieldIdentifier.lowercaseString, between_in.min]];
                            [newErrors addObject:error];
                            
                        } else if (self.text.length > between_in.max) {
                            NSString *error = [self fieldError:key withSubtitute:[NSString stringWithFormat:@"O campo \"%@\" é muito longo (máximo de %d caracteres)", self.fieldIdentifier.lowercaseString, between_in.max]];
                            [newErrors addObject:error];
                            
                        } else {
                            // Default
                            NSString *error = [self fieldError:key withSubtitute:[NSString stringWithFormat:@"O campo \"%@\" é inválido", self.fieldIdentifier.lowercaseString]];
                            [newErrors addObject:error];
                            
                        }
                    }
                }
                
                
            } else if ([key.lowercaseString isEqualToString:@"format"]) {
                // NSLog(@"VALIDANDO FORMATO");
                
                NSString *regExPattern = self.validations[key][@"value"];
                
                if (!(regExPattern == nil || [regExPattern isEqualToString:@""])) {
                    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
                    NSUInteger regExMatches = [regEx numberOfMatchesInString:self.text options:0 range:NSMakeRange(0, [self.text length])];
                    
                    if (regExMatches == 0) {
                        valid = NO;
                        
                        NSString *error = [self fieldError:key withSubtitute:[NSString stringWithFormat:@"O campo \"%@\" não está formatado corretamente", self.fieldIdentifier.lowercaseString]];
                        [newErrors addObject:error];
                    }
                }
                
            }
        }
        
        // NSLog(@"FINALIZANDO VALIDAÇÃO");
        
        if (newErrors.count > 0)
            self.errors = [[NSArray alloc] initWithArray:newErrors];
        else
            self.errors = nil;
        
        [self cache:self.text succeeded:@(valid) withMessage:newErrors];
        
    }
    
    // NSLog(@"CONCLUINDO...");
    
    [self performValidationChanges:valid];
    
    // NSLog(@"CONCLUIDO!");
    
    return valid;
}

- (NSString *)fieldError:(NSString *)key withSubtitute:(NSString *)error
{
    return (self.validations[key][@"message"] == nil) ? error : self.validations[key][@"message"];
}

- (void)performValidationChanges:(BOOL)isValid
{
    
    UIColor *color;
    
    if (isValid) {
        color = [UIColor colorWithRed:54.0/255.0 green:121.0/255.0 blue:52.0/255.0 alpha:1.0];
        
    } else {
        color = [UIColor colorWithRed:171.0/255.0 green:53.0/255.0 blue:54.0/255.0 alpha:1.0];
        
    }
    
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = 1;
    self.layer.cornerRadius = 3;
}

#pragma mark - Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // NSLog(@"INICIANDO DELEGATE shouldChangeCharactersInRange");
    
    if (self.validations == nil || self.validations.allKeys.count == 0) {
        // NSLog(@"NÃO HÁ VALIDAÇÕES");
        
        return YES;
    } else {
        // NSLog(@"HÁ VALIDAÇÕES");
        
        NSNumber *maxValue = @(-1);
        
        if (self.validations[@"maxlength"] != nil && self.validations[@"maxlength"][@"value"] != nil)
            maxValue = self.validations[@"maxlength"][@"value"];
        
        else if (self.validations[@"in"] != nil && self.validations[@"in"][@"value"] != nil) {
            BetweenLengths between_in;
            [(NSValue *)self.validations[@"in"][@"value"] getValue:&between_in];
            
            maxValue = @(between_in.max);
        }
        
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        
        // NSLog(@"VALORES: %@", @{ @"maxValue": maxValue, @"oldLength": @(oldLength), @"replacementLength": @(replacementLength), @"rangeLength": @(rangeLength), @"newLength": @(newLength) });
        
        return (maxValue.integerValue == -1) || (newLength <= maxValue.integerValue);
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // NSLog(@"INICIANDO DELEGATE textFieldDidBeginEditing");
    
    if (self.formerDelegate != nil && [self.formerDelegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [self.formerDelegate textFieldDidBeginEditing:self];
    }
}

@end