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

// 修改用户名
export function updateUserNameService(username, new_username) {
    return request.get('/auth/updateName', {
        params: {
            username,
            new_username
        }
    });  
}

// 修改密码
export function updatePasswordService(username, new_password) {
    return request.get('/auth/updatePassword', {
        params: {
            username,
            new_password
        }
    });  
}

// 删除账号
export function deleteAccountService(username) {
    return request.get('/auth/deleteUser', {
        params: {
            username
        }
    });  
}

// 修改邮箱
export function updateEmailService(username, new_email) {
    return request.get('/auth/updateEmail', {
        params: {
            username,
            new_email
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