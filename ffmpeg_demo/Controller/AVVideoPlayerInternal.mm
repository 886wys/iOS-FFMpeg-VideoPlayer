//
//  AVVideoPlayerInternal.m
//  ffmpeg_demo
//
//  Created by yuxueqing on 2018/9/30.
//  Copyright © 2018年 yuxueqing. All rights reserved.
//

#import "AVVideoPlayerInternal.h"
#import <UIKit/UIKit.h>
#import "AVDispatchQueue.h"

namespace AVVideoPlayer {

AVVideoPlayerInternal::AVVideoPlayerInternal(AVVideoPlayer *videoPlayer)
{
    m_videoPlayer = videoPlayer;
}

void AVVideoPlayerInternal::Prepare()
{
    m_videoPlayer->Prepare();
}

void AVVideoPlayerInternal::Destroyed()
{

}

void AVVideoPlayerInternal::Pause()
{
    m_videoPlayer->SetPause(true);
}

void AVVideoPlayerInternal::Stop()
{
    m_videoPlayer->Stop();
}

void AVVideoPlayerInternal::Resume()
{
    m_videoPlayer->Prepare();
}

void AVVideoPlayerInternal::Restart()
{
    m_videoPlayer->Restart();
}
    
void AVVideoPlayerInternal::Seek(double pos)
{
    m_videoPlayer->SeekToTime(pos);
}

AVVideoPlayerSystemListener::AVVideoPlayerSystemListener(AVApplicationListener& listener)
    : m_listener(listener)
{}
    
AVVideoPlayerListener::AVApplicationListener& AVVideoPlayerSystemListener::Listener() const
{
    return m_listener;
}

AVVideoPlayerListener::AVVideoPlayerListener(AVApplicationListener& listener)
    : AVVideoPlayerSystemListener(listener)
    , m_willResignObserver(nil)
    , m_willEnterBackgroundObserver(nil)
    , m_didBecomeActiveObserver(nil)
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    std::weak_ptr<AVVideoPlayerListener> weakSelf = SharedListener();
    
    m_didBecomeActiveObserver =
    [center addObserverForName:UIApplicationDidBecomeActiveNotification
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification * _Nonnull note) {
                        auto strongSelf = weakSelf.lock();
                        [AVDispatchQueue dispatchTaskAsyncOnMainQueue:^{
                            if (strongSelf)
                                strongSelf->m_listener.ApplicationDidBecomeActive();
                        }];
    }];
    
    m_willEnterBackgroundObserver =
    [center addObserverForName:UIApplicationDidEnterBackgroundNotification
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification * _Nonnull note) {
                        auto strongSelf = weakSelf.lock();
                        [AVDispatchQueue dispatchTaskAsyncOnMainQueue:^{
                            if (strongSelf)
                                strongSelf->m_listener.ApplicationWillEnterBackground();
                        }];
    }];
    
    m_willResignObserver =
    [center addObserverForName:UIApplicationWillResignActiveNotification
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification * _Nonnull note) {
                        auto strongSelf = weakSelf.lock();
                        [AVDispatchQueue dispatchTaskAsyncOnMainQueue:^{
                            if (strongSelf)
                                strongSelf->m_listener.ApplicationWillResign();
                        }];
    }];
    
}
    
AVVideoPlayerListener::~AVVideoPlayerListener()
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:m_didBecomeActiveObserver];
    [center removeObserver:m_willResignObserver];
    [center removeObserver:m_willEnterBackgroundObserver];
}

std::shared_ptr<AVVideoPlayerListener> AVVideoPlayerListener::SharedListener()
{
    return shared_from_this();
}
    
std::unique_ptr<AVVideoPlayerSystemListener> AVVideoPlayerSystemListener::Create(AVApplicationListener& listener)
{
    return std::unique_ptr<AVVideoPlayerSystemListener>(new AVVideoPlayerListener(listener));
}
    
AVPlayerNotificationListener::AVPlayerNotificationListener()
{
    
}
    
AVPlayerNotificationListener::~AVPlayerNotificationListener()
{
    
}
    
void AVPlayerNotificationListener::ApplicationWillResign()
{
    auto videoPlayer = m_videoPrivate.lock();
    if (videoPlayer)
        videoPlayer->Stop();
}
    
void AVPlayerNotificationListener::ApplicationDidBecomeActive()
{
    auto videoPlayer = m_videoPrivate.lock();
    if (videoPlayer)
        videoPlayer->Resume();
}
    
void AVPlayerNotificationListener::ApplicationWillEnterBackground()
{
    auto videoPlayer = m_videoPrivate.lock();
    if (videoPlayer)
        videoPlayer->Pause();
}
    
}
