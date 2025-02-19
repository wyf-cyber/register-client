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
export function registerService(username, password) {
    return request.get('/auth/register', {
        params: {  // 同样使用 params 传递查询参数
            username,
            password
        }
    });
}
