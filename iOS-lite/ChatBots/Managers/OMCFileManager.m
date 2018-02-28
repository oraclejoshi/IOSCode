//
//  OMCFileManager.m
//  ChatBots
//
//  Created by Jay Vachhani on 11/3/17.
//  Copyright © 2017 Oracle. All rights reserved.
//

#import "OMCFileManager.h"

@implementation OMCFileManager

+ (NSURL *)applicationDocumentsDirectory{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

+(NSString *) getUniqueFilename{
    
    NSString* filename = @"OMCBot";
    double currenttimestamp = [[NSDate date] timeIntervalSince1970];
    NSString* cTime = [NSString stringWithFormat:@"%f", currenttimestamp];
    filename = [filename stringByAppendingFormat:@"%@", [[cTime componentsSeparatedByString:@"."] objectAtIndex:0]];
    
    return filename;
}

+ (NSString *_Nullable) storeFileData:(NSData *_Nonnull) data
                              withExt:(NSString * __nullable) ext {
    
    NSString* path = [[self.class applicationDocumentsDirectory] relativePath];
    path = [path stringByAppendingPathComponent:@"OMCBotCache"];
    BOOL isDir = YES;
    NSError* error = nil;
    
    NSFileManager *fileManager= [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:path isDirectory:&isDir])
        if(![fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error])
            NSLog(@"Error: Create folder failed at %@ with error: %@", path, error.localizedDescription);
    
    if ( error != nil ) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"Exception writing file: %@", error.localizedDescription]
                                     userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Exception writing a file: %@", error.localizedDescription]
                                                                          forKey:@"error"]];
    }
    
    NSString* fileName = [self.class getUniqueFilename];
    NSString* fPath = [path stringByAppendingPathComponent:fileName];
    if (ext)
        fPath = [fPath stringByAppendingString:ext];
    if ( [data writeToFile:fPath atomically:YES] ){
        fPath = [[fPath componentsSeparatedByString:@"/"] lastObject];
        return fPath;
    }
    
    return nil;
}

+ (NSData *) fileData:(NSString *) fileName {
    
    NSString* path = [[self.class applicationDocumentsDirectory] relativePath];
    path = [path stringByAppendingPathComponent:@"OMCBotCache"];
    path = [path stringByAppendingPathComponent:fileName];
    
    BOOL isDir = NO;
    if ( [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] == NO ) {
        NSLog(@"Error: file not found at path: %@", path);
    }
    
    return [NSData dataWithContentsOfFile:path];
}

+ (NSString *) filePath:(NSString *) fileName {
    
    NSString* path = [[self.class applicationDocumentsDirectory] relativePath];
    path = [path stringByAppendingPathComponent:@"OMCBotCache"];
    path = [path stringByAppendingPathComponent:fileName];
    
    BOOL isDir = NO;
    if ( [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] == NO ) {
        NSLog(@"Error: file not found at path: %@", path);
    }
    
    return path;
}

@end
