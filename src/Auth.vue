<!-- src/Auth.vue -->
<template>
  <div class="auth-container">
    <!-- Left half: Image Carousel -->
    <div class="left-half">
      <div class="content-wrapper">
        <p class="title">XXX医院线上挂号服务平台</p>
        <img src="./assets/images/1.jpg" alt="photo not found" class="left-image" />
      </div>
    </div>
    <!-- Right half: Auth card -->
    <div class="right-half">
      <div class="auth-card">
        <div class="auth-toggle">
          <h2 :class="{'active': isLogin}" @click="toggleAuthMode('login')">登录</h2>
          <h2 :class="{'active': !isLogin}" @click="toggleAuthMode('regist')">注册</h2>
        </div>
        <form @submit.prevent="handleAuth">
          <input type="text" v-model="username" placeholder="请输入用户名" required class="auth-card-input"/>
          <input type="password" v-model="password" placeholder="请输入密码" required class="auth-card-input"/>
          <!-- 验证码区域 -->
          <div class="captcha-container">
            <img :src="verifyCodeImgUrl" alt="Verification" @click="fetchVerifyCode" class="captcha-image" title="点击图片刷新验证码"/>
            <input type="text" v-model="enteredVerifyCode" placeholder="输入验证码" required class="captcha-input"/>
          </div>
          <button type="submit">{{ isLogin ? "登录" : "注册" }}</button>
        </form>
        <p @click="openModal">忘记密码？</p>
      </div>
    </div>
   <!-- 邮箱验证模态框 -->
   <div v-if="showEmailModal" class="modal">
      <div class="modal-content">
        <h2>邮箱验证登录</h2>
        <!-- 第一个表单：发送验证邮件 -->
        <form @submit.prevent="sendVerifyEmail">
          <div class="modal-input">
            <p>用户名:</p>
            <input type="text" v-model="modalUsername" placeholder="请输入用户名" class="modal-content-input" required/>
            <button type="submit" class="modal-button" :disabled="!canSendEmail">发送验证邮件</button>
          </div>
        </form>

        <!-- 第二个表单：输入验证码并验证 -->
        <form @submit.prevent="verifyEmailCode">
          <div class="modal-input">
            <p>验证码:</p>
            <input v-model="enteredConfirmCode" type="text" placeholder="输入验证码" class="modal-content-input" required/>
          </div>

          <div class="modal-actions">
            <button type="submit" class="modal-button">确认</button>
            <button @click="closeModal" type="button" class="modal-button">取消</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { loginService, registerService, sendVerificationEmailService, verifyEmailCodeService } from '@/api/authService';
import { verifyService } from '@/api/toolsService';
import { useRouter } from 'vue-router';
import CryptoJS from 'crypto-js';


const isLogin = ref(true);
const username = ref('');
const password = ref('');
const router = useRouter();

// 验证码相关
const modalUsername = ref('');
const verifyCode = ref('');
const verifyCodeImgUrl = ref('');
const enteredVerifyCode = ref('');

// 邮箱验证模态框相关
const showEmailModal = ref(false);
const enteredConfirmCode = ref('');
const canSendEmail = ref(true);  // 控制发送邮件按钮是否可用
const lastSentTime = ref(0);     // 上次发送邮件的时间

// 验证码请求限制变量
let canFetchCaptcha = true;


// 获取验证码
async function fetchVerifyCode() {
  if (!canFetchCaptcha) {
    alert("请求过于频繁，请稍候再试。");
    return;
  }

  canFetchCaptcha = false;
  setTimeout(() => {
    canFetchCaptcha = true;
  }, 10000);

  try {
    const res = await verifyService();
    if (res && res.verifyCode && res.verifyCodeImgUrl) {
      verifyCode.value = res.verifyCode;
      verifyCodeImgUrl.value = res.verifyCodeImgUrl;
    } else {
      alert("获取验证码失败。" + res);
    }
  } catch (error) {
    alert("验证码请求错误：" + error.message);
  }
} 

// 页面加载时获取初始验证码
onMounted(fetchVerifyCode);

// 切换登录和注册模式
function toggleAuthMode(mode) {
  if (mode === 'login') {
    isLogin.value = true;
  } else if (mode === 'regist') {
    isLogin.value = false;
  }
}

// 输入字段安全性检查
function validateInput() {
  const usernamePattern = /^[a-zA-Z0-9_]{3,15}$/;
  const captchaPattern = /^[a-zA-Z0-9]{5}$/;

  if (!usernamePattern.test(username.value)) {
    alert("用户名不合法，请使用3-15个字母、数字或下划线。");
    return false;
  }

  if (!captchaPattern.test(enteredVerifyCode.value)) {
    alert("验证码格式不正确。");
    return false;
  }

  return true;
}

// 登录或注册处理
async function handleAuth() {
  if (!validateInput()) {
    return;
  }

  // 密码加密
  const encryptedPassword = CryptoJS.SHA256(password.value).toString();

  if (enteredVerifyCode.value != verifyCode.value) {
    alert("验证码错误，请重试。");
    return;
  }

  if (isLogin.value) {
    try {
      const response = await loginService(username.value, encryptedPassword);
      if (response.success) {
        sessionStorage.setItem("isAuthenticated", "true");
        sessionStorage.setItem("UserName", username.value);
        // alert("登录成功");
        router.push("/"); // 登录成功后跳转到主页面
      } else if (response.message === "Invalid password") {
        alert("密码错误，请重试。");
      } else if (response.message === "Invalid username") {
        alert("用户名未找到，请注册。");
      }
    } catch (error) {
      alert("登录错误：" + error.message);
    }
  } else {
    try {
      const response = await registerService(username.value, encryptedPassword);
      if (response.success) {
        alert("注册成功，您可以现在登录。");
        isLogin.value = true;
      } else if (response.message === "Username already exists") {
        alert("用户名已存在，请选择另一个。");
      } else if (response.message === "User inserting failed") {
        alert("添加新用户失败，原因未知");
      }
    } catch (error) {
      alert("注册错误：" + error.message);
    }
  }
}

// 打开弹窗
const openModal = () => {
  showEmailModal.value = true;
};

// 关闭弹窗
const closeModal = () => {
  confirmCode.value = "";
  showEmailModal.value = false;
};

// 发送验证邮件
async function sendVerifyEmail() {
  const currentTime = Date.now();
  if (currentTime - lastSentTime.value < 30000) { // 判断30秒内是否已经发送过邮件
    alert("验证邮件发送过于频繁，请稍等片刻再试。");
    return;
  }

  lastSentTime.value = currentTime;
  canSendEmail.value = false;  // 禁用按钮
  setTimeout(() => {
    canSendEmail.value = true; // 30秒后恢复按钮可用
  }, 30000);

  try {
    const res = await sendVerificationEmailService(username.value);
    if (res == "Invalid username") {
      alert("Email sent successfully");
    } else {
      alert("发送邮件失败：" + res);
    }
  } catch (error) {
    alert("发送邮件错误：" + error.message);
  }
}

// 校验邮箱验证码
async function verifyEmailCode() {
  try {
    const res = await verifyEmailCodeService(modalUsername.value, enteredConfirmCode.value);
    if (res) {
      alert("验证码验证成功，正在跳转...");
      // 完成登录
      sessionStorage.setItem("isAuthenticated", "true");
      sessionStorage.setItem("UserName", username.value);
      router.push("/");  // 验证成功后跳转到主页面
    } else {
      alert("验证码错误，请重试。");
    }
  } catch (error) {
    alert("验证失败：" + error.message);
  }
}
</script>
<style scoped>
.auth-container {
  display: flex;
  height: 100vh;
  width: 72vw;
}

/* Left half: Image */
.left-half {
  width: 50%;
  display: flex;
  justify-content: center;
  align-items: center;
  background-color: #ffffff;
  position: relative; /* 允许内部绝对定位 */
}

.content-wrapper {
  text-align: center; /* 居中内容 */
  width: 100%; /* 确保内容宽度一致 */
}

.title {
  font-size: 2rem;
  font-weight: bold;
  color: #42b983;
  text-shadow: 1px 1px 4px rgba(0, 0, 0, 0.3); /* 添加文字阴影 */
  margin-bottom: 1rem; /* 与图片的间距 */
  font-family: 'Arial', sans-serif; /* 字体美化 */
}

.left-image {
  width: 100%;
  height: 375px;
  object-fit: cover;
  border-radius: 8px; /* 增加图片圆角 */
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2); /* 图片投影效果 */
}
/* Right half: Auth card */
.right-half {
  width: 40%;
  display: flex;
  justify-content: center;
  align-items: center;
  background-color: #ffffff;
}
.auth-card {
  width: 100%;
  max-width: 320px;
  padding: 2rem;
  border-radius: 16px; /* 增加圆角 */
  background: linear-gradient(145deg, #ffffff, #f3f3f3); /* 添加渐变背景 */
  box-shadow: 0 8px 15px rgba(0, 0, 0, 0.1), inset 0 1px 2px rgba(255, 255, 255, 0.2); /* 添加阴影 */
  text-align: center;
}

.auth-toggle {
  flex-direction: row;
  gap: 20px;  /* 控制子元素之间的水平间距 */
}

.auth-card h2 {
  margin: 1rem 30px 1.5rem; /* 上方 1.5rem，左右 20px，下方 0 */
  font-size: 1.5rem;
  color: #767676;
  font-weight: bold;
  display: inline-block;
  padding-bottom: 0.3rem;
  cursor: pointer;
}

.auth-card h2.active {
  margin: 1rem 30px 1.5rem; /* 上方 1.5rem，左右 20px，下方 0 */
  font-size: 1.5rem;
  color: #252525;
  font-weight: bold;
  border-bottom: 2px solid #42b983; /* 添加底部分隔线 */
  display: inline-block;
  padding-bottom: 0.3rem;
  cursor: pointer;
}

.auth-card-input {
  width: 100%;
  padding: 0.8rem;
  margin-bottom: 1rem;
  border: 1px solid #ddd;
  border-radius: 6px; /* 增加圆角 */
  background: #fafafa;
  box-shadow: inset 0 1px 3px rgba(0, 0, 0, 0.1);
  font-size: 1rem;
  transition: border-color 0.3s ease;
}

.auth-card-input:focus {
  border-color: #42b983; /* 聚焦时高亮边框 */
  outline: none;
  box-shadow: 0 0 5px rgba(66, 185, 131, 0.5);
}

.captcha-container {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 1.5rem;
  border-top: 1px solid #eee; /* 添加顶部分隔线 */
  padding-top: 1rem;
}

.captcha-image {
  width: 110px;
  height: 40px;
  cursor: pointer;
  border-radius: 4px; /* 添加圆角 */
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s ease;
}

.captcha-image:hover {
  transform: scale(1.05); /* 悬浮时放大 */
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

.captcha-input {
  width: 120px;
  padding: 0.8rem;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 1rem;
  box-shadow: inset 0 1px 3px rgba(0, 0, 0, 0.1);
}

.auth-card form button {
  width: 100%;
  padding: 0.8rem;
  border: none;
  background: linear-gradient(145deg, #42b983, #3ca374); /* 按钮渐变 */
  color: white;
  font-weight: bold;
  font-size: 1rem;
  border-radius: 6px; /* 圆角 */
  cursor: pointer;
  box-shadow: 0 4px 8px rgba(66, 185, 131, 0.2);
  transition: background 0.3s ease, transform 0.2s ease;
}

.auth-card form button:hover {
  background: linear-gradient(145deg, #3ca374, #42b983);
  transform: translateY(-3px); /* 悬浮上移 */
  box-shadow: 0 6px 12px rgba(66, 185, 131, 0.3);
}

.auth-card p {
  margin-top: 1rem;
  color: #42b983;
  cursor: pointer;
  transition: color 0.3s ease;
}

.auth-card p:hover {
  color: #3ca374;
}

/* 模态框背景和居中设置 */
.modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5); /* 半透明背景 */
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000; /* 确保模态框位于最上层 */
}

/* 模态框内容 */
.modal-content {
  background: #fff;
  padding: 30px;
  border-radius: 12px;
  text-align: center;
  width: 90%;
  max-width: 450px; /* 限制最大宽度 */
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1); /* 阴影效果 */
  transition: transform 0.3s ease, opacity 0.3s ease; /* 动画效果 */
}

.modal-content h2 {
  font-size: 22px;
  color: #333;
  font-weight: 600;
  margin-bottom: 20px;
}

.modal-content p {
  font-size: 16px;
  color: #555;
  margin-bottom: 30px;
}

/* 输入框样式 */
.modal-content-input {
  min-width: 100px;
  max-width: 155px;
  padding: 12px;
  margin-bottom: 20px;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 14px;
  transition: border-color 0.3s ease;
}

/* 输入框焦点效果 */
.modal-content-input:focus {
  border-color: #007bff;
  outline: none;
}

/* 水平排列输入框和按钮 */
.modal-input {
  display: flex;
  flex-direction: row;
  gap: 20px;  /* 控制子元素之间的水平间距 */
  align-items: center;
}

/* 发送邮件按钮 */
.modal-button {
  padding: 12px 20px;
  margin-bottom: 20px;
  background-color: #007bff;
  color: #fff;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  cursor: pointer;
  transition: background-color 0.3s ease;
  width: auto; /* 自动宽度 */
  min-width: 140px; /* 设置最小宽度 */
}

.modal-button:hover {
  background-color: #0056b3;
}

/* 模态框按钮区域 */
.modal-actions {
  display: flex;
  justify-content: space-between;
  margin-top: 20px;
}

/* 确认和取消按钮 */
.modal-actions button {
  max-width: 40px;
  padding: 10px 20px;
  font-size: 14px;
  background-color: #28a745;
  color: #fff;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  transition: background-color 0.3s ease;
  width: 45%;
}

.modal-actions button:hover {
  background-color: #218838;
}

/* 取消按钮 */
.modal-actions button:last-child {
  max-width: 70px;
  background-color: #dc3545;
}

.modal-actions button:last-child:hover {
  background-color: #c82333;
}
</style>