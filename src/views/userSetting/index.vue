<script setup>
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import CryptoJS from "crypto-js";
import { loginService, updateUserNameService, updatePasswordService, deleteAccountService, updateEmailService } from "@/views/userSetting/api";
import PageHeader from "@/views/components/header.vue";
import CircleLoading from "@/views/components/circle_loading.vue";
import { Icon, Menu, Submenu, MenuItem } from "view-ui-plus";

// Define state variables
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

// Sidebar menu data
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

// Menu handling
const handleMenuChange = (name) => {
  router.push({ name });
};

const changeMenu = (name) => {
  handleMenuChange(name);
};

// Form validation
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

// Confirmation handler
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

// Modal controls
const openModal = (type) => {
  if (!validateForm(type)) return;
  actionType.value = type;
  showConfirmationModal.value = true;
};

const closeModal = () => {
  confirmPassword.value = "";
  showConfirmationModal.value = false;
};

// Logout
const handleLogout = () => {
  sessionStorage.clear();
  sessionStorage.setItem("isAuthenticated", "false");
  alert("已退出登录");
  router.push("/auth");
};

// Sidebar toggle
const toggleCollapse = () => {
  isCollapsed.value = !isCollapsed.value;
};

const toggleMobileMenu = () => {
  showMobileMenu.value = !showMobileMenu.value;
};

// Set initial menu state based on route
onMounted(() => {
  const currentRoute = router.currentRoute.value;
  if (currentRoute.matched.length > 1) {
    singleOpenName.value = [currentRoute.matched[0].name];
  }
});

// 添加移动菜单开关的处理方法
const handleMobileToggle = () => {
  showMobileMenu.value = !showMobileMenu.value;
};
</script>

<template>
  <div class="layout">
    <PageHeader class="layout-header" />
    <div class="layout-content">
      <div class="layout-sider" :class="{ collapsed: isCollapsed, 'mobile-open': showMobileMenu }">
        <div class="sidebar-container">
          <div class="sidebar-shrink-button" @click="toggleCollapse">
            <Icon :type="isCollapsed ? 'ios-arrow-forward' : 'ios-arrow-back'" />
          </div>
          <div class="sidebar-content">
            <div class="user-panel">
              <div class="user-avatar">
                <Icon type="ios-person" size="24" />
              </div>
              <div class="user-info" v-show="!isCollapsed">
                <div class="user-name">{{ username }}</div>
                <div class="user-role">用户</div>
              </div>
            </div>
            <Menu
              ref="sideMenu"
              :class="{ collapsed: isCollapsed }"
              accordion
              :active-name="$route.name"
              :open-names="singleOpenName"
              :theme="menuTheme"
              width="auto"
              @on-select="changeMenu"
            >
              <template v-for="item in menuList" :key="item.name">
                <Submenu v-if="item.children" :name="item.name">
                  <template #title>
                    <Icon :type="item.icon" />
                    <span class="layout-text">{{ item.title }}</span>
                  </template>
                  <MenuItem v-for="child in item.children" :key="child.name" :name="child.name">
                    <Icon :type="child.icon" />
                    <span class="layout-text">{{ child.title }}</span>
                  </MenuItem>
                </Submenu>
                <MenuItem v-else :name="item.name">
                  <Icon :type="item.icon" />
                  <span class="layout-text">{{ item.title }}</span>
                </MenuItem>
              </template>
            </Menu>
          </div>
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

      .sidebar-content {
        height: 100%;
        display: flex;
        flex-direction: column;
        overflow-y: auto;
        
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

      .collapsed {
        width: 80px !important;

        .layout-text {
          display: none;
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

  .mobile-menu-toggle {
    display: none;
    position: fixed;
    left: 15px;
    top: 70px;
    z-index: 1100;
    background: #fff;
    width: 40px;
    height: 40px;
    border-radius: 50%;
    box-shadow: 0 2px 8px rgba(0,0,0,0.15);
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 0.3s;
    
    &:hover {
      transform: scale(1.05);
      box-shadow: 0 3px 10px rgba(0,0,0,0.2);
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

      .sidebar-container {
        .sidebar-shrink-button {
          width: 36px;
          height: 36px;
          line-height: 36px;
          right: -18px;
        }
      }
    }

    &-main {
      margin-left: 0;
      width: 100%;
      padding: 15px;
    }

    .mobile-menu-toggle {
      display: flex;
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
</style>