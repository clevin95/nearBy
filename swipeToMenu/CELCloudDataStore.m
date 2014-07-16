//
//  CELCloudDataStore.m
//  swipeToMenu
//
//  Created by Carter Levin on 7/14/14.
//  Copyright (c) 2014 Carter Levin. All rights reserved.
//

#import "CELCloudDataStore.h"
#import "CELCoreDataStore.h"

@implementation CELCloudDataStore

+ (void)savePostToCloud:(Post *)newPost
{
    NSString *content = newPost.text;
    NSData *image = newPost.image;
    NSNumber *rate = newPost.rate;
    NSNumber *longitude = newPost.longitude;
    NSNumber *latitude = newPost.latitude;
    NSString *formattedString = [NSString stringWithFormat:@"content=%@&image=%@&rate=%@&longitude=%@&latitude=%@",content,image,rate,longitude,latitude];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *postsUrl = [NSURL URLWithString:@"http://localhost:5050"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postsUrl];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [formattedString dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    }];
    [task resume];
}


+ (void)getAllPosts
{
    CELCoreDataStore *store = [CELCoreDataStore sharedDataStore];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *postsUrl = [NSURL URLWithString:@"http://localhost:5050/posts"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postsUrl];
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSArray *responseArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        for (NSInteger i = 0; i < [responseArray count]; i++){
            
            
            [store savePostWithDictionary:responseArray[i]];
            
            
        }
    }];
    [task resume];
}


-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
}



@end
