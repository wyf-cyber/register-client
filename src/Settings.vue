<script setup>
import { ref } from "vue";
import { useRouter } from "vue-router";
import CryptoJS from "crypto-js";
import { loginService, updateUserNameService, updatePasswordService, deleteAccountService } from "@/api/authService";

// 定义状态变量
const newUsername = ref("");
const newPassword = ref("");
const confirmPassword = ref("");
const showConfirmationModal = ref(false);
const actionType = ref("");
const router = useRouter();

// 弹窗确认修改
const handleConfirm = async () => {
  const encryptedPassword = CryptoJS.SHA256(confirmPassword.value).toString();
  try {
    const response = await loginService(sessionStorage.getItem("UserName"), encryptedPassword);
    if (response.success) {
      if (actionType.value === "username") {
        const res1 = await updateUserNameService(sessionStorage.getItem("UserName"), newUsername.value);
        if (res1 === "Invalid username") {
          alert("Invalid username");
        } else {
          sessionStorage.setItem("UserName", newUsername.value);
          alert("用户名修改成功！");
        }
      } else if (actionType.value === "password") {
        const new_password = CryptoJS.SHA256(newPassword.value).toString();
        const res2 = await updatePasswordService(sessionStorage.getItem("UserName"), new_password);
        if (res2 === "Invalid username") {
          alert("Invalid username");
        } else {
          alert("密码修改成功！");
        }
      } else if (actionType.value === "delete") {
        const res3 = await deleteAccountService(sessionStorage.getItem("UserName"));
        if (res3 === "delete successfully") {
          alert("账号 " + sessionStorage.getItem("UserName") + " 注销成功");
          sessionStorage.clear();
          sessionStorage.setItem("isAuthenticated", "false");
          router.push("/auth"); // 注销账号后跳转到登录/注册页面
        } else {
          alert("账号注销失败，请重试");
        }
      } 
      closeModal();
    } else if (response.message === "Invalid password") {
      alert("密码错误，请重试。");
    }
  } catch (error) {
    alert("身份验证错误：" + error.message);  // 身份验证错误：new_password is not defined
  }
};

// 打开弹窗
const openModal = (type) => {
  actionType.value = type;
  showConfirmationModal.value = true;
};

// 关闭弹窗
const closeModal = () => {
  confirmPassword.value = "";
  showConfirmationModal.value = false;
};

// 退出登录逻辑
const handleLogout = () => {
  sessionStorage.clear(); // 清空 sessionStorage
  sessionStorage.setItem("isAuthenticated", "false"); // 设置 isAuthenticated 为 false
  alert("已退出登录");
  router.push("/auth"); // 退出登录后跳转到登录/注册页面
};
</script>

<template>
  <div class="container">
    <h1>个人账号设置</h1>
    <div class="settings-container">
      <!-- 左半部分 -->
      <div class="settings-left">
        <h2>修改账号设置</h2>
        <div class="form-group">
          <label for="username">修改用户名</label>
          <input id="username" v-model="newUsername" type="text" placeholder="输入新用户名" maxlength="20" />
          <button @click="openModal('username')">修改用户名</button>
        </div>
        <div class="form-group">
          <label for="password">修改密码</label>
          <input id="password" v-model="newPassword" type="password" placeholder="输入新密码" maxlength="20" />
          <button @click="openModal('password')">修改密码</button>
        </div>
      </div>

      <!-- 分隔线 -->
      <div class="divider"></div>

      <!-- 右半部分 -->
      <div class="settings-right">
        <div class="form-group-rightdown">
          <button @click="handleLogout" class="logout-btn" title="退出当前账户，但保留账户数据">退出登录</button>
          <button @click="openModal('delete')" class="delete-btn" title="永久删除账户及所有数据，无法恢复">注销账号</button>
        </div>
      </div>
    </div>
    
    <!-- 修改/注销身份验证模态框 -->
    <div v-if="showConfirmationModal" class="modal">
      <div class="modal-content">
        <h2>确认修改</h2>
        <p>请输入当前密码以确认操作</p>
        <input v-model="confirmPassword" type="password" placeholder="输入当前密码" />
        <div class="modal-actions">
          <button @click="handleConfirm">确认</button>
          <button @click="closeModal">取消</button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.container {
  background-color: #ffffff;
  padding: 40px;
  border-radius: 12px;
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.2);
  width: 90vw;
  max-width: 1200px;
  margin: 20px auto;
}

h1 {
  margin-bottom: 30px;
  color: #343a40;
  text-align: center;
  font-size: 28px;
  font-weight: bold; /* 加粗字体 */
  font-family: 'Arial', sans-serif; /* 美化字体 */
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2); /* 添加文字阴影 */
  letter-spacing: 1px; /* 增加字符间距 */
  line-height: 1.5; /* 改善行高 */
}

h2 {
  font-size: 20px;
  letter-spacing: 1px; /* 增加字符间距 */
  line-height: 1.5; /* 改善行高 */
  margin-bottom: 20px;
  font-weight: bold;
}

.settings-container {
  display: flex;
  gap: 20px;
  align-items: flex-start;
}

.settings-left,
.settings-right {
  flex: 1;
}

.divider {
  width: 2px;
  background-color: #808080;
  height: 100%;
}

.form-group {
  margin-bottom: 20px;
  display: flex;
  flex-direction: column;
}

.form-group-rightup {
  margin-top: 48px;
  margin-bottom: 20px;
  display: flex;
  flex-direction: column;
}

.form-group-rightdown {
  margin-bottom: 20px;
  display: flex;
  flex-direction: row;
  gap: 30px;  /* 控制子元素之间的水平间距 */
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
  transition: border-color 0.3s ease-in-out;
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

.logout-btn,
.delete-btn {
  display: block;
  margin-top: 30px;
  margin-left: 0px;
  padding: 10px 15px;
  font-size: 16px;
  background-color: #dc3545;
  color: white;
  border: none;
  border-radius: 5px;
  cursor: pointer;
}

.logout-btn:hover {
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