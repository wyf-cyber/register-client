<script setup>
import { ref } from "vue";
import { useRouter } from "vue-router";
import CryptoJS from "crypto-js";
import { loginService, updateUserNameService, updatePasswordService, deleteAccountService } from "@/api/authService";

// 定义状态变量
const newUsername = ref("");
const newPassword = ref("");
const router = useRouter();

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

</style>