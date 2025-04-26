<script setup>
import { ref, onMounted, computed, inject, provide } from "vue";
import { useRouter } from "vue-router";
import CryptoJS from "crypto-js";
import { loginService, updateUserNameService, updatePasswordService, deleteAccountService, updateEmailService } from "@/views/userSetting/api";
import PageHeader from "@/views/components/header.vue";
import CircleLoading from "@/views/components/circle_loading.vue";
import ShrinkableMenu from "@/views/navbar/menu.vue";
import Messages from "@/views/components/messages.vue";
import { ElMessage } from "element-plus";

// 使用let声明，允许后续修改
let showNotification = inject('showNotification');

// 如果注入失败，使用默认实现
if (!showNotification) {
  console.warn('未能注入showNotification方法，将使用默认方法');
  showNotification = (message, type) => {
    ElMessage({
      message,
      type,
      duration: 3000
    });
  };
}

// 定义状态变量
const newUsername = ref("");
const newPassword = ref("");
const newEmail = ref("");
const confirmPassword = ref("");
const showConfirmationModal = ref(false);
const actionType = ref("");
const router = useRouter();
const username = ref(sessionStorage.getItem("UserName") || "未登录");
const userRole = ref(window.sessionStorage.getItem('UserRole') === "admin" ? "管理员" : "普通用户");
const isAdmin = ref(window.sessionStorage.getItem('UserRole') === "admin");
const isCollapsed = ref(sessionStorage.getItem("sidebarCollapsed") === "true" ? true : false);
const loading = ref(false);
const showMobileMenu = ref(false);
const singleOpenName = ref(["user"]); // 控制菜单展开状态
const menuTheme = ref("dark"); // 菜单主题

/**
 * 侧边栏菜单数据
 * @name 菜单名称，用于路由跳转
 * @title 菜单标题，用于显示在菜单上
 * @icon 菜单图标，用于显示在菜单上
 * @children 子菜单，用于显示在折叠菜单中
 * @active-name 当前激活的菜单名称，有高亮效果
 * @open-names 当前展开的菜单名称，有展开效果
 */

// 管理员菜单列表
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

// 用户菜单列表
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

// 表单验证
const validateForm = (type) => {
  if (type === "username") {
    if (!newUsername.value) {
      showNotification("用户名不能为空", "warning");
      return false;
    }
    if (newUsername.value.length < 3) {
      showNotification("用户名长度需至少3个字符", "warning");
      return false;
    }
  }
  if (type === "password") {
    if (!newPassword.value) {
      showNotification("密码不能为空", "warning");
      return false;
    }
    if (newPassword.value.length < 6) {
      showNotification("密码长度需至少6个字符", "warning");
      return false;
    }
  }
  if (type === "email") {
    if (!newEmail.value) {
      showNotification("邮箱不能为空", "warning");
      return false;
    }
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(newEmail.value)) {
      showNotification("请输入有效的邮箱地址", "warning");
      return false;
    }
  }
  return true;
};

// 确认操作处理
const handleConfirm = async () => {
  if (!confirmPassword.value) {
    showNotification("请输入当前密码", "warning");
    return;
  }
  loading.value = true;
  const encryptedPassword = CryptoJS.SHA256(confirmPassword.value).toString();
  try {
    const response = await loginService(sessionStorage.getItem("UserName"), encryptedPassword);
    if (response.success) {
      if (actionType.value === "username") {
        const res = await updateUserNameService(sessionStorage.getItem("UserName"), newUsername.value);
        if (res === "Invalid username") {
          showNotification("用户名无效或已存在", "error");
        } else {
          sessionStorage.setItem("UserName", newUsername.value);
          username.value = newUsername.value;
          showNotification("用户名修改成功！", "success");
          closeModal();
        }
      } else if (actionType.value === "password") {
        const newEncryptedPassword = CryptoJS.SHA256(newPassword.value).toString();
        const res = await updatePasswordService(sessionStorage.getItem("UserName"), newEncryptedPassword);
        if (res === "Invalid username") {
          showNotification("用户名无效", "error");
        } else {
          showNotification("密码修改成功！", "success");
          closeModal();
        }
      } else if (actionType.value === "email") {
        const res = await updateEmailService(sessionStorage.getItem("UserName"), newEmail.value);
        if (res === "Invalid username") {
          showNotification("用户名无效", "error");
        } else {
          sessionStorage.setItem("Email", newEmail.value);
          showNotification("邮箱绑定成功！", "success");
          closeModal();
        }
      } else if (actionType.value === "delete") {
        const res = await deleteAccountService(sessionStorage.getItem("UserName"));
        if (res === "delete successfully") {
          showNotification(`账号 ${sessionStorage.getItem("UserName")} 注销成功`, "success");
          sessionStorage.clear();
          sessionStorage.setItem("isAuthenticated", "false");
          router.push("/login");
        } else {
          showNotification("账号注销失败，请重试", "error");
        }
      }
    } else {
      showNotification("当前密码错误，请重试", "error");
    }
  } catch (error) {
    showNotification(`操作失败：${error.message || "未知错误"}`, "error");
  } finally {
    loading.value = false;
  }
};

// 模态框控制
const openModal = (type) => {
  if (!validateForm(type)) return;
  actionType.value = type;
  showConfirmationModal.value = true;
};

const closeModal = () => {
  confirmPassword.value = "";
  showConfirmationModal.value = false;
};

// 退出登录
const handleLogout = () => {
  sessionStorage.clear();
  sessionStorage.setItem("isAuthenticated", "false");
  showNotification("已退出登录", "info");
  router.push("/login");
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
onMounted(() => {
  const currentRoute = router.currentRoute.value;
  if (currentRoute.matched.length > 1) {
    singleOpenName.value = [currentRoute.matched[0].name];
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
    <Messages />
    <div class="layout-container">
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
          @on-mobile-toggle="toggleMobileMenu"
          @on-shrink="toggleCollapse"
        />
      </div>
      <!-- 页面内容 -->
      <div class="layout-main" :style="mainContentStyle">
    <div class="soft-card">
      <div class="card-header">
        <h1>个人账号设置</h1>
      </div>
      <div class="card-body">
        <div class="settings-container">
          <div class="card-item">
            <h2 class="section-title">账号设置</h2>
            <div class="form-group">
              <label for="username">修改用户名</label>
              <input id="username" v-model="newUsername" type="text" placeholder="输入新用户名" maxlength="20" class="input-field" />
              <button class="btn-soft" @click="openModal('username')" :disabled="loading">修改用户名</button>
            </div>
            <div class="form-group">
              <label for="password">修改密码</label>
              <input id="password" v-model="newPassword" type="password" placeholder="输入新密码" maxlength="20" class="input-field" />
              <button class="btn-soft" @click="openModal('password')" :disabled="loading">修改密码</button>
            </div>
            <div class="form-group">
              <label for="email">绑定邮箱号</label>
              <input id="email" v-model="newEmail" type="text" placeholder="输入新邮箱号" maxlength="40" class="input-field" />
              <button class="btn-soft" @click="openModal('email')" :disabled="loading">绑定邮箱号</button>
            </div>
            <div class="form-group form-group--actions">
              <button class="btn-outline" @click="handleLogout" :disabled="loading">退出登录</button>
              <button class="btn-outline" @click="openModal('delete')" :disabled="loading">注销账号</button>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div v-if="showConfirmationModal" class="modal">
      <div class="modal-content">
        <h2>确认修改</h2>
        <p>请输入当前密码以确认操作</p>
        <input v-model="confirmPassword" type="password" placeholder="输入当前密码" class="input-field" />
        <div class="modal-actions">
          <button class="btn-soft" @click="handleConfirm" :disabled="loading">
            <CircleLoading v-if="loading" /> {{ loading ? "处理中..." : "确认" }}
          </button>
          <button class="btn-outline" @click="closeModal" :disabled="loading">取消</button>
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


.layout-main {
  display: flex;
  justify-content: center;
  padding: 60px 20px;
  min-height: 100vh;
  background: #f0f8ff;
}

.soft-card {
  background: #ffffff;
  border-radius: 24px;
  box-shadow: 0 12px 32px rgba(116, 185, 255, 0.15);
  overflow: hidden;
  width: 100%;
  max-width: 1000px;
  animation: fadeInUp 0.6s ease-out;
}

.card-header {
  background: linear-gradient(135deg, #6495ed, #9370db);
  padding: 40px 30px;
  text-align: center;
  color: #ffffff;
  border-radius: 24px 24px 0 0;
  box-shadow: 0 4px 16px rgba(100, 149, 237, 0.1);
}

.card-header h1 {
  margin: 0;
  font-size: 32px;
  font-weight: 600;
  letter-spacing: 0.8px;
}

.card-body {
  padding: 40px 50px;
  display: grid;
  gap: 40px;
}

.settings-container {
  flex-direction: column;
  align-items: stretch;
  gap: 30px;
}

.card-item {
  flex: none;
  min-width: auto;
  width: 100%;
  max-width: 600px;
  margin: 0 auto; /* 水平居中 */
}

.section-title {
  text-align: center; /* 标题居中 */
  border-left: none; /* 移除左侧边框 */
  padding-left: 0;
  border-bottom: 4px solid #74b9ff; /* 改为底部边框 */
  padding-bottom: 8px;
  margin-bottom: 24px;
}

.form-group {
  margin-bottom: 24px;
}

.form-group label {
  display: block;
  margin-bottom: 12px;
  font-size: 16px;
  color: #4a4a4a;
  font-weight: 500;
}

.input-field {
  width: 100%;
  padding: 14px 20px;
  border: 2px solid #e0e8ff;
  border-radius: 18px;
  font-size: 16px;
  transition: all 0.3s ease;
  background: #f5f9ff;
}

.input-field:focus {
  outline: none;
  border-color: #74b9ff;
  box-shadow: 0 0 16px rgba(116, 185, 255, 0.2);
  background: #ffffff;
}

.divider {
  display: none;
}

.btn-soft {
  width: fit-content;
  margin-top: 16px;
  padding: 14px 32px;
  border: none;
  border-radius: 28px;
  background: linear-gradient(135deg, #74b9ff, #a29bfe);
  color: white;
  font-size: 16px;
  font-weight: 500;
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.3s ease;
  box-shadow: 0 4px 12px rgba(116, 185, 255, 0.2);
}

.btn-soft:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 24px rgba(116, 185, 255, 0.3);
}

.btn-outline {
  margin-top: 16px;
  padding: 14px 32px;
  border: 2px solid #e0e8ff;
  border-radius: 28px;
  background: transparent;
  color: #1a237e;
  font-size: 16px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-outline:hover {
  background: #e0e8ff;
  border-color: #74b9ff;
  color: #1a237e;
}

.modal {
  display: flex;
  align-items: center;
  justify-content: center;
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100vh;
  background: rgba(26, 35, 126, 0.5);
  animation: fadeIn 0.4s ease;
}

.modal-content {
  background: #ffffff;
  padding: 40px 50px;
  border-radius: 24px;
  box-shadow: 0 16px 48px rgba(116, 185, 255, 0.2);
  text-align: center;
  max-width: 500px;
  width: 90%;
}

.modal-actions {
  margin-top: 30px;
  display: flex;
  justify-content: center;
  gap: 24px;
}

/* 动画优化 */
@keyframes fadeInUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

/* 响应式调整 */
@media (max-width: 768px) {
  .settings-container {
    flex-direction: column;
    gap: 30px;
  }
  
  .divider {
    display: none;
    width: 100%;
    height: 2px;
    background: #e0e8ff;
  }
  
  .card-body {
    padding: 30px 20px;
  }
}

/* 新增样式 */
.form-group--actions {
  display: flex;
  justify-content: center;
  gap: 24px;
  margin-top: 32px;
}

.btn-outline {
  margin-top: 0;
}

@media (max-width: 480px) {
  .form-group--actions {
    flex-direction: column;
    align-items: center;
    gap: 16px;
  }
}
</style>
