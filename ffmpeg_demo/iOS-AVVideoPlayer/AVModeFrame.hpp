//
//  AVModeFrame.hpp
//  ffmpeg_demo
//
//  Created by yuxueqing on 2018/9/18.
//  Copyright © 2018年 yuxueqing. All rights reserved.
//

#ifndef AVModeFrame_hpp
#define AVModeFrame_hpp

#include <memory>
//#include <optional>
extern "C" {
#include <libavcodec/avcodec.h>
#include <libavutil/avutil.h>
#include <libavformat/avformat.h>
}

class AVModeFrame;

extern void av_free_mode_frame(AVModeFrame **frame);

namespace AVVideoPlayer {
    
class AVModeFrame
{
public:
    double Pts() const;
    void SetPts(double pts);
    
    int Width() const;
    int Height() const;
    
    uint32_t Size() const;
    
    int64_t TimeStamp() const;
    void SetTimeStamp(int64_t ts);
    
    std::shared_ptr<AVFrame> Frame() const;
    
    static AVModeFrame* CreateMFrame(AVFrame *frame);
    
    const uint8_t** BufferData() const;
    
private:
    uint8_t **data { nullptr };
    std::shared_ptr<AVFrame> m_avframe;
    double m_pts = 0.0;
    double m_duration = 0.0;
    int64_t m_timeStamp;
    uint32_t m_size;
    int m_width = 0;
    int m_height = 0;
};
}

#endif /* AVModeFrame_hpp */
