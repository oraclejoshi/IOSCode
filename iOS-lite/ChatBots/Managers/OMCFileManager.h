//
//  OMCFileManager.h
//  ChatBots
//
//  Created by Jay Vachhani on 11/3/17.
//  Copyright © 2017 Oracle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OMCFileManager : NSObject

+ (NSString *_Nullable) storeFileData:(NSData *_Nonnull) data
                              withExt:(NSString * __nullable) ext;

+ (NSData *_Nullable) fileData:(NSString *_Nonnull) fileName;

+ (NSString *_Nullable) filePath:(NSString *_Nonnull) fileName;

@end
