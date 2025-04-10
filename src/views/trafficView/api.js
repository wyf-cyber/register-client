import request from '@/utils/request';

// 获取系统用户总数
export function countSystemUsersService() {
  return request.get('/admin/getUserCount');
}

// 获取今日新增预约数量
export function countTodayAppointmentsService() {
  return request.get('/admin/getTodayAppointments');
}

// 获取未来7天的预约数量
export function countSystemAppointmentsService(day) {
  return request.get('/admin/countSystemAppointments', {
    params: { day }
  });
}

// 获取各科室的预约统计数据
export function getDepartmentStatsService(startDate, endDate) {
  return request.get('/admin/getDepartmentStats', {
    params: { startDate, endDate }
  });
}

// 获取热门医生名单和当前预约人数
export function getHotDoctorsService(startDate, endDate) {
  return request.get('/admin/getTopDoctors', {
    params: { startDate, endDate }
  });
}

// 获取指定时间段内的预约趋势数据
export function getAppointmentTrendService(startDate, endDate) {
  return request.get('/admin/getAppointmentTrend', {
    params: { startDate, endDate }
  });
}