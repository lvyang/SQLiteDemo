//
//  StringUtil.m
//  WuHan_GJJ
//
//  Created by Yang.Lv on 16/1/26.
//  Copyright © 2016年 chinda021. All rights reserved.
//

#import "BSStringUtil.h"
#import <CommonCrypto/CommonDigest.h>

@implementation BSStringUtil

+ (BOOL)isValidateNumberString:(NSString *)text
{
    NSString *formatter = @"^([+-]?)(?:|0|[1-9]\\d*)(?:\\.\\d*)?$";

    return [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", formatter] evaluateWithObject:text];
}

+ (BOOL)isDigitOnly:(NSString *)str
{
    NSCharacterSet *notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];

    return [str rangeOfCharacterFromSet:notDigits].location == NSNotFound;
}

+ (BOOL)isValidateIntegerString:(NSString *)string
{
    NSScanner   *scan = [NSScanner scannerWithString:string];
    int         val = 0;

    return [scan scanInt:&val] && [scan isAtEnd];
}

+ (BOOL)isValidateFloatString:(NSString *)string
{
    NSScanner   *scan = [NSScanner scannerWithString:string];
    float       val = 0.0f;

    return [scan scanFloat:&val] && [scan isAtEnd];
}

+ (BOOL)isValidateEmail:(NSString *)email
{
    NSString    *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];

    return [emailTest evaluateWithObject:email];
}

+ (BOOL)isValidateUrl:(NSString *)url
{
    if ([url isKindOfClass:[NSURL class]]) {
        url = [(NSURL *)url absoluteString];
    }

    if (![url isKindOfClass:[NSString class]]) {
        return NO;
    }

    NSString    *regex = @"^(http://|https://)?((?:[A-Za-z0-9]+-[A-Za-z0-9]+|[A-Za-z0-9]+)\\.)+([A-Za-z]+)[/\?\\:]?.*$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];

    return [predicate evaluateWithObject:url];
}

+ (BOOL)isValidateImageUrl:(NSString *)url
{
    BOOL validate = [self isValidateUrl:url];

    if (!validate) {
        return NO;
    }

    if ([url hasSuffix:@"/"]) {
        return NO;
    }

    return YES;
}

+ (NSString *)md5String:(NSString *)str
{
    const char      *cStr = [str UTF8String];
    unsigned char   result[16];

    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
           result[0], result[1], result[2], result[3],
           result[4], result[5], result[6], result[7],
           result[8], result[9], result[10], result[11],
           result[12], result[13], result[14], result[15]];
}

+ (NSString *)encriptPhoneNumber:(NSString *)phoneNumber
{
    if (![phoneNumber isKindOfClass:[NSString class]] || (phoneNumber.length != 11)) {
        return phoneNumber;
    }

    NSRange range = NSMakeRange(3, 4);
    return [phoneNumber.mutableCopy stringByReplacingCharactersInRange:range withString:@"****"];
}

+ (NSString *)encriptEmail:(NSString *)sourceEmail
{
    if (![self isValidateEmail:sourceEmail]) {
        return sourceEmail;
    }

    NSMutableArray  *components = [sourceEmail componentsSeparatedByString:@"@"].mutableCopy;
    NSString        *identifier = components.firstObject;

    if (identifier.length <= 3) {
        return sourceEmail;
    }

    NSString *encriptStr = [NSString stringWithFormat:@"%@***", [identifier substringWithRange:NSMakeRange(0, 3)]];
    [components replaceObjectAtIndex:0 withObject:encriptStr];
    return [components componentsJoinedByString:@"@"];
}

+ (NSAttributedString *)stringByHighlightSubString:(NSString *)subString withDefaultAttribute:(NSDictionary *)defaultAttribute sourceString:(NSString *)str withAttribute:(NSDictionary *)attributs
{
    if (subString.length == 0) {
        return [[NSAttributedString alloc] initWithString:str attributes:defaultAttribute];
    }

    NSRange range = [str rangeOfString:subString options:NSCaseInsensitiveSearch];

    if (range.location == NSNotFound) {
        return [[NSAttributedString alloc] initWithString:str attributes:defaultAttribute];
    }

    NSUInteger                  maxRange = NSMaxRange(range);
    NSString                    *string1 = [str substringToIndex:maxRange];
    NSMutableAttributedString   *attributeString = [[NSMutableAttributedString alloc] initWithString:string1 attributes:defaultAttribute];
    [attributeString addAttributes:attributs range:range];

    [attributeString appendAttributedString:[self stringByHighlightSubString:subString withDefaultAttribute:defaultAttribute sourceString:[str substringFromIndex:maxRange] withAttribute:attributs]];

    return attributeString;
}

+ (NSString *)stringByTrimmingTrailZero:(NSString *)originalString
{
    if ((originalString.length == 0) || ([originalString rangeOfString:@"."].location == NSNotFound)) {
        return originalString;
    }

    if (([originalString characterAtIndex:originalString.length - 1] == '0')
        || ([originalString characterAtIndex:originalString.length - 1] == '.')) {
        NSString *newString = [originalString.mutableCopy substringToIndex:originalString.length - 2];
        return [BSStringUtil stringByTrimmingTrailZero:newString];
    }

    return originalString;
}

+ (CGSize)sizeForString:(NSString *)string font:(UIFont *)font limitWidth:(CGFloat)width
{
    CGFloat             lineHeight = font.lineHeight;
    CGSize              constrainSize = CGSizeZero;
    NSMutableDictionary *attribute = [NSMutableDictionary dictionary];

    if (fabs(width) < FLT_EPSILON) { // 传0的话认为不限制宽度
        constrainSize = CGSizeMake(INT_MAX, lineHeight);
    } else {
        constrainSize = CGSizeMake(width, INT_MAX);
    }

    if (font) {
        [attribute setObject:font forKey:NSFontAttributeName];
    }

    CGSize size = [string boundingRectWithSize:constrainSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
    return size;
}

+ (NSString *)stringByRemoveHtmlTag:(NSString *)str
{
    if (!str) {
        return nil;
    }

    NSError             *error = nil;
    NSMutableString     *string = [str mutableCopy];
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"<[^>]*(>*)" options:0 error:&error];

    if (expression) {
        NSArray *result = [expression matchesInString:str options:0 range:NSMakeRange(0, [str length])];

        for (int i = 0; i < result.count; i++) {
            NSTextCheckingResult    *textCheckingResult = result[result.count - i - 1];
            NSRange                 range = [textCheckingResult rangeAtIndex:0];
            [string replaceCharactersInRange:range withString:@""];
        }
    }

    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSURL *)originalImageUrlFromThumnailUrlString:(NSString *)thumnailString
{
    if (!thumnailString.length) {
        return nil;
    }

    NSError             *error = nil;
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"/resize/\\d+x\\d+/" options:0 error:&error];

    if (expression) {
        NSArray *result = [expression matchesInString:thumnailString options:0 range:NSMakeRange(0, [thumnailString length])];

        if (!result.count) {
            return [NSURL URLWithString:thumnailString];
        }

        NSMutableString *string = thumnailString.mutableCopy;

        for (int i = 0; i < result.count; i++) {
            NSTextCheckingResult    *textCheckingResult = result[result.count - i - 1];
            NSRange                 range = [textCheckingResult rangeAtIndex:0];
            [string replaceCharactersInRange:NSMakeRange(range.location, range.length - 1) withString:@""];
        }

        return [NSURL URLWithString:string];
    }

    return [NSURL URLWithString:thumnailString];
}

+ (CGSize)imageSizeFromImageUrl:(NSString *)urlString
{
    CGSize              defaultImageSize = CGSizeZero;
    NSError             *error = nil;
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"/\\d+x\\d+/" options:0 error:&error];

    if (expression) {
        NSArray *result = [expression matchesInString:urlString options:0 range:NSMakeRange(0, [urlString length])];

        if (result.count == 0) {
            return defaultImageSize;
        }

        NSTextCheckingResult    *textCheckingResult = result.firstObject;
        NSRange                 range = [textCheckingResult rangeAtIndex:0];
        NSString                *sizeString = [urlString substringWithRange:NSMakeRange(range.location + 1, range.length - 2)];
        NSArray                 *arr = [sizeString componentsSeparatedByString:@"x"];
        CGFloat                 width = [arr.firstObject floatValue];
        CGFloat                 height = [arr.lastObject floatValue];

        return CGSizeMake(width, height);
    }

    return defaultImageSize;
}

@end
