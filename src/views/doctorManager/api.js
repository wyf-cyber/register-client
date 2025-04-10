import request from '@/utils/request';

// 添加医生信息
export function addDoctorService(department, doctor, detail, day) {
  return request.get('/admin/addDoctor', {
    params: { department, doctor, detail, day }
  });
}

// 更新医生信息
export function updateDoctorService(department, doctor, newDepartment, newDoctor, newDetail, day) {
  return request.get('/admin/updateDoctor', {
    params: { department, doctor, newDepartment, newDoctor, newDetail, day }
  });
}

// 删除医生信息
export function deleteDoctorService(department, doctor, day) {
  return request.get('/admin/deleteDoctor', {
    params: { department, doctor, day }
  });
}

// 获取指定科室的所有医生
export function getDoctorsByDepartmentService(department) {
  return request.get('/admin/getDoctorsByDepartment', {
    params: { department }
  });
}

// 获取指定日期的医生排班情况
export function getDoctorScheduleService(day) {
  return request.get('/admin/getDoctorSchedule', {
    params: { day }
  });
}

// 统计指定医生的预约人数
export function countAppointmentsService(department, doctor, day, begin_time, end_time) {
  return request.get('/admin/countAppointments', {
    params: { department, doctor, day, begin_time, end_time }
  });
}
