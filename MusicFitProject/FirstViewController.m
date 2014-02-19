//
//  ViewController.m
//  MusicFitProject
//
//  Created by SDT-1 on 2014. 1. 10..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "FirstViewController.h"
#import "AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
#import "DBManager.h"
#import "PlayerViewController.h"
#import "FirstViewController.h"
#import <aubio/aubio.h>

@interface FirstViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@end

@implementation FirstViewController{
    DBManager *_DBManager;
    BOOL _repeat;
}
- (BOOL)loadFromUserDefaultTutorial{
    BOOL tutorialShow = [[NSUserDefaults standardUserDefaults] boolForKey:@"tutorial_preference"];
    
    return tutorialShow;
}

//FIXME: 튜토리얼 다시 안보기 설정시 분기를 이용해 메인/튜토리얼 로 넘어가게 하기.
- (void)movePlayerOrTutorial{
     AppDelegate *app = [[UIApplication sharedApplication]delegate];
    BOOL tutorialShow = [self loadFromUserDefaultTutorial];
    if(tutorialShow==NO){
        //NO : 안볼래요를 누른 경우
        PlayerViewController *initVC = [self.storyboard instantiateViewControllerWithIdentifier:@"player"];
        [initVC setSwipeController];
        app.window.rootViewController = initVC;
    }else{
        FirstViewController *initVC = [self.storyboard instantiateViewControllerWithIdentifier:@"tutorial"];
        app.window.rootViewController = initVC;
    }
}
- (void)animationMainImage{
    [UIView animateWithDuration:1.0 animations:^{
        self.mainImageView.alpha = 0;
        self.mainImageView.backgroundColor = [UIColor clearColor];
//        [self getITunseSyncMusic];
    }completion:nil];
    [self performSelector:@selector(movePlayerOrTutorial) withObject:nil afterDelay:0.2];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//페이지 로드시
//메인 페이지를 어느정도 보여 준 후 튜토리얼로 넘어갈 수 있도록 함.
- (void)viewDidLoad{
    [super viewDidLoad];

    [self performSelector:@selector(animationMainImage) withObject:nil afterDelay:1.0];
    [self performSelector:@selector(getITunseSyncMusic) withObject:nil afterDelay:0.0];
    
//    DBManager *dbManager = [DBManager sharedDBManager];
//    
//    [dbManager initStaticMode];
}

//아이튠즈에서 음악에 대한 정보를 가져와 DB화 하는 함수를 부름
- (void)getITunseSyncMusic{
    //1.7초
    DBManager *dbManager = [DBManager sharedDBManager];
    //아이튠즈 미디어들을 모두 가져와 초기화함
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    //아이튠즈 미디어들을 어레이에 넣어 접근을 용이하게 함
    NSArray *itemsFromGenericQuery = [everything items];
    //
    NSInteger count = [itemsFromGenericQuery count] -1;
    
    NSMutableArray *insertArr = [[NSMutableArray alloc]init];
    NSLog(@"insert Start");
    for(int index = 0 ; index < count ; index++){
        
        MPMediaItem *music = [itemsFromGenericQuery objectAtIndex:index];
        
        NSString *stringURL = [[music valueForProperty:MPMediaItemPropertyAssetURL] absoluteString];
        NSString *location = [stringURL substringFromIndex:32];
        
        
        if([dbManager isExistWithlocation:location])
            continue;
        
        
        NSString *title = [NSString stringWithFormat:@"%@",[music valueForProperty:MPMediaItemPropertyTitle]];
        title =[title stringByReplacingOccurrencesOfString: @"'" withString: @"''"];
        
        NSString *artist = [NSString stringWithFormat:@"%@",[music valueForProperty:                        MPMediaItemPropertyArtist]];
        artist =[artist stringByReplacingOccurrencesOfString: @"'" withString: @"''"];
        
//        NSString *wavURLString = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.wav"];
        ////        [self exportMP3:url toFileUrl:wavURLString];
        ////        [self convertToWav:url wavURLString:wavURLString];
        //        //            NSData *data = [NSData dataWithContentsOfFile:stringURL];
        //
        ////        NSInteger BPM = [self anlysisBPMWithWav:wavURLString];
        //유효 bpm범위 처리를 해야함.
        
        //FIXME: bpm 분석 후 얻어오는 부분 추가시 위의 주석이랑 같이 처리
        NSInteger BPM = index*3 +2;
        
        Music *song = [[Music alloc] initWithMusicID:0 BPM:BPM title:title artist:artist location:location isMusic:YES];
        
        [insertArr addObject:song];
        //FIXME:무조건 isMusic을 true로 넣는다 고쳐야함.
    }
    [dbManager insertMusicWithMusicArr:insertArr];
    NSLog(@"insert end");
    [dbManager initStaticMode];
    /*
     가슴 시린 이야기 (Feat. 용준형 of BEAST), 휘성, 8605142450541980905
     가질 수 없는 너, 하이니, 8605142450541980900
     거짓말 거짓말 거짓말, 이적, 8605142450541980878
     겨울 고백, 성시경, 박효신, 서인국, 빅스, 여동생, 8605142450541980860
     그대가 분다, 엠씨 더 맥스, 8605142450541980874
     그대와 함께, B1A4, 8605142450541980910
     그때 우리, 엠씨 더 맥스, 8605142450541980872
     그런 줄 알았어, 지아(Zia), 8605142450541980884
     그렇게 당해놓고 (Feat. 마부스 Of 일렉트로보이즈), 임창정, 8605142450541980879
     그리워해요, 투애니원(2NE1), 8605142450541980894
     금요일에 만나요 (Feat. 장이정 Of HISTORY), 아이유, 8605142450541980866
     꾸리스마스, 크레용팝, 8605142450541980890
     나란놈이란, 임창정, 8605142450541980880
     날 위한 이별, 디아, 8605142450541980838
     내 생각날 거야 (Narr. 이시영), 거미, 8605142450541980825
     내일은 없어, 트러블메이커, 8605142450541980895
     너 밖에 몰라 (One Way Love), 효린, 8605142450541980903
     너를, 브라운 아이드 소울(Brown Eyed Soul), 8605142450541980854
     너만 보여 (Feat. 범키), 톱밥, 8605142450541980892
     너만을 느끼며, 정우 & 유연석 & 손호준, 8605142450541980881
     너에게, 성시경, 8605142450541980859
     너에게만, 범키, 버벌진트, 8605142450541980853
     노래가 늘었어, 에일리, 8605142450541980869
     눈물이 맘을 훔쳐서, 에일리, 8605142450541980870
     답이 없었어, 홍대광, 8605142450541980902
     둘도 없는 바보, 레드애플(Led apple), 8605142450541980840
     링가 링가 (RINGA LINGA), 태양, 8605142450541980891
     만약에 말야 (전우성 Solo), 노을, 8605142450541980833
     몹쓸 노래 (Feat. 칸토), 럼블 피쉬, 8605142450541980839
     미스터리 (Feat. San E), 박지윤, 8605142450541980848
     바람이 분다 (영화 '신이 보낸 사람' 삽입곡), 포맨(4men), 8605142450541980896
     */
    //    NSArray *tempMP3 = @[@{@"title":@"가슴 시린 이야기 (Feat. 용준형 of BEAST)",@"artist":@"휘성",@"location":@"8605142450541980905"},@{@"title":@"가질 수 없는 너",@"artist":@"하이니",@"location":@"8605142450541980900"},                         @{@"title":@"금요일에 만나요 (Feat. 장이정 Of HISTORY)",@"artist":@"아이유",@"location":@"8605142450541980866"}];
    //    NSString *location ;
    //    NSString *title ;
    //    NSString *artist ;
    //    NSInteger BPM;
    //    int count = (int)[tempMP3 count];
    //    for(int index = 0 ; index < count ; index++){
    //        location= tempMP3[index][@"location"];
    //
    //        if([_musicDBManager isExistWithlocation:location])
    //            continue;
    //
    //        title = tempMP3[index][@"title"];
    //        artist = tempMP3[index][@"artist"];
    //
    //        BPM = index*73 +30;
    //
    //        //FIXME:무조건 isMusic을 true로 넣는다 고쳐야함.
    //        [_musicDBManager insertMusicWithBPM:BPM title:title artist:artist location:location isMusic:YES];
    //    }
}
- (NSInteger)anlysisBPMWithWav:(NSString *)wavURLString{
    uint_t err = 0;
    
    uint_t samplerate = 0;
    
    uint_t buf_size = 1024*2;//1024; // window size (2^12)
    uint_t hop_size = buf_size/8;
    
    uint_t n_frames = 0, read = 0;
    //            NSURL *output = [NSURL URLWithString:urlString];
    char_t *source_path = (char_t *)[wavURLString UTF8String];
    aubio_source_t * source = new_aubio_source(source_path, samplerate, hop_size);
    
    int averBPM = 0;
    
    if (!source) {
        err = 1;
        goto beach;
    }
    int loopCount =0;
    float bpm = 0.0f;
    
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
        
        //                smpl_t is_beat = fvec_get_sample (out, 0);
        //                NSLog(@"%f", is_beat);
        // do something with the beats
        if (out->data[0] != 0) {
            //                    float ms = aubio_tempo_get_last_ms(o);
            //                    float s = aubio_tempo_get_last_s(o);
            //                    int frame = aubio_tempo_get_last(o);
            bpm += aubio_tempo_get_bpm(o);
            //                    float confidence = aubio_tempo_get_confidence(o);
            //                    NSLog(@"beat at %.3fms, %.3fs, frame %d, %.2fbpm with confidence %.2f",ms,s,frame,bpm,confidence);
            loopCount++;
        }
        n_frames += read;
    } while ( read == hop_size );
    float reead = n_frames * 1. / samplerate;
    int frames = n_frames;
    int hz =samplerate;
    int blocks =n_frames / hop_size;
    averBPM = bpm/loopCount;
    NSLog(@"read %.2fs, %d frames at %dHz (%d blocks) from %s count:%d\n BPM:%d",reead ,frames,hz,blocks, source_path, loopCount, averBPM);
    // clean up memory
    del_aubio_tempo(o);
    del_fvec(in);
    del_fvec(out);
    del_aubio_source(source);
beach:
    aubio_cleanup();
    //            return err;
    
    return averBPM;
    
}
-(NSString *)exportMP3:(NSURL*)url toFileUrl:(NSString*)fileURL{
    AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:url options:nil];
//    NSURL *url = [NSURL url]
    AVAssetReader *reader=[[AVAssetReader alloc] initWithAsset:asset error:nil];
//    [asset tracksWithMediaType:AVMediaTypeAudio];
    NSMutableArray *myOutputs =[[NSMutableArray alloc] init];
    for(id track in [asset tracks]){
        AVAssetReaderTrackOutput *output=[AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:track outputSettings:nil];
        [myOutputs addObject:output];
        [reader addOutput:output];
    }
    [reader startReading];
    NSFileHandle *fileHandle ;
    NSFileManager *fm=[NSFileManager defaultManager];
    
    [fm removeItemAtPath:fileURL error:nil];
    [fm createFileAtPath:fileURL contents:[[NSData alloc] init] attributes:nil];

    
    
    fileHandle=[NSFileHandle fileHandleForUpdatingAtPath:fileURL];
    [fileHandle seekToEndOfFile];
    
    AVAssetReaderOutput *output=[myOutputs objectAtIndex:0];
    AudioBufferList audioBufferList;
    int totalBuff=0;
    while(TRUE){
        CMSampleBufferRef ref=[output copyNextSampleBuffer];
        
        CMBlockBufferRef blockBuffer = NULL;
        if(ref==NULL)
            break;
        //copy data to file
            
        //read next one
        
            NSMutableData *data=[[NSMutableData alloc] init];
            CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(ref, NULL, &audioBufferList, sizeof(audioBufferList), NULL, NULL, 0, &blockBuffer);

            for( int y=0; y<audioBufferList.mNumberBuffers; y++ ){
                AudioBuffer audioBuffer = audioBufferList.mBuffers[y];
                Float32 *frame = audioBuffer.mData;

                //  Float32 currentSample = frame[i];
                [data appendBytes:frame length:audioBuffer.mDataByteSize];

                //  written= fwrite(frame, sizeof(Float32), audioBuffer.mDataByteSize, f);
                ////NSLog(@"Wrote %d", written);
            }
            totalBuff++;
        
            
        [fileHandle writeData:data];
            
        CFRetain(blockBuffer);
        CFRelease(blockBuffer);
        CFRelease(ref);
//        NSLog(@"writting %d frame for amounts of buffers %d ", data.length, audioBufferList.mNumberBuffers);
////        [data release];
    }
      NSLog(@"total buffs %d", totalBuff);
//        fclose(f);    [fileHandle closeFile];
    
//    
    return fileURL;
}
-(BOOL)exportAssetAsWaveFormat:(NSString*)mp3Url wavUrl:(NSString *)wavUrl{
    NSError *error = nil ;
//    
//    NSDictionary *audioSetting = [NSDictionary dictionaryWithObjectsAndKeys:
//                                  [ NSNumber numberWithFloat:44100.0], AVSampleRateKey,
//                                  [ NSNumber numberWithInt:1], AVNumberOfChannelsKey,
//                                  [ NSNumber numberWithInt:8], AVLinearPCMBitDepthKey, //16
//                                  [ NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
//                                  [ NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
//                                  [ NSNumber numberWithBool:0], AVLinearPCMIsBigEndianKey,
//                                  [ NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
//                                  [ NSData data], AVChannelLayoutKey, nil ];
    
//    NSString *audioFilePath = filePath;
    AVURLAsset * URLAsset = [[AVURLAsset alloc]  initWithURL:[NSURL fileURLWithPath:mp3Url] options:nil];
    
    if (!URLAsset) return NO ;
    
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:URLAsset error:&error];
    if (error) return NO;
    
    NSMutableArray *myOutputs =[[NSMutableArray alloc] init];
    
//    NSArray *tracks = [URLAsset tracksWithMediaType:AVMediaTypeAudio];
//    if (![tracks count]) return NO;
    AVAssetReaderTrackOutput *output;
    for(id track in [URLAsset tracks]){
        output=[AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:track outputSettings:nil];
        [myOutputs addObject:output];
//        [reader addOutput:output];
    }
    
    if (![assetReader canAddOutput:output]) return NO ;
    
    [assetReader addOutput:output];
    
    if (![assetReader startReading])
        return NO;
    
    
    // Remove previously converted wav
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:wavUrl error:NULL];
    
    NSURL *outURL = [NSURL fileURLWithPath:wavUrl];
    AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:outURL fileType:AVFileTypeWAVE error:&error];
    if (error) return NO;
    
    
    AVAssetWriterInput *assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:nil];
    assetWriterInput.expectsMediaDataInRealTime = NO;
    
    if (![assetWriter canAddInput:assetWriterInput])
        return NO ;
    
    [assetWriter addInput :assetWriterInput];
    
    if (![assetWriter startWriting])
        return NO;
    
    
//    [assetReader retain];
//    [assetWriter retain];
    
    [assetWriter startSessionAtSourceTime:kCMTimeZero ];
    
    dispatch_queue_t queue = dispatch_queue_create( "assetWriterQueue", NULL );
    
    [assetWriterInput requestMediaDataWhenReadyOnQueue:queue usingBlock:^{
        
        NSLog(@"start");
        while ([assetWriterInput isReadyForMoreMediaData]) {
            
            CMSampleBufferRef sampleBuffer = [output copyNextSampleBuffer];
            
            if (sampleBuffer) {
                [assetWriterInput appendSampleBuffer :sampleBuffer];
                CFRelease(sampleBuffer);
            } else {
                [assetWriterInput markAsFinished];
                break;
            }
        }
        
        [assetWriter finishWritingWithCompletionHandler:^{
            NSLog(@"finish");
//            [self performSelectorOnMainThread:@selector(wavConvertionCompletedWithPath:) withObject:wavUrl waitUntilDone:NO];
        }];
//        [assetReader release ];
//        [assetWriter release ];
        
        
    }];
    
//    dispatch_release(queue);
    
    return YES;
}

-(void) convertToWav:(NSURL *)mp3URL wavURLString:(NSString *)wavURLString{
    // set up an AVAssetReader to read from the iPod Library
    
//    NSString *cafFilePath=[[NSBundle mainBundle]pathForResource:@"test" ofType:@"caf"];
    
//    NSURL *assetURL = [NSURL fileURLWithPath:cafFilePath];
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:mp3URL options:nil];
    
    __autoreleasing NSError *assetError = nil;
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:songAsset error:&assetError];
    
    if (assetError) {
        NSLog (@"error: %@", assetError);
        return;
    }
    
    AVAssetReaderOutput *assetReaderOutput = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks:songAsset.tracks audioSettings: nil];
    
    if (! [assetReader canAddOutput: assetReaderOutput]) {
        NSLog (@"can't add reader output... die!");
        return;
    }
    
    [assetReader addOutput: assetReaderOutput];

    if ([[NSFileManager defaultManager] fileExistsAtPath:wavURLString]){
        [[NSFileManager defaultManager] removeItemAtPath:wavURLString error:nil];
    }
    
    NSURL *exportURL = [NSURL fileURLWithPath:wavURLString];
    AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:exportURL fileType:AVFileTypeWAVE error:&assetError];
    if (assetError){
        NSLog (@"error: %@", assetError);
        return;
    }
    
    AudioChannelLayout channelLayout;
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                    [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                    [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
                                    [NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)], AVChannelLayoutKey,
                                    [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                    [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                    nil];
    
    AVAssetWriterInput *assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:outputSettings];
    
    if ([assetWriter canAddInput:assetWriterInput]){
        [assetWriter addInput:assetWriterInput];
    }else{
        NSLog (@"can't add asset writer input... die!");
        return;
    }
    
    assetWriterInput.expectsMediaDataInRealTime = NO;
    
    [assetWriter startWriting];
    [assetReader startReading];
    
    AVAssetTrack *soundTrack = [songAsset.tracks objectAtIndex:0];
    CMTime startTime = CMTimeMake (0, soundTrack.naturalTimeScale);
    [assetWriter startSessionAtSourceTime: startTime];
//
//    UInt64 convertedByteCount = 0;
//    dispatch_queue_t mediaInputQueue = dispatch_queue_create("mediaInputQueue", NULL);
    
//    [assetWriterInput requestMediaDataWhenReadyOnQueue:mediaInputQueue
//                                            usingBlock: ^
//     {
//
         while (assetWriterInput.readyForMoreMediaData){
             CMSampleBufferRef nextBuffer = [assetReaderOutput copyNextSampleBuffer];
             if (nextBuffer){
                 // append buffer
                 [assetWriterInput appendSampleBuffer: nextBuffer];
//                 convertedByteCount += CMSampleBufferGetTotalSampleSize (nextBuffer);
//                 CMTime progressTime = CMSampleBufferGetPresentationTimeStamp(nextBuffer);
                 
//                 CMTime sampleDuration = CMSampleBufferGetDuration(nextBuffer);
//                 if (CMTIME_IS_NUMERIC(sampleDuration))
//                     progressTime= CMTimeAdd(progressTime, sampleDuration);
//                 float dProgress= CMTimeGetSeconds(progressTime) / CMTimeGetSeconds(songAsset.duration);
//                 NSLog(@"%f",dProgress);
                 
                 
                 CFRelease(nextBuffer);
             }else{
                 [assetWriterInput markAsFinished];
//                 //              [assetWriter finishWriting];
//                 [assetWriter cancelWriting];
                
                 
                 [assetReader cancelReading];
                [assetWriter finishWritingWithCompletionHandler:^{}];
                 NSLog(@"end");
                 
                 [NSThread sleepForTimeInterval:0.7];
             }
         }
//     }];
}
@end
