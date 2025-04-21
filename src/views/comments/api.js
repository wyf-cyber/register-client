import request from '@/utils/request';

// 添加评论
export function addCommentService(doctor,content, rating) {
  return request.get('/register/addComment', {
    params: { doctor, content, rating }
  });
}

// 获取所有评论
export function getAllCommentsService() {
  return request.get('/register/getAllComments');
}

// 获取某个医生的所有评论
export function getCommentsByDoctorService(doctor) {
  return request.get('/register/getCommentsByDoctor', {
    params: { doctor }
  });
}