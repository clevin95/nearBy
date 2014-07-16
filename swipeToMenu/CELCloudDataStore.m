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
    UIImage *imageToConvert = [UIImage imageNamed:@"defaultImage.jpg"];
    NSData *imageData = UIImagePNGRepresentation(imageToConvert);
    
    
    NSString *content = newPost.text;
    NSData *image = newPost.image;
    NSNumber *rate = newPost.rate;
    NSNumber *longitude = newPost.longitude;
    NSNumber *latitude = newPost.latitude;
    NSLog(@"longitude: %@\nlatitude: %@",longitude,latitude);
    NSString *formattedString = [NSString stringWithFormat:@"content=%@&image=%@&rate=%@&longitude=%@&latitude=%@",content,image,rate,longitude,latitude];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *postsUrl = [NSURL URLWithString:POSTS_ACCESS_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postsUrl];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [formattedString dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"%@",response);
        NSLog(@"%@",error);
    }];
    [task resume];
}

+ (void)getAllPosts
{
    CELCoreDataStore *store = [CELCoreDataStore sharedDataStore];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *postsUrl = [NSURL URLWithString:POSTS_ACCESS_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postsUrl];
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSArray *responseArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        for (NSInteger i = 0; i < [responseArray count]; i++){
            [store savePostWithDictionary:responseArray[i]];
        }
        if (error){
            NSLog(@"%@",error);
        }
    }];
    [task resume];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
}



@end
