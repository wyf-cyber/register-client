<script setup>
import { ref, onMounted, computed } from "vue";
import { useRouter } from "vue-router";
import PageHeader from "@/views/components/header.vue";
import CircleLoading from "@/views/components/circle_loading.vue";
import ShrinkableMenu from "@/views/navbar/menu.vue";
import { getUserInfoService, getUserAppointmentHistoryService } from "@/views/userinfo/api";

// 定义状态变量
const router = useRouter();
const username = ref(sessionStorage.getItem("UserName") || "未登录");
const userRole = ref(sessionStorage.getItem("UserRole") === "admin" ? "管理员" : "普通用户");
const isAdmin = ref(sessionStorage.getItem("UserRole") === "admin");
const isCollapsed = ref(sessionStorage.getItem("sidebarCollapsed") === "true" ? true : false);
const loading = ref(false);
const showMobileMenu = ref(false);
const singleOpenName = ref(["user"]); // 控制菜单展开状态
const menuTheme = ref("dark"); // 菜单主题
const email = ref(sessionStorage.getItem("Email") || "未绑定");
const reserveRecords = ref([]);
/**
 * 侧边栏菜单数据
 * @name 菜单名称，用于路由跳转
 * @title 菜单标题，用于显示在菜单上
 * @icon 菜单图标，用于显示在菜单上
 * @children 子菜单，用于显示在折叠菜单中
 * @active-name 当前激活的菜单名称，有高亮效果
 * @open-names 当前展开的菜单名称，有展开效果
 */

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
          <h1>个人资料</h1>
          
          <!-- 上半部分：账户信息 -->
          <div class="info-section">
            <h2>账户信息</h2>
            <div class="user-info-card">
              <div class="info-item">
                <span class="info-label">用户名：</span>
                <span class="info-value">{{ username }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">用户权限：</span>
                <span class="info-value">{{ userRole }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">绑定邮箱：</span>
                <span class="info-value">{{ email || '暂未绑定邮箱' }}</span>
              </div>
            </div>
          </div>

          <!-- 下半部分：预约挂号记录 -->
          <div class="record-section">
            <h2>预约挂号历史记录</h2>
            <div v-if="loading" class="loading-container">
              <CircleLoading />
              <span>加载中...</span>
            </div>
            <div v-else-if="reserveRecords.length === 0" class="empty-records">
              暂无预约挂号记录
            </div>
            <div v-else class="records-list">
              <div v-for="(record, index) in reserveRecords" :key="index" class="record-item">
                <div class="record-header">
                  <span class="record-time">{{ formatDate(record.appointmentTime) }}</span>
                  <span :class="['record-status', getStatusClass(record.status)]">{{ getStatusText(record.status) }}</span>
                </div>
                <div class="record-content">
                  <div class="record-info">
                    <div class="info-row">
                      <span class="info-label">医生：</span>
                      <span class="info-value">{{ record.doctorName }}</span>
                    </div>
                    <div class="info-row">
                      <span class="info-label">科室：</span>
                      <span class="info-value">{{ record.department }}</span>
                    </div>
                    <div class="info-row">
                      <span class="info-label">预约时间：</span>
                      <span class="info-value">{{ formatDate(record.appointmentTime) }} {{ record.timeSlot }}</span>
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
  transition: all 0.3s ease;
  
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
  margin-bottom: 20px;
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
  padding: 30px;
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
</style>

