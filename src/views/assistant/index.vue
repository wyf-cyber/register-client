<!-- AI问诊助手页面，仿照主流AI页面提供AI对话服务，不提供选择AI对话记录的功能 -->
<script setup>
import { ref, onMounted, computed, reactive, nextTick, onUnmounted } from "vue";
import { useRouter } from "vue-router";
import { marked } from 'marked'; // 导入marked库用于Markdown渲染
import DOMPurify from 'dompurify'; // 导入DOMPurify用于防止XSS攻击
import PageHeader from "@/views/components/header.vue";
import CircleLoading from "@/views/components/circle_loading.vue";
import ShrinkableMenu from "@/views/navbar/menu.vue";
import { getUserInfoService, getUserAppointmentHistoryService } from "@/views/userinfo/api";
import { getAIResponseService } from "@/views/assistant/api";
import { User, ChatLineRound, Delete, Position } from '@element-plus/icons-vue';


// 定义状态变量
const router = useRouter();
const username = ref(sessionStorage.getItem("UserName") || "未登录");
const userRole = ref(sessionStorage.getItem("UserRole") === "admin" ? "管理员" : "普通用户");
const isCollapsed = ref(sessionStorage.getItem("sidebarCollapsed") === "true" ? true : false);
const loading = ref(true);
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


 const adminMenuList = ref([
  {
    name: "adminbusinesscenter",
    title: "用户流量统计",
    icon: "ios-document",
    children: [
      { name: "trafficView", title: "用户流量统计", icon: "ios-document" },
    ],
  },
  {
    name: "adminusercenter",
    title: "用户中心",
    icon: "ios-person",
    children: [
      { name: "profile", title: "个人资料", icon: "ios-person" },
      { name: "settings", title: "账号设置", icon: "ios-settings" },
    ],
  },
]);

const userMenuList = ref([
  {
    name: "registercenter",
    title: "预约挂号",
    icon: "ios-calendar",
    children: [
      { name: "register", title: "预约挂号", icon: "ios-navigate" },
      { name: "evaluate", title: "医生评价", icon: "ios-search" },
    ],
  },
  {
    name: "usercenter",
    title: "用户中心",
    icon: "ios-person",
    children: [
      { name: "reserverecords", title: "预约记录", icon: "ios-calendar" },
      { name: "profile", title: "个人资料", icon: "ios-contact" },
      { name: "settings", title: "账号设置", icon: "ios-settings" },
    ],
  },
  {
    name: "assistant",
    title: "AI问诊助手",
    icon: "ios-chatbubble",
    children: [
      { name: "assistant", title: "AI问诊助手", icon: "ios-chatbubble" },
    ],
  },
]);

// 根据用户角色选择菜单类型
const menuList = ref(userRole.value === "管理员" ? adminMenuList.value : userMenuList.value);

// 菜单处理
const handleMenuChange = (name) => {
  router.push({ name });
};

const changeMenu = (name) => {
  handleMenuChange(name);
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
    // await fetchReserveRecords();
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

// AI聊天相关状态
const chatHistory = ref([
  { role: 'assistant', content: '您好！我是您的AI问诊助手。请问有什么健康问题需要咨询？' }
]);
const userInput = ref('');
const isTyping = ref(false);
const messageRef = ref(null);

// 发送消息
const sendMessage = async () => {
  if (!userInput.value.trim()) return;
  
  // 添加用户消息到聊天历史
  chatHistory.value.push({
    role: 'user',
    content: userInput.value
  });
  
  // 清空输入框
  const userMessage = userInput.value;
  userInput.value = '';
  
  // 显示AI正在输入状态
  isTyping.value = true;
  
  // 滚动到最新消息
  scrollToBottom();

  try {
    // 调用后端API获取AI响应
    const response = await getAIResponseService(userMessage);
    
    // 添加AI响应到聊天历史
    chatHistory.value.push({
      role: 'assistant',
      content: response
    });
  } catch (error) {
    console.error("AI响应获取失败:", error);
    // 添加错误消息
    chatHistory.value.push({
      role: 'assistant',
      content: '很抱歉，我暂时无法回答您的问题。请稍后再试或联系客服。'
    });
  } finally {
    isTyping.value = false;
    
    // 滚动到最新消息
    scrollToBottom();
  }
};

// 处理输入框回车事件
const handleKeyDown = (e) => {
  if (e.key === 'Enter' && !e.shiftKey) {
    e.preventDefault();
    sendMessage();
  }
};

// 滚动到最新消息
const scrollToBottom = () => {
  nextTick(() => {
    if (messageRef.value) {
      messageRef.value.scrollTop = messageRef.value.scrollHeight;
    }
  });
};

// 清空聊天历史
const clearChat = () => {
  chatHistory.value = [
    { role: 'assistant', content: '您好！我是您的AI问诊助手。请问有什么健康问题需要咨询？' }
  ];
};

// 组件挂载后滚动到底部
onMounted(() => {
  scrollToBottom();
});

// ios图标设置

// 定义渲染Markdown的函数
const renderMarkdown = (text) => {
  // 使用marked转换Markdown为HTML，并使用DOMPurify清理HTML以防止XSS攻击
  return DOMPurify.sanitize(marked.parse(text));
};

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
          :menu-list="menuList"
          :theme="menuTheme"
          :open-names="singleOpenName"
          :show-mobile-toggle="true"
          :show-user-panel="true"
          :show-shrink-button="true"
          :username="username"
          :userRole="userRole"
          @on-change="changeMenu"
          @on-mobile-toggle="handleMobileToggle"
          @on-shrink="toggleCollapse"
        />
      </div>
      
      <!-- 页面内容 -->
      <div class="layout-main" :style="mainContentStyle">
        <div class="ai-chat-container">
          <div class="chat-header">
            <h1>AI问诊助手</h1>
            <p class="chat-description">
              您的专业医疗咨询助手，为您解答健康问题，提供初步建议。请注意：AI建议不能替代专业医生的诊断。
            </p>
          </div>
          
          <!-- 对话区域 -->
          <div class="chat-messages" ref="messageRef">
            <div 
              v-for="(message, index) in chatHistory" 
              :key="index" 
              :class="['message', message.role === 'user' ? 'user-message' : 'assistant-message']"
            >
              <div class="message-avatar">
                <div class="avatar-icon">
                  <!-- 使用Element Plus的图标组件 -->
                  <el-icon v-if="message.role === 'user'"><User /></el-icon>
                  <el-icon v-else><ChatLineRound /></el-icon>
                </div>
              </div>
              <div class="message-content">
                <div class="message-sender">{{ message.role === 'user' ? '我' : 'AI问诊助手' }}</div>
                <!-- 用户消息保持纯文本，AI消息使用Markdown渲染 -->
                <div v-if="message.role === 'user'" class="message-text">{{ message.content }}</div>
                <div v-else class="message-text markdown-content" v-html="renderMarkdown(message.content)"></div>
              </div>
            </div>
            
            <!-- AI正在输入提示 -->
            <div v-if="isTyping" class="typing-indicator">
              <div class="typing-dot"></div>
              <div class="typing-dot"></div>
              <div class="typing-dot"></div>
              <span>AI助手正在思考...</span>
            </div>
          </div>
          
          <!-- 输入区域 -->
          <div class="chat-input-container">
            <div class="input-wrapper">
              <textarea 
                v-model="userInput" 
                class="chat-input" 
                placeholder="请描述您的健康问题..."
                @keydown="handleKeyDown"
                rows="3"
              ></textarea>
              <div class="input-actions">
                <button @click="clearChat" class="clear-btn" title="清空对话">
                  <el-icon><Delete /></el-icon> 清空
                </button>
                <button @click="sendMessage" class="send-btn" :disabled="!userInput.trim() || isTyping">
                  <el-icon><Position /></el-icon> 发送
                </button>
              </div>
            </div>
          </div>
          
          <!-- 免责声明 -->
          <div class="disclaimer">
            <p>免责声明：AI问诊助手提供的建议仅供参考，不构成医疗诊断。如有健康问题，请咨询专业医生。</p>
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

/* AI聊天界面样式 */
.ai-chat-container {
  max-width: 900px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  height: 100%;
  background-color: #fff;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.chat-header {
  padding: 20px;
  border-bottom: 1px solid #f0f0f0;
  text-align: center;
}

.chat-header h1 {
  margin-bottom: 10px;
  color: #2daa9e;
  font-size: 24px;
}

.chat-description {
  color: #606266;
  font-size: 14px;
  line-height: 1.5;
}

.chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 16px;
  height: calc(100% - 240px);
  min-height: 300px;
}

.message {
  display: flex;
  // margin-bottom: 16px;
  max-width: 80%;
}

.user-message {
  align-self: flex-end;
  flex-direction: row-reverse;
}

.assistant-message {
  align-self: flex-start;
}

.message-avatar {
  margin: 0 12px;
}

.avatar-icon {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
}

.user-message .avatar-icon {
  background-color: #409EFF;
  color: white;
}

.assistant-message .avatar-icon {
  background-color: #2daa9e;
  color: white;
}

.message-content {
  background: #f7f7f7;
  padding: 12px;
  border-radius: 12px;
  position: relative;
}

.user-message .message-content {
  background: #ecf5ff;
  border-radius: 12px 12px 0 12px;
}

.assistant-message .message-content {
  background: #f0f9eb;
  border-radius: 12px 12px 12px 0;
}

.message-sender {
  font-weight: bold;
  margin-bottom: 4px;
  color: #303133;
  font-size: 14px;
}

.message-text {
  color: #606266;
  line-height: 1.6;
  white-space: pre-wrap;
}

.typing-indicator {
  display: flex;
  align-items: center;
  padding: 12px;
  background: #f5f7fa;
  border-radius: 12px;
  width: fit-content;
  margin-left: 64px;
}

.typing-dot {
  width: 8px;
  height: 8px;
  background: #2daa9e;
  border-radius: 50%;
  margin-right: 6px;
  animation: typingAnimation 1s infinite ease-in-out;
}

.typing-dot:nth-child(1) {
  animation-delay: 0s;
}

.typing-dot:nth-child(2) {
  animation-delay: 0.2s;
}

.typing-dot:nth-child(3) {
  animation-delay: 0.4s;
}

@keyframes typingAnimation {
  0% { transform: translateY(0); }
  50% { transform: translateY(-5px); }
  100% { transform: translateY(0); }
}

.chat-input-container {
  padding: 20px;
  border-top: 1px solid #f0f0f0;
}

.input-wrapper {
  display: flex;
  flex-direction: column;
  background: #f5f7fa;
  border-radius: 8px;
  padding: 10px;
}

.chat-input {
  width: 100%;
  border: none;
  background: transparent;
  resize: none;
  outline: none;
  padding: 8px;
  font-size: 16px;
  color: #606266;
  font-family: inherit;
}

.input-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 8px;
}

.send-btn, .clear-btn {
  padding: 8px 16px;
  border-radius: 4px;
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 6px;
  cursor: pointer;
  transition: all 0.3s;
}

.send-btn {
  background: #2daa9e;
  color: white;
  border: none;
}

.send-btn:hover {
  background: #258f85;
}

.send-btn:disabled {
  background: #a0cfca;
  cursor: not-allowed;
}

.clear-btn {
  background: #2daa9e;
  color: #fff;
  border: none;
}

.clear-btn:hover {
  background: #258f85;
}

.disclaimer {
  padding: 12px 20px;
  background: #fdf6ec;
  border-top: 1px solid #faecd8;
  font-size: 12px;
  color: #e6a23c;
  text-align: center;
}

@media screen and (max-width: 768px) {
  .message {
    max-width: 90%;
  }
  
  .chat-messages {
    height: calc(100% - 220px);
    min-height: 200px;
  }
  
  .avatar-icon {
    width: 32px;
    height: 32px;
    font-size: 16px;
  }
  
  .input-actions {
    flex-direction: row;
  }
}

/* 添加Markdown内容的样式 */
:deep(.markdown-content) {
  h1, h2, h3, h4, h5, h6 {
    margin-top: 12px;
    margin-bottom: 1px;
    font-weight: 600;
    line-height: 1.25;
  }
  
  h1 {
    font-size: 20px;
  }
  
  h2 {
    font-size: 18px;
  }
  
  h3 {
    font-size: 16px;
  }
  
  p {
    margin-bottom: 3px;
  }
  
  ul, ol {
    padding-left: 20px;
    margin-bottom: 3px;
  }
  
  li {
    margin-bottom: 3px;
  }
  
  code {
    background-color: rgba(0, 0, 0, 0.05);
    padding: 2px 4px;
    border-radius: 3px;
    font-family: 'Courier New', Courier, monospace;
  }
  
  pre {
    background-color: rgba(0, 0, 0, 0.05);
    padding: 8px;
    border-radius: 4px;
    overflow-x: auto;
    margin-bottom: 3px;
  }
  
  pre code {
    background-color: transparent;
    padding: 0;
  }
  
  blockquote {
    border-left: 4px solid #b4b4b4;
    padding-left: 10px;
    color: #666;
    margin-bottom: 3px;
  }
  
  table {
    border-collapse: collapse;
    width: 100%;
    margin-bottom: 3px;
  }
  
  th, td {
    border: 1px solid #ddd;
    padding: 6px 10px;
  }
  
  th {
    background-color: rgba(0, 0, 0, 0.05);
  }
  
  a {
    color: #2daa9e;
    text-decoration: none;
  }
  
  a:hover {
    text-decoration: underline;
  }
  
  img {
    max-width: 100%;
    border-radius: 4px;
  }
}
</style>

