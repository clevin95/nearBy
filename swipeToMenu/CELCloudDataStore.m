//
//  CELCloudDataStore.m
//  swipeToMenu
//
//  Created by Carter Levin on 7/14/14.
//  Copyright (c) 2014 Carter Levin. All rights reserved.
//

#import "CELCloudDataStore.h"
#import "CELCoreDataStore.h"
#import "CELConstants.h"

@implementation CELCloudDataStore

+ (void)savePostToCloud:(Post *)newPost
{
    NSString *content = newPost.text;
    NSData *image = newPost.image;
    NSNumber *rate = newPost.rate;
    NSNumber *longitude = newPost.longitude;
    NSNumber *latitude = newPost.latitude;
    NSLog(@"longitude: %@\nlatitude: %@",longitude,latitude);
    NSString *formattedString = [NSString stringWithFormat:@"content=%@&image=%@&rate=%@&longitude=%@&latitude=%@",content,image,rate,longitude,latitude];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/travellers/44/posts",REMOTE_URL];
    NSURL *postsUrl = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postsUrl];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [formattedString dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"%@",response);
        NSLog(@"%@",error);
    }];
    [task resume];
}

+ (void)getAllPosts:(void (^) (NSArray *allPosts))postsPassback;
{
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/travellers/posts", REMOTE_URL];
    
    NSURL *postsUrl = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postsUrl];
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSArray *responseArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (error){
            NSLog(@"%@",error);
        }
        postsPassback(responseArray);
        
        
        
    }];
    [task resume];
}

+ (void)createUserWithName:(NSString *)name
                  password:(NSString *)password
           completionBlock:(void (^)(NSString *error, NSString *uniqueID))callbackUniqueID
{
    
    NSString *formattedString = [NSString stringWithFormat:@"username=%@&password=%@",name,password];
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *urlString = [NSString stringWithFormat:@"%@/travellers", REMOTE_URL];
    NSURL *postsUrl = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postsUrl];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [formattedString dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *convertedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSString *uniqueID = [NSString stringWithFormat:@"%@",convertedData[@"unique_id"]];
        callbackUniqueID([NSString stringWithFormat:@"%@",error], uniqueID);
    }];
    [task resume];
}


+ (void)validateUserWithName:(NSString *)name
                    password:(NSString *)password
                userPassback:(void (^) (NSString *error, NSDictionary *userDic))userPassback
{
    NSString *formattedString = [NSString stringWithFormat:@"username=%@&password=%@",name,password];
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *urlString = [NSString stringWithFormat:@"%@/travellers", REMOTE_URL];
    NSURL *postsUrl = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postsUrl];
    request.HTTPMethod = @"PUT";
    request.HTTPBody = [formattedString dataUsingEncoding:NSUTF8StringEncoding];
    
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *convertedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (error){
            NSString *errorAsString = [NSString stringWithFormat:@"%@",error];
            userPassback(errorAsString, nil);
        }
        else if (convertedData[@"error"]){
            userPassback(convertedData[@"error"], nil);
        }else {
            userPassback(nil, convertedData);
        }
    }];
    [task resume];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
}



@end
