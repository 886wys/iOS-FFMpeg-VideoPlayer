//
//  ViewController.m
//  ffmpeg_demo
//
//  Created by yuxueqing on 2018/9/7.
//  Copyright © 2018年 yuxueqing. All rights reserved.
//

#import "ViewController.h"
#import "AVDemux.hpp"
#import "AVDemuxThread.hpp"
#import "AVDecode.hpp"
#import <iostream>
#import "AVViewController.h"

@interface ViewController ()
{
    std::shared_ptr<AVVideoPlayer::AVDemux> m_demux;
 //   std::shared_ptr<AVVideoPlayer::AVDemuxThread> m_demuxThread;
    std::shared_ptr<AVVideoPlayer::AVDecode> m_decode;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    const char *file = [[[NSBundle mainBundle] pathForResource:@"video" ofType:@"mp4"] UTF8String];
    AVVideoPlayer::AVDemux demux;
    m_demux = std::shared_ptr<AVVideoPlayer::AVDemux>(new AVVideoPlayer::AVDemux());
    bool success = m_demux->Open(file);
    if (success) {
        AVPacket* packet = m_demux->Read();
        std::cout << packet->size << packet->pts << std::endl;
        av_packet_free(&packet);
    }
    m_demux->Start();
    AVVideoPlayer::AVDecode decode;
    m_decode = std::shared_ptr<AVVideoPlayer::AVDecode>(new AVVideoPlayer::AVDecode());
    AVCodecParameters *paras = m_demux->CopyVideoParams();
    success = m_decode->Open(paras);
    success = m_decode->Send(m_demux->Read());
    
    std::shared_ptr<AVFrame> frame = m_decode->RecvFrame()->frame();
    std::cout << frame->linesize[0] << "--- size :" << frame->pkt_size << " pts :"<< frame->pts << "  dts:" << frame->pkt_dts << std::endl;
    
    AVVideoPlayer::AVDemuxThread m_demuxThread;
    m_demuxThread.StartDemux(file, nullptr, (__bridge void *)self);
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end