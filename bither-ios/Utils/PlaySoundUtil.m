//
//  PlaySoundUtil.m
//  bither-ios
//
//  Copyright 2014 http://Bither.net
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "PlaySoundUtil.h"

@implementation PlaySoundUtil
static void(^_callback)();

static void SoundFinished(SystemSoundID soundID, void *sample) {
    /*播放全部结束，因此释放所有资源 */
    
    AudioServicesDisposeSystemSoundID(soundID);
    CFRunLoopStop(CFRunLoopGetCurrent());
    if (_callback) {
        _callback();
    }
    NSLog(@"callback");
}

+ (void)playSound:(NSString *)soundName extension:(NSString *)extension callback:(void (^)())callback {
    NSURL *url = [[NSBundle mainBundle] URLForResource:soundName withExtension:extension];
    _callback = callback;
    SystemSoundID soundID;

    OSStatus err = AudioServicesCreateSystemSoundID((__bridge CFURLRef) (url), &soundID);
    if (err) {
        if (_callback) {
            _callback();
        }
        NSLog(@"Error occurred assigning system sound!");
    } else {
        /*添加音频结束时的回调*/
        AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, SoundFinished, (__bridge void *) (url));
        /*开始播放*/
        AudioServicesPlaySystemSound(soundID);
        CFRunLoopRun();
    }
}

+ (void)playSound:(NSString *)soundName callback:(void (^)())callback {
    [PlaySoundUtil playSound:soundName extension:@"mp3" callback:callback];

}
@end
