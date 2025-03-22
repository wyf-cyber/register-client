import request from '@/utils/request.js'

// 获取AI回复
export function getAIResponseService(message) {
    return request.get('/tools/getAIResponse', {
        params: {
            message   // 传递消息，这是一个字符串
        }
    });
}