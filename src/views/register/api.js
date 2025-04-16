import request from '@/utils/request';

// 获取所有医生信息
export function getAllDoctorService(username, day) {
  return request.get('/register/getAllDoctors', {
    params: { username, day }
  });
};

// 搜索医生信息
export function registerSearchService(department, state, username, day) {
  return request.get('/register/searchDoctors', {
    params: { department, state, username, day }
  });
};

// 添加预约
export function addAppointmentService(department, doctor, username, day) {
  return request.get('/register/addApp', {
    params: { department, doctor, username, day }
  });
};

// 取消预约
export function deleteAppointmentService(department, doctor, username, day) {
  return request.get('/register/cancelApp', {
    params: { department, doctor, username, day }
  });
};

// 获取支付二维码
export const payQRCodeService = (username) => {
  return request.get('/tools/QRCode', {
    params: { username }
  });
};