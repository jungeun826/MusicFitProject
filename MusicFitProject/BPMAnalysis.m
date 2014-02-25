//
//  BPMAnalysis.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 20..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "BPMAnalysis.h"
#import "DBManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <aubio/aubio.h>

@implementation BPMAnalysis
- (BOOL)getiTunseMusic{
    
    DBManager *dbManager = [DBManager sharedDBManager];
    //아이튠즈 미디어들을 모두 가져와 초기화함
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    //아이튠즈 미디어들을 어레이에 넣어 접근을 용이하게 함
    NSArray *itemsFromGenericQuery = [everything items];
    //
    NSInteger count = [itemsFromGenericQuery count] -1;
    for(int index = (int)count ; index >= 0 ; index--){
        
        MPMediaItem *music = [itemsFromGenericQuery objectAtIndex:index];
        
        NSURL *url =[music valueForProperty:MPMediaItemPropertyAssetURL] ;
        //        if(index == 0)
        
        
        NSString *mp3URLString = [url absoluteString];
        NSString *location = [mp3URLString substringFromIndex:32];
        
        if([dbManager isExistWithlocation:location])
            continue;
        
        NSString *title = [NSString stringWithFormat:@"%@",[music valueForProperty:MPMediaItemPropertyTitle]];
        title =[title stringByReplacingOccurrencesOfString: @"'" withString: @"''"];
        
        NSString *artist = [NSString stringWithFormat:@"%@",[music valueForProperty:MPMediaItemPropertyArtist]];
        artist =[artist stringByReplacingOccurrencesOfString: @"'" withString: @"''"];
        
        //        Float64 time = [[music valueForKey:MPMediaItemPropertyPlaybackDuration] floatValue];
        //        CMTime duration = [[music valueForKey:MPMediaItemPropertyPlaybackDuration] CMTimeValue];
        NSInteger BPM = [[music valueForProperty:MPMediaItemPropertyBeatsPerMinute] intValue];
        if(BPM <=0 || BPM > 250)
            BPM = [self convertWav:url title:title];
        
        
        
        
        //유효 bpm범위 처리를 해야함.
        //        NSInteger BPM = [[music valueForProperty:MPMediaItemPropertyBeatsPerMinute] intValue];
        
        //FIXME: bpm 분석 후 얻어오는 부분 추가시 위의 주석이랑 같이 처리
        //        NSInteger BPM = index*2+2;
        
        NSLog(@"title :%@", title);
        //FIXME:무조건 isMusic을 true로 넣는다 고쳐야함.
        [dbManager insertMusicWithBPM:BPM title:title artist:artist location:location isMusic:YES];
    }
    [dbManager initStaticMode];
    
    return YES;
}
- (NSInteger)convertWav:(NSURL *)url title:(NSString *)title{
    //    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Music" withExtension:@"mp3"];
	AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    
	NSError *assetError = nil;
	AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:songAsset error:&assetError];
	if (assetError) {
		NSLog (@"error: %@", assetError);
		return -1;
	}
    
    AVAssetReaderOutput *assetReaderOutput = [AVAssetReaderAudioMixOutput  assetReaderAudioMixOutputWithAudioTracks:songAsset.tracks audioSettings: nil];
    if (! [assetReader canAddOutput: assetReaderOutput]) {
        NSLog (@"can't add reader output... die!");
        return -1;
    }
    [assetReader addOutput: assetReaderOutput];
    
    //    NSArray *dirs = NSSearchPathForDirectoriesInDomains
    //    (NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
    NSString *exportPath = [NSTemporaryDirectory() stringByAppendingString:@"temp.wav"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    }
    NSURL *exportURL = [NSURL fileURLWithPath:exportPath];
    
    AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:exportURL fileType:AVFileTypeCoreAudioFormat error:&assetError];
    if (assetError) {
        NSLog (@"error: %@", assetError);
        return -1;
    }
    
    AudioChannelLayout channelLayout;
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    NSDictionary *outputSettings =
    [NSDictionary dictionaryWithObjectsAndKeys:
     [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
     [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
     [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
     [NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)],
     AVChannelLayoutKey,
     [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
     [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
     [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
     [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
     nil];
    
    AVAssetWriterInput *assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:outputSettings];
    if ([assetWriter canAddInput:assetWriterInput]) {
        [assetWriter addInput:assetWriterInput];
    } else {
        NSLog (@"can't add asset writer input... die!");
        return -1;
    }
    assetWriterInput.expectsMediaDataInRealTime = YES;
    
    AVAssetTrack *soundTrack = [songAsset.tracks objectAtIndex:0];
    CMTime startTime = CMTimeMake (0, soundTrack.naturalTimeScale);
    //    CMTime time = CMTimeMakeWithSeconds(endTime, soundTrack.naturalTimeScale);
    
    
    if(![assetWriter startWriting])
        return -1;
    [assetWriter startSessionAtSourceTime: startTime];
    
    [assetReader startReading];
    
    //    [assetWriter endSessionAtSourceTime:endTime];
    UInt64 convertedByteCount = 0;
    //    dispatch_queue_t mediaInputQueue =	dispatch_queue_create("mediaInputQueue", NULL);
    //    NSArray *arr =
    //    [[NSOperationQueue mainQueue] addOperations:Nil waitUntilFinished:YES];
    //
    //    [assetWriterInput requestMediaDataWhenReadyOnQueue:mediaInputQueue
    //                                            usingBlock: ^{
    
    while (assetWriterInput.readyForMoreMediaData) {
        CMSampleBufferRef nextBuffer =[assetReaderOutput copyNextSampleBuffer];
        if (nextBuffer) {
            
            // append buffer
            [assetWriterInput appendSampleBuffer: nextBuffer];
            
            CFRelease(nextBuffer);
            convertedByteCount += CMSampleBufferGetTotalSampleSize (nextBuffer);
            //            if( convertedByteCount < 1323008*44)
            if(convertedByteCount > 1323008*4)
                break;
            
            // update ui
            
            //                                                        NSNumber *convertedByteCountNumber = [NSNumber numberWithLong:convertedByteCount];
            //                                                        [self performSelectorOnMainThread:@selector(updateSizeLabel:)
            //                                                                               withObject:convertedByteCountNumber
            //                                                                            waitUntilDone:NO];
            
        }else
            break;
    }
    
    // done!
    [assetWriterInput markAsFinished];
    //            [assetWriter finishWriting];
    [assetWriter finishWritingWithCompletionHandler:^{}];
    [assetReader cancelReading];
    NSDictionary *outputFileAttributes =[[NSFileManager defaultManager] attributesOfItemAtPath:exportPath error:nil];
    NSLog (@"\n FILE SIZE : %llu", [outputFileAttributes fileSize]);
    
    //                                            }];
    //	NSLog (@"bottom of convertTapped:");
    return [self getBPM];
    
}
- (NSInteger)getBPM{
    //    [self convertWav];
    NSString *urlString = [NSTemporaryDirectory() stringByAppendingString:@"temp.wav"];
    //    NSString *urlString = [url absoluteString];
    uint_t err = 0;
    
    uint_t samplerate = 0;
    
    uint_t buf_size = 1024;//1024; // window size (2^12)
    
    uint_t hop_size = buf_size/2;
    
    uint_t n_frames = 0, read = 0;
    //            NSURL *output = [NSURL URLWithString:urlString];
    //    NSString *sourcePathStr = [wa absoluteString];
    char_t *source_path = (char_t *)[urlString UTF8String];
    aubio_source_t * source = new_aubio_source(source_path, samplerate, hop_size);
    
    int averBPM = 0;
    
    if (!source) {
        err = 1;
        goto beach;
    }
    int loopCount =0;
    float bpm = 0.0f;
    float readSeconds = 0.0f;
    //    float reead = n_frames * 1. / samplerate;
    if (samplerate == 0 ) samplerate = aubio_source_get_samplerate(source);
    // create some vectors
    fvec_t * in = new_fvec (hop_size); // input audio buffer
    fvec_t * out = new_fvec (2); // output position
    // create tempo object
    aubio_tempo_t * o = new_aubio_tempo("default", buf_size, hop_size, samplerate);
    //            NSLog(@"start");
    do {
        // put some fresh data in input vector
        aubio_source_do(source, in, &read);
        // execute tempo
        aubio_tempo_do(o,in,out);
        
        n_frames += read;
        readSeconds = n_frames*1. / samplerate;
        if(readSeconds < 20.0f)
            continue;
        
        if(readSeconds >= 10.0f && readSeconds < 30.0f){
            
            //                smpl_t is_beat = fvec_get_sample (out, 0);
            //                NSLog(@"%f", is_beat);
            // do something with the beats
            if (out->data[0] != 0) {
                //                                float ms = aubio_tempo_get_last_ms(o);
                //                                float s = aubio_tempo_get_last_s(o);
                //                            int frame = aubio_tempo_get_last(o);
                bpm += aubio_tempo_get_bpm(o);
                //                            float confidence = aubio_tempo_get_confidence(o);
                
                //                                NSLog(@"beat at %.3fms, %.3fs, frame %d, %.2fbpm with confidence %.2f",ms,s,frame,bpm,confidence);
                
                loopCount++;
            }
        }else
            break;
    } while ( read == hop_size );
    int frames = n_frames;
    int hz =samplerate;
    int blocks =n_frames / hop_size;
    averBPM= bpm/loopCount;
    NSLog(@"\nread %.2fs, %d frames at %dHz (%d blocks) count:%d\n BPM:%d",readSeconds ,frames,hz,blocks, loopCount, averBPM);
    // clean up memory
    del_aubio_tempo(o);
    del_fvec(in);
    del_fvec(out);
    del_aubio_source(source);
beach:
    aubio_cleanup();
    //    error = ExtAudioFileDispose(af);
    //    ExtAudioFileDispose(outAF);
    
    
    //    NSLog(@"averBPM: %d", averBPM);
    return averBPM;
    
}
@end
