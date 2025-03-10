import request from '@/utils/request';

// 用户登录服务，用于验证身份
export function loginService(username, password) {
    return request.get('/auth/login', {
        params: {  // 使用 params 来传递查询参数
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