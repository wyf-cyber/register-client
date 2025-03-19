import request from '@/utils/request';

// 获取用户信息
// 输入用户的名称，返回用户绑定的邮箱号
export function getUserInfoService(username) {
    return request.get('/auth/getUserInfo', {
        params: {
            username
        }
    });
}

// 获取用户过往预约记录
export function getUserAppointmentHistoryService(username) {
    return request.get('/auth/getUserAppointmentHistory', {
        params: {
            username
        }
    });
}

