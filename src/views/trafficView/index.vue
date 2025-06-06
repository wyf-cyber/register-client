<!-- 挂号流量图形化统计页面 -->
<script setup>
import { ref, onMounted, computed, reactive, nextTick, onUnmounted } from "vue";
import { useRouter } from "vue-router";
import PageHeader from "@/views/components/header.vue";
import CircleLoading from "@/views/components/circle_loading.vue";
import ShrinkableMenu from "@/views/navbar/menu.vue";
import { getUserInfoService, getUserAppointmentHistoryService } from "@/views/userinfo/api";
import { getDepartmentStatsService, getAppointmentTrendService, countSystemUsersService, countSystemAppointmentsService, getHotDoctorsService } from "@/views/trafficView/api";
import * as echarts from 'echarts';

// 定义状态变量
const router = useRouter();
const username = ref(sessionStorage.getItem("UserName") || "未登录");
const userRole = ref(sessionStorage.getItem("UserRole") === "admin" ? "管理员" : "普通用户");
const isAdmin = ref(sessionStorage.getItem("UserRole") === "admin");
const isCollapsed = ref(sessionStorage.getItem("sidebarCollapsed") === "true" ? true : false);
const loading = ref(true);
const showMobileMenu = ref(false);
const singleOpenName = ref(["user"]); // 控制菜单展开状态
const menuTheme = ref("dark"); // 菜单主题
const email = ref(sessionStorage.getItem("Email") || "未绑定");
const reserveRecords = ref([]);

// 菜单处理
const handleMenuChange = (name) => {
  router.push({ name });
};

const changeMenu = (name) => {
  handleMenuChange(name);
};

// 获取用户的预约记录
const fetchReserveRecords = async () => {
  loading.value = true;
  try {
    const response = await getUserAppointmentHistoryService(username.value);
    reserveRecords.value = response || [];
  } catch (error) {
    console.error("获取预约记录出错:", error);
  } finally {
    loading.value = false;
  }
};

// 格式化日期
const formatDate = (dateString) => {
  if (!dateString) return '';
  const date = new Date(dateString);
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
};

// 获取状态文本
const getStatusText = (status) => {
  const statusMap = {
    'pending': '待就诊',
    'completed': '已完成',
    'cancelled': '已取消'
  };
  return statusMap[status] || status;
};

// 获取状态样式类名
const getStatusClass = (status) => {
  return `status-${status}`;
};

// 退出登录
const handleLogout = () => {
  sessionStorage.clear();
  sessionStorage.setItem("isAuthenticated", "false");
  alert("已退出登录");
  router.push("/auth");
};

// 侧边栏折叠切换
const toggleCollapse = () => {
  isCollapsed.value = !isCollapsed.value;
  sessionStorage.setItem("sidebarCollapsed", isCollapsed.value);
};

const toggleMobileMenu = () => {
  showMobileMenu.value = !showMobileMenu.value;
};

// 根据路由设置初始菜单状态
onMounted(async () => {
  const currentRoute = router.currentRoute.value;
  if (currentRoute.matched.length > 1) {
    singleOpenName.value = [currentRoute.matched[0].name];
  }
  // 获取用户邮箱和预约记录
  loading.value = true;
  try {
    // 获取用户信息（包含邮箱）
    const userInfoResponse = await getUserInfoService(username.value);
    if (userInfoResponse) {  // 直接检查返回的邮箱字符串
      email.value = userInfoResponse;
    } else {
      email.value = '';  // 如果没有邮箱信息，设置为空字符串
    }
    
    // 获取预约记录
    await fetchReserveRecords();
  } catch (error) {
    console.error("加载数据出错:", error);
  } finally {
    loading.value = false;
  }
});

// 移动菜单开关处理
const handleMobileToggle = () => {
  showMobileMenu.value = !showMobileMenu.value;
};

// 添加计算属性，计算主内容区域的样式
const mainContentStyle = computed(() => {
  const sidebarWidth = isCollapsed.value ? 80 : 80;  // 
  return {
    marginLeft: `${sidebarWidth}px`,
    width: `calc(100% - ${sidebarWidth}px)`
  };
});

// 定义图表数据
const chartData = reactive({
  departmentStats: [],
  appointmentTrend: [],
  userCount: 0,
  appointmentCounts: [],
  hotDoctors: [] // 添加热门医生数据
});

const dateRange = reactive({
  startDate: formatDate(new Date(Date.now() - 30 * 24 * 60 * 60 * 1000)), // 默认30天前
  endDate: formatDate(new Date())
});

// 图表实例
const departmentChartRef = ref(null);
const trendChartRef = ref(null);
let departmentChart = null;
let trendChart = null;

// 获取统计数据
const fetchStatisticsData = async () => {
  loading.value = true;
  try {
    // 获取科室统计数据
    const deptStats = await getDepartmentStatsService(dateRange.startDate, dateRange.endDate);
    chartData.departmentStats = deptStats || [];
    
    // 获取热门医生数据
    const hotDoctorsData = await getHotDoctorsService(dateRange.startDate, dateRange.endDate);
    chartData.hotDoctors = hotDoctorsData || [];
    
    // 获取用户总数
    const userCountResponse = await countSystemUsersService();
    chartData.userCount = userCountResponse || 0;
    
    // 获取未来7天预约数量
    const appointmentCountsResponse = await countSystemAppointmentsService(formatDate(new Date()));
    chartData.appointmentCounts = appointmentCountsResponse || [];
    
    // 初始化图表
    initCharts();
  } catch (error) {
    console.error("获取统计数据出错:", error);
  } finally {
    loading.value = false;
  }
};

// 初始化图表
const initCharts = () => {
  nextTick(() => {
    // 初始化科室统计图表
    if (departmentChartRef.value) {
      departmentChart = echarts.init(departmentChartRef.value);
      const departmentNames = chartData.departmentStats.map(item => item.department);
      const appointmentCounts = chartData.departmentStats.map(item => item.count);
      
      departmentChart.setOption({
        title: {
          text: '各科室预约数量统计',
          left: 'center'
        },
        tooltip: {
          trigger: 'item',
          formatter: '{a} <br/>{b}: {c} ({d}%)'
        },
        legend: {
          orient: 'vertical',
          left: 'left',
          data: departmentNames
        },
        series: [
          {
            name: '预约数量',
            type: 'pie',
            radius: ['40%', '70%'],
            avoidLabelOverlap: false,
            itemStyle: {
              borderRadius: 10,
              borderColor: '#fff',
              borderWidth: 2
            },
            label: {
              show: false,
              position: 'center'
            },
            emphasis: {
              label: {
                show: true,
                fontSize: '18',
                fontWeight: 'bold'
              }
            },
            labelLine: {
              show: false
            },
            data: departmentNames.map((name, index) => {
              return {
                value: appointmentCounts[index],
                name: name
              };
            })
          }
        ]
      });
    }
    
    // 不再初始化热门医生图表，改为使用卡片式展示
  });
};

// 处理日期范围变化
const handleDateRangeChange = () => {
  fetchStatisticsData();
};

// 窗口大小变化时重新调整图表大小
const handleResize = () => {
  if (departmentChart) {
    departmentChart.resize();
  }
  if (trendChart) {
    trendChart.resize();
  }
};

// 组件挂载时获取数据
onMounted(async () => {
  await fetchStatisticsData();
  window.addEventListener('resize', handleResize);
});

// 组件卸载时移除事件监听
onUnmounted(() => {
  window.removeEventListener('resize', handleResize);
  if (departmentChart) {
    departmentChart.dispose();
  }
  if (trendChart) {
    trendChart.dispose();
  }
});
</script>

<template>
  <div class="layout">
    <PageHeader class="layout-header" />
    
    <!-- 新增布局容器 -->
    <div class="layout-container">
      <!-- 侧边栏 -->
      <div class="layout-sider" :class="{ collapsed: isCollapsed, 'mobile-open': showMobileMenu }">
        <ShrinkableMenu 
          :shrink="isCollapsed"
          :theme="menuTheme"
          :open-names="singleOpenName"
          :show-mobile-toggle="true"
          :show-user-panel="true"
          :show-shrink-button="true"
          :username="username"
          :userRole="userRole"
          :isAdmin="isAdmin"
          @on-change="changeMenu"
          @on-mobile-toggle="handleMobileToggle"
          @on-shrink="toggleCollapse"
        />
      </div>
      
      <!-- 页面内容 -->
      <div class="layout-main" :style="mainContentStyle">
        <div class="content-wrapper">
          <h1>挂号流量统计</h1>
          
          <!-- 日期选择器 -->
          <div class="date-filter">
            <div class="filter-item">
              <label>开始日期：</label>
              <input type="date" v-model="dateRange.startDate" @change="handleDateRangeChange" />
            </div>
            <div class="filter-item">
              <label>结束日期：</label>
              <input type="date" v-model="dateRange.endDate" @change="handleDateRangeChange" />
            </div>
          </div>
          
          <!-- 加载中提示 -->
          <div v-if="loading" class="loading-container">
            <CircleLoading />
            <span>加载中...</span>
          </div>
          
          <div v-else>
            <!-- 数据概览卡片 -->
            <div class="stats-overview">
              <div class="stat-card">
                <div class="stat-icon">
                  <i class="ivu-icon ios-people"></i>
                </div>
                <div class="stat-content">
                  <div class="stat-title">系统用户总数</div>
                  <div class="stat-value">{{ chartData.userCount }}</div>
                </div>
              </div>
              
              <div class="stat-card">
                <div class="stat-icon">
                  <i class="ivu-icon ios-calendar"></i>
                </div>
                <div class="stat-content">
                  <div class="stat-title">今日新增预约数</div>
                  <div class="stat-value">{{ chartData.appointmentCounts[0] || 0 }}</div>
                </div>
              </div>
              
              <div class="stat-card">
                <div class="stat-icon">
                  <i class="ivu-icon ios-trending-up"></i>
                </div>
                <div class="stat-content">
                  <div class="stat-title">未来7天预约总数</div>
                  <div class="stat-value">{{ chartData.appointmentCounts.reduce((sum, count) => sum + count, 0) }}</div>
                </div>
              </div>
            </div>
            
            <!-- 图表区域 -->
            <div class="charts-container">
              <!-- 科室统计图表 -->
              <div class="chart-wrapper">
                <div ref="departmentChartRef" class="chart"></div>
              </div>
              
              <!-- 热门医生展示区域 -->
              <div class="hot-doctors-wrapper">
                <h3 class="section-title">热门医生排行榜</h3>
                <div class="hot-doctors-list">
                  <div v-for="(doctor, index) in chartData.hotDoctors" :key="index" class="doctor-card">
                    <div class="rank-badge" :class="`rank-${index + 1}`">{{ index + 1 }}</div>
                    <div class="doctor-info">
                      <div class="doctor-name">{{ doctor.doctor }}</div>
                      <div class="appointment-count">
                        <span>预约量:</span>
                        <div class="progress-bar-container">
                          <div 
                            class="progress-bar" 
                            :style="{ width: `${Math.min(doctor.count / (chartData.hotDoctors[0]?.count || 1) * 100, 100)}%` }"
                          ></div>
                        </div>
                        <span class="count-label">{{ doctor.count }}</span>
                      </div>
                    </div>
                  </div>
                  <div v-if="chartData.hotDoctors.length === 0" class="empty-data">
                    暂无医生数据
                  </div>
                </div>
              </div>
            </div>
            
            <!-- 未来7天预约数量预测 -->
            <div class="forecast-section">
              <h2>未来7天预约数量预测</h2>
              <div class="forecast-bars">
                <div 
                  v-for="(count, index) in chartData.appointmentCounts" 
                  :key="index" 
                  class="forecast-bar-item"
                >
                  <div class="day-label">第{{ index + 1 }}天</div>
                  <div class="bar-container">
                    <div 
                      class="bar" 
                      :style="{ height: `${Math.max(count * 5, 20)}px` }"
                    >
                      <span class="bar-value">{{ count }}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="less" scoped>
.layout {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  width: 100%;
  overflow-x: hidden;
  background-color: #f5f7fa;

  /* 头部 */
  &-header {
    height: 60px;
    width: 100%;
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    z-index: 1000;
  }
  
  /* 新增的容器层 */
  &-container {
    display: flex;
    position: fixed;
    left: 0;
    right: 0;
    bottom: 0;
    flex-direction: row;
    margin-top: 60px;
    height: calc(100vh - 60px);
    width: 100%;
    background-color: #f5f7fa;
  }

  /* 侧边栏 */
  &-sider {
    width: 200px;
    height: 100%;
    top: 0;
    // margin-top: 60px;
    flex-shrink: 0;
    // background: #4f959d;
    background: #2daa9e;
    transition: all 0.8s ease;
    box-shadow: 2px 0 6px rgba(0,0,0,0.1);
    position: relative;

    &.collapsed {
      width: 80px;
    }
  }

  /* 主内容区域 */
  &-main {
    flex: 1;  
    padding: 20px;
    box-sizing: border-box;
    // margin-top: 60px;
    height: calc(100vh - 60px);
    overflow-y: auto;
    background: #f5f7fa;
  }
}

@media screen and (max-width: 768px) {
  .layout {
    &-container {
      flex-direction: column;
    }
    
    &-sider {
      width: 100% !important;
      height: auto;
      
      &.collapsed {
        display: none;
      }
      
      &.mobile-open {
        display: block;
      }
    }
  }
}

.sidebar-shrink-button {
  position: absolute;
  right: -15px;
  top: 50%;
  transform: translateY(-50%);
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #dedbdb;
  border-radius: 50%;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  cursor: pointer;
  z-index: 1001;
  transition: all 0.5s ease;
  
  &:hover {
    transform: translateY(-50%) scale(1.1);
    box-shadow: 0 3px 10px rgba(0, 0, 0, 0.2);
  }
}

.settings-container {
  display: flex;
  flex-wrap: wrap;
  gap: 30px;
  justify-content: space-between;
  margin-top: 20px;
}

.settings-left, .settings-right {
  flex: 1;
  min-width: 280px;
}

.divider {
  width: 1px;
  background-color: #e0e0e0;
  margin: 0 10px;
}

@media screen and (max-width: 768px) {
  .settings-container {
    flex-direction: column;
  }
  
  .divider {
    display: none;
  }
  
  .settings-left, .settings-right {
    width: 100%;
  }
}

h1 {
  margin-bottom: 30px;
  color: #343a40;
  text-align: center;
  font-size: 28px;
  font-weight: bold;
}

h2 {
  font-size: 20px;
  margin: 30px 0 20px;
  font-weight: bold;
}

.form-group,
.form-group-rightup,
.form-group-rightdown {
  margin-bottom: 20px;
  display: flex;
  flex-direction: column;
}

.form-group-rightdown {
  flex-direction: row;
  gap: 30px;
}

label {
  margin-bottom: 5px;
  font-weight: bold;
  color: #495057;
}

input {
  width: 100%;
  padding: 10px;
  border: 1px solid #ced4da;
  border-radius: 5px;
  font-size: 16px;
  outline: none;
  max-width: 400px;
}

input:focus {
  border-color: #007bff;
  box-shadow: 0 0 5px rgba(0, 123, 255, 0.5);
}

button {
  padding: 10px 15px;
  margin-top: 10px;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 5px;
  font-size: 16px;
  cursor: pointer;
  align-self: flex-start;
}

button:hover {
  background-color: #0056b3;
}

button:disabled {
  background-color: #6c757d;
  cursor: not-allowed;
}

.logout-btn,
.delete-btn {
  margin-top: 30px;
  padding: 10px 15px;
  font-size: 16px;
  background-color: #dc3545;
}

.logout-btn:hover,
.delete-btn:hover {
  background-color: #c82333;
}

.delete-btn {
  background-color: #6c757d;
}

.delete-btn:hover {
  background-color: #5a6268;
}

.modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
}

.modal-content {
  background: white;
  padding: 30px;
  border-radius: 12px;
  text-align: center;
  width: 90%;
  max-width: 400px;
  box-shadow: 0 6px 15px rgba(0, 0, 0, 0.2);
}

.modal-content h2 {
  font-size: 20px;
  margin-bottom: 20px;
  color: #343a40;
}

.modal-content input {
  width: 100%;
  padding: 10px;
  margin-top: 10px;
  border: 1px solid #ced4da;
  border-radius: 5px;
}

.modal-actions {
  margin-top: 20px;
  display: flex;
  justify-content: space-around;
}

.modal-actions button {
  padding: 8px 20px;
  font-size: 14px;
}

.content-wrapper {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

/* 用户信息卡片 */
.info-section, .record-section {
  margin-bottom: 30px;
}

.user-info-card {
  background: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.info-item {
  margin-bottom: 15px;
  display: flex;
  align-items: center;
}

.info-label {
  font-weight: bold;
  width: 100px;
  color: #606266;
}

.info-value {
  color: #303133;
}

.actions {
  margin-top: 20px;
  display: flex;
  gap: 15px;
}

.setting-btn {
  background-color: #409EFF;
}

.setting-btn:hover {
  background-color: #337ecc;
}

/* 挂号记录列表 */
.records-list {
  margin-top: 15px;
}

.record-item {
  background: white;
  border-radius: 8px;
  margin-bottom: 15px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.record-header {
  padding: 12px 15px;
  background-color: #f5f7fa;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #ebeef5;
}

.record-time {
  font-weight: bold;
  color: #303133;
}

.record-status {
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 12px;
}

.status-pending {
  background-color: #e6a23c;
  color: white;
}

.status-completed {
  background-color: #67c23a;
  color: white;
}

.status-cancelled {
  background-color: #909399;
  color: white;
}

.record-content {
  padding: 15px;
}

.record-info {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.info-row {
  display: flex;
  align-items: center;
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 50px;
}

.empty-records {
  text-align: center;
  color: #909399;
  padding: 30px;
  background: white;
  border-radius: 8px;
}

@media screen and (max-width: 768px) {
  .info-item {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .info-label {
    width: auto;
    margin-bottom: 5px;
  }
  
  .actions {
    flex-direction: column;
  }
  
  .actions button {
    width: 100%;
  }
}

.date-filter {
  display: flex;
  gap: 20px;
  width: 100%;
  margin-bottom: 30px;
  justify-content: center;
  flex-wrap: wrap;
}

.filter-item {
  display: flex;
  align-items: center;
  gap: 10px;
}

.filter-item label {
  width: 150px;
  font-weight: bold;
}

.filter-item input {
  padding: 8px 12px;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  font-size: 14px;
}

/* 数据概览卡片 */
.stats-overview {
  display: flex;
  gap: 20px;
  margin-bottom: 30px;
  flex-wrap: wrap;
}

.stat-card {
  flex: 1;
  min-width: 200px;
  background: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  gap: 15px;
  transition: transform 0.3s;
}

.stat-card:hover {
  transform: translateY(-5px);
}

.stat-icon {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  background: #2daa9e;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 24px;
}

.stat-content {
  flex: 1;
}

.stat-title {
  color: #606266;
  font-size: 14px;
  margin-bottom: 5px;
}

.stat-value {
  color: #303133;
  font-size: 24px;
  font-weight: bold;
}

/* 图表容器 */
.charts-container {
  display: flex;
  gap: 20px;
  margin-bottom: 30px;
  flex-wrap: wrap;
}

.chart-wrapper {
  flex: 1;
  min-width: 300px;
  background: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.chart {
  width: 100%;
  height: 400px;
}

/* 预测部分 */
.forecast-section {
  background: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.forecast-bars {
  display: flex;
  justify-content: space-around;
  align-items: flex-end;
  height: 200px;
  padding: 20px 0;
}

.forecast-bar-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 60px;
}

.day-label {
  margin-top: 10px;
  font-size: 14px;
  color: #606266;
}

.bar-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-end;
  height: 150px;
}

.bar {
  width: 40px;
  background: linear-gradient(to top, #2daa9e, #4ecdc4);
  border-radius: 4px 4px 0 0;
  position: relative;
  display: flex;
  justify-content: center;
}

.bar-value {
  position: absolute;
  top: -25px;
  font-weight: bold;
  color: #303133;
}

@media screen and (max-width: 768px) {
  .stats-overview {
    flex-direction: column;
  }
  
  .charts-container {
    flex-direction: column;
  }
  
  .forecast-bars {
    overflow-x: auto;
    justify-content: flex-start;
    padding-bottom: 20px;
  }
  
  .forecast-bar-item {
    min-width: 60px;
  }
}

/* 热门医生卡片样式 */
.hot-doctors-wrapper {
  flex: 1;
  min-width: 300px;
  background: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
}

.section-title {
  text-align: center;
  margin-bottom: 20px;
  color: #333;
  font-size: 18px;
  font-weight: bold;
}

.hot-doctors-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
  height: 360px;
  overflow-y: auto;
  padding: 5px;
}

.doctor-card {
  display: flex;
  align-items: center;
  padding: 15px;
  border-radius: 8px;
  background: #f9f9f9;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  transition: transform 0.2s ease;
  position: relative;
}

.doctor-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}

.rank-badge {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  color: white;
  margin-right: 15px;
}

.rank-1 {
  background: linear-gradient(135deg, #FFD700, #FFA500);
  box-shadow: 0 2px 8px rgba(255, 165, 0, 0.3);
  font-size: 16px;
}

.rank-2 {
  background: linear-gradient(135deg, #C0C0C0, #A9A9A9);
  box-shadow: 0 2px 8px rgba(169, 169, 169, 0.3);
  font-size: 16px;
}

.rank-3 {
  background: linear-gradient(135deg, #CD7F32, #A0522D);
  box-shadow: 0 2px 8px rgba(160, 82, 45, 0.3);
  font-size: 16px;
}

.rank-4, .rank-5 {
  background: #2daa9e;
  font-size: 14px;
}

.doctor-info {
  flex: 1;
}

.doctor-name {
  font-weight: bold;
  margin-bottom: 8px;
  font-size: 16px;
  color: #333;
}

.appointment-count {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 14px;
  color: #666;
}

.progress-bar-container {
  flex: 1;
  height: 12px;
  background: #eee;
  border-radius: 10px;
  overflow: hidden;
  position: relative;
}

.progress-bar {
  height: 100%;
  background: linear-gradient(to right, #2daa9e, #4ecdc4);
  border-radius: 10px;
}

.count-label {
  font-size: 12px;
  color: #333;
  font-weight: bold;
  min-width: 30px;
  text-align: right;
}

.empty-data {
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #999;
  font-size: 16px;
}
</style>

