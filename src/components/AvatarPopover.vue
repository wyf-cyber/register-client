<template>
  <el-popover trigger="hover" placement="bottom" width="160" popper-class="simple-user-popup">
    <div class="popup-content">
      <div class="header">
        <el-avatar :src="avatarUrl" size="48" />
        <div class="popup-line">{{ username || '用户' }}</div>
        <div class="popup-line">{{ userRole || '角色' }}</div>
      </div>
      <div class="stats">
        <div class="stat-item">
          <el-icon size="16"><Bell /></el-icon> 待支付：¥{{ totalDue }}
        </div>
        <div class="stat-item">
          <el-icon size="16"><Calendar /></el-icon> 待就诊：{{ appointmentCount }} 次
        </div>
        <div class="stat-item">
          <el-icon size="16"><Document /></el-icon> 新报告：{{ newReportCount }} 份
        </div>
      </div>
      <div class="actions-grid">
        <el-button type="text" @click="goToAppointments">我的预约</el-button>
        <el-button type="text" @click="goToReports">个人信息</el-button>
      </div>
      <div class="actions-grid">
        <el-button type="text" @click="editProfile">账号设置</el-button>
        <el-button type="text" @click="goToAssits">AI 助手</el-button>
      </div>
      <div class="logout-wrapper">
        <el-button type="danger" plain size="small" @click="handleLogout">退出登录</el-button>
      </div>
    </div>
    <template #reference>
      <div class="user-avatar">
        <el-icon size="24"><User /></el-icon>
      </div>
    </template>
  </el-popover>
</template>

<script setup>
import { Bell, Calendar, Document, User } from '@element-plus/icons-vue'
// 根据你项目实际情况去拿用户状态
import { useRouter } from "vue-router";

const props = defineProps({
  username:     { type: String, default: '' },
  userRole:     { type: String, default: 'user' },
})
const router = useRouter()
function goToAppointments() { router.push({ name: 'reserverecords' }) }
function goToReports()      { router.push({ name: 'profile' }) }
function goToAssits()     { router.push({ name: 'assistant' }) }
function editProfile()      { router.push({ name: 'settings' }) }
function handleLogout() {
  sessionStorage.clear()
  sessionStorage.setItem('isAuthenticated', 'false')
  router.push('/login')
}
</script>

<style scoped>
.simple-user-popup {
  padding: 8px;
  border-radius: 4px;
  box-shadow: 0 2px 6px rgba(0,0,0,0.12);
}
.popup-content {
  text-align: center;
}
.popup-line {
  margin: 4px 0;
  font-size: 14px;
  color: #303133;
}
.actions {
  display: flex;
  justify-content: space-between;
}
.actions .el-button {
  padding: 0;
  font-size: 13px;
  color: #409eff;
}
.actions-grid {
  display: grid;
  grid-template-columns: repeat(2, 2fr);
  gap: 4px;
}
.actions-grid .el-button {
  padding: 4px 0;
  font-size: 13px;
  color: #409EFF;
  text-align: left;
}
.stats {
  display: flex;
  flex-direction: column;
  margin: 8px 0;
}
.stat-item {
  display: flex;
  align-items: center;
  margin-bottom: 4px;
}
.stat-item .el-icon {
  margin-right: 6px;
}
.logout-wrapper {
  margin-top: 8px;
  text-align: center;    /* 按钮居中 */
}
</style>
