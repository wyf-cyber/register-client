import request from '@/utils/request.js'

// 用户登录服务
export function loginService(username, password) {
    return request.get('/auth/login', {
        params: {  // 使用 params 来传递查询参数
            username,
            password
        }
    });
}

// 用户注册服务
export function registerService(username, password, email) {
    return request.get('/auth/register', {
        params: {  // 同样使用 params 传递查询参数
            username,
            password,
            email
        }
    });
}

// 发送邮箱验证码
export function sendVerificationEmailService(username) {
    return request.get('/auth/sendEmail', {
        params: {
            username
        }
    });  
}

// 验证邮箱验证码
export function verifyEmailCodeService(username, code) {
    return request.get('/auth/checkCode', {
        params: {
            username,
            code
        }
    });  
}

// 验证码服务
export function verifyService() {
    return request.get('/tools/Captcha');  // 不需要 params，验证码应由后端生成并返回
}