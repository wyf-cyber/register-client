<script setup>
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import CryptoJS from "crypto-js";
import { loginService, updateUserNameService, updatePasswordService, deleteAccountService, updateEmailService } from "@/views/userSetting/api";
import PageHeader from "@/views/components/header.vue";
import CircleLoading from "@/views/components/circle_loading.vue";
import { ElMenu, ElSubMenu, ElMenuItem, ElIcon } from "element-plus";
import { User, Setting, Operation, ArrowRight, ArrowLeft } from "@element-plus/icons-vue";
import ShrinkableMenu from "@/views/navbar/menu.vue";

// 定义状态变量
const newUsername = ref("");
const newPassword = ref("");
const newEmail = ref("");
const confirmPassword = ref("");
const showConfirmationModal = ref(false);
const actionType = ref("");
const router = useRouter();
const username = ref(sessionStorage.getItem("UserName") || "未登录");
const isCollapsed = ref(false);
const loading = ref(false);
const showMobileMenu = ref(false);
const singleOpenName = ref(["user"]); // 控制菜单展开状态
const menuTheme = ref("dark"); // 菜单主题

// 侧边栏菜单数据
const menuList = ref([
  {
    name: "user",
    title: "用户中心",
    icon: "ios-person",
    children: [
      { name: "settings", title: "账号设置", icon: "ios-settings" },
      { name: "profile", title: "个人资料", icon: "ios-contact" },
    ],
  },
]);

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
      alert("用户名不能为空");
      return false;
    }
    if (newUsername.value.length < 3) {
      alert("用户名长度需至少3个字符");
      return false;
    }
  }
  if (type === "password") {
    if (!newPassword.value) {
      alert("密码不能为空");
      return false;
    }
    if (newPassword.value.length < 6) {
      alert("密码长度需至少6个字符");
      return false;
    }
  }
  if (type === "email") {
    if (!newEmail.value) {
      alert("邮箱不能为空");
      return false;
    }
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(newEmail.value)) {
      alert("请输入有效的邮箱地址");
      return false;
    }
  }
  return true;
};

// 确认操作处理
const handleConfirm = async () => {
  if (!confirmPassword.value) {
    alert("请输入当前密码");
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
          alert("用户名无效或已存在");
        } else {
          sessionStorage.setItem("UserName", newUsername.value);
          alert("用户名修改成功！");
        }
      } else if (actionType.value === "password") {
        const newEncryptedPassword = CryptoJS.SHA256(newPassword.value).toString();
        const res = await updatePasswordService(sessionStorage.getItem("UserName"), newEncryptedPassword);
        if (res === "Invalid username") {
          alert("用户名无效");
        } else {
          alert("密码修改成功！");
        }
      } else if (actionType.value === "email") {
        const res = await updateEmailService(sessionStorage.getItem("UserName"), newEmail.value);
        if (res === "Invalid username") {
          alert("用户名无效");
        } else {
          alert("邮箱绑定成功！");
        }
      } else if (actionType.value === "delete") {
        const res = await deleteAccountService(sessionStorage.getItem("UserName"));
        if (res === "delete successfully") {
          alert(`账号 ${sessionStorage.getItem("UserName")} 注销成功`);
          sessionStorage.clear();
          sessionStorage.setItem("isAuthenticated", "false");
          router.push("/login");
        } else {
          alert("账号注销失败，请重试");
        }
      }
      closeModal();
    } else {
      alert("当前密码错误，请重试");
    }
  } catch (error) {
    alert(`操作失败：${error.message || "未知错误"}`);
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
  alert("已退出登录");
  router.push("/auth");
};

// 侧边栏折叠切换
const toggleCollapse = () => {
  isCollapsed.value = !isCollapsed.value;
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

// 图标映射
const iconMap = {
  'ios-person': 'ios-person',
  'ios-settings': 'ios-settings',
  'ios-contact': 'ios-contact',
  'ios-arrow-forward': 'ios-arrow-forward',
  'ios-arrow-back': 'ios-arrow-back',
  'ios-menu': 'ios-menu'
};
</script>

<template>
  <div class="layout">
    <PageHeader class="layout-header" />
    <div class="layout-content">
      <div class="layout-sider" :class="{ collapsed: isCollapsed, 'mobile-open': showMobileMenu }">
        <div class="sidebar-container">
          <div class="sidebar-shrink-button" @click="toggleCollapse">
            <ElIcon>
              <component :is="isCollapsed ? ArrowRight : ArrowLeft" />
            </ElIcon>
          </div>
          
          <div class="user-panel">
            <div class="user-avatar">
              <ElIcon><User /></ElIcon>
            </div>
            <div class="user-info" v-show="!isCollapsed">
              <div class="user-name">{{ username }}</div>
              <div class="user-role">用户</div>
            </div>
          </div>
          
          <ShrinkableMenu 
            :shrink="isCollapsed"
            :menu-list="menuList"
            :theme="menuTheme"
            :open-names="singleOpenName"
            :show-mobile-toggle="false"
            @on-change="changeMenu"
            @on-mobile-toggle="handleMobileToggle"
          />
        </div>
      </div>
      
      <!-- 页面内容 -->
      <div class="layout-main" :class="{ collapsed: isCollapsed }">
        <div class="content-wrapper">
          <h1>个人账号设置</h1>
          <div class="settings-container">
            <div class="settings-left">
              <h2>修改账号设置</h2>
              <div class="form-group">
                <label for="username">修改用户名</label>
                <input id="username" v-model="newUsername" type="text" placeholder="输入新用户名" maxlength="20" />
                <button @click="openModal('username')" :disabled="loading">修改用户名</button>
              </div>
              <div class="form-group">
                <label for="password">修改密码</label>
                <input id="password" v-model="newPassword" type="password" placeholder="输入新密码" maxlength="20" />
                <button @click="openModal('password')" :disabled="loading">修改密码</button>
              </div>
            </div>
            <div class="divider"></div>
            <div class="settings-right">
              <div class="form-group-rightup">
                <label for="email">绑定邮箱号</label>
                <input id="email" v-model="newEmail" type="text" placeholder="输入新邮箱号" maxlength="40" />
                <button @click="openModal('email')" :disabled="loading">绑定邮箱号</button>
              </div>
              <div class="form-group-rightdown">
                <button @click="handleLogout" class="logout-btn" :disabled="loading">退出登录</button>
                <button @click="openModal('delete')" class="delete-btn" :disabled="loading">注销账号</button>
              </div>
            </div>
          </div>
          <div v-if="showConfirmationModal" class="modal">
            <div class="modal-content">
              <h2>确认修改</h2>
              <p>请输入当前密码以确认操作</p>
              <input v-model="confirmPassword" type="password" placeholder="输入当前密码" />
              <div class="modal-actions">
                <button @click="handleConfirm" :disabled="loading">
                  <CircleLoading v-if="loading" /> {{ loading ? "处理中..." : "确认" }}
                </button>
                <button @click="closeModal" :disabled="loading">取消</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="less" scoped>
/* 恢复scoped属性，确保样式只应用于当前组件 */

.layout {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  width: 100%;

  &-header {
    flex: 0 0 60px;
    width: 100%;
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    z-index: 1000;
  }

  &-content {
    flex: 1;
    display: flex;
    margin-top: 60px;
    height: calc(100vh - 60px);
  }

  &-sider {
    position: fixed;
    left: 0;
    top: 60px;
    bottom: 0;
    width: 200px;
    background: #2b3643;
    z-index: 900;
    transition: all 0.3s ease;
    box-shadow: 2px 0 6px rgba(0,0,0,0.1);

    &.collapsed {
      width: 80px;
    }

    &.mobile-open {
      transform: translateX(0);
    }
    
    .sidebar-container {
      position: relative;
      height: 100%;
      display: flex;
      flex-direction: column;

      .user-panel {
        padding: 15px;
        display: flex;
        align-items: center;
        margin-bottom: 10px;
        border-bottom: 1px solid rgba(255,255,255,0.1);
        
        .user-avatar {
          width: 40px;
          height: 40px;
          border-radius: 50%;
          background: rgba(255,255,255,0.1);
          display: flex;
          align-items: center;
          justify-content: center;
          color: #fff;
          margin-right: 10px;
        }
        
        .user-info {
          overflow: hidden;
          
          .user-name {
            color: #fff;
            font-weight: 500;
            font-size: 14px;
            white-space: nowrap;
          }
          
          .user-role {
            color: rgba(255,255,255,0.7);
            font-size: 12px;
          }
        }
      }
    }
  }

  &-main {
    flex: 1;
    margin-left: 200px;
    transition: all 0.3s ease;
    height: calc(100vh - 60px);
    width: calc(100vw - 200px);
    background: #f5f7fa;
    padding: 20px;
    box-sizing: border-box;
    overflow-y: auto;

    &.collapsed {
      margin-left: 80px;
      width: calc(100vw - 80px);
    }
    
    .content-wrapper {
      background: #fff;
      border-radius: 8px;
      box-shadow: 0 2px 12px rgba(0, 0, 0, 0.05);
      padding: 20px;
      height: 100%;
      overflow-y: auto;
    }
  }
}

@media screen and (max-width: 768px) {
  .layout {
    &-sider {
      transform: translateX(-200px);
      z-index: 1000;

      &.mobile-open {
        transform: translateX(0);
        width: 200px;
      }
    }

    &-main {
      margin-left: 0;
      width: 100%;
      padding: 15px;
    }
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

/* Element UI 侧边栏样式调整 */
.el-menu-vertical:not(.el-menu--collapse) {
  width: 200px;
}

.el-menu {
  border-right: none;
  height: 100%;
}

.el-menu--collapse {
  width: 80px;
}

/* 强化图标大小控制 */
.el-icon {
  font-size: 18px !important;
  width: 24px !important;
  height: 18px !important;
  display: inline-flex !important;
  justify-content: center !important;
  align-items: center !important;
}

.el-icon svg {
  width: 18px !important;
  height: 18px !important;
  vertical-align: middle !important;
}

/* 统一所有菜单按钮样式 */
.el-menu-item,
.el-submenu__title {
  height: 48px !important;
  line-height: 48px !important;
  padding: 0 24px !important;
  position: relative;
  cursor: pointer;
  z-index: 1;
  transition: all .3s ease-in-out;
  display: flex !important;
  align-items: center !important;
  color: rgba(255, 255, 255, 0.7) !important;
}

/* 统一所有图标样式 */
.el-menu-item .el-icon,
.el-submenu__title .el-icon {
  margin-right: 10px;
  width: 24px;
  text-align: center;
  font-size: 18px !important;
  color: rgba(255, 255, 255, 0.7);
}

/* 统一所有文本样式 */
.el-menu-item span,
.el-submenu__title span {
  font-size: 14px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* 子菜单特殊处理 */
.el-submenu .el-menu .el-menu-item {
  padding-left: 43px !important;
  background-color: #1e2732 !important;
}

/* 统一所有按钮交互效果 */
.el-menu-item:hover,
.el-submenu__title:hover {
  background: rgba(255, 255, 255, 0.05) !important;
  color: #fff !important;
}

.el-menu-item:hover .el-icon,
.el-submenu__title:hover .el-icon {
  color: #fff !important;
}

/* 统一激活状态 */
.el-menu-item.is-active,
.el-submenu.is-active > .el-submenu__title {
  color: #fff !important;
  background-color: rgba(0, 170, 255, 0.2) !important;
  border-right: 3px solid #00aaff !important;
}

.el-menu-item.is-active .el-icon,
.el-submenu.is-active > .el-submenu__title .el-icon {
  color: #fff !important;
}

/* 折叠状态下的样式统一 */
.el-menu--collapse .el-submenu__title span,
.el-menu--collapse .el-menu-item span {
  opacity: 0;
  display: none;
}

.el-menu--collapse .el-submenu__title .el-icon,
.el-menu--collapse .el-menu-item .el-icon {
  margin: 0 !important;
  width: 100% !important;
  text-align: center;
}

/* 使用:deep()选择器专门针对箭头图标 */
:deep(.el-sub-menu__icon-arrow) {
  font-size: 12px !important;
  width: 12px !important;
  height: 12px !important;
  position: absolute;
  right: 20px;
  top: 50%;
  margin-top: -6px;
  transition: transform .3s;
  color: rgba(255, 255, 255, 0.7);
}

:deep(.el-sub-menu__icon-arrow svg) {
  width: 12px !important;
  height: 12px !important;
}

:deep(.el-sub-menu.is-opened > .el-sub-menu__title .el-sub-menu__icon-arrow) {
  transform: rotateZ(180deg);
}

/* 移动设备适配 */
@media screen and (max-width: 768px) {
  .el-submenu__title, .el-menu-item {
    padding: 0 32px !important;
    height: 56px !important;
    line-height: 56px !important;
  }
}

/* 收缩按钮样式调整 */
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
</style>

<!-- 移除或简化下面的样式，因为我们将使用侧边栏组件自带的样式 -->
<style>
/* 必要的局部样式可以保留 */
</style>