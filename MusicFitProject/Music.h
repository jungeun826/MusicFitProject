//
//  Music.h
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 2. 3..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPMediaItem;
//CREATE  TABLE  IF NOT EXISTS "main"."MUSIC" ("Music_ID" INTEGER PRIMARY KEY  NOT NULL , "BPM" INTEGER DEFAULT 0, "Title" VARCHAR, "Artist" VARCHAR, "Location" VARCHAR, "IsMusic" BOOL DEFAULT YES)
@interface Music : NSObject

@property (nonatomic, readonly) NSInteger musicID;
@property (nonatomic, readonly) NSInteger BPM;
@property (strong, nonatomic, readonly) NSString *title;
@property (strong, nonatomic, readonly) NSString *artist;
@property (strong, nonatomic, readonly) NSString *location;
@property (nonatomic, readonly) BOOL isMusic;

-(id)initWithMusicID:(NSInteger)musicID BPM:(NSInteger)bpm title:(NSString *)title artist:(NSString *)artist location:(NSString *)location isMusic:(BOOL)isMusic;
- (UIImage *)getAlbumImageWithSize:(CGSize)size;
- (MPMediaItem *)getMPMediaItemOfMusic;
@end
