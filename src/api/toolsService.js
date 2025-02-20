import request from '@/utils/request.js'

// 验证码服务
export function verifyService() {
    return request.get('/tools/Captcha');  // 不需要 params，验证码应由后端生成并返回
}