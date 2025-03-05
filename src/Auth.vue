<template>
  <div class="page-background">
    <div class="body">
      <div class="main-box">
        <div :class="['container', 'container-register', { 'is-txl': isLogin }]">
          <form @submit.prevent="register">
            <h2 class="title">注册</h2>
            <input class="form__input" type="text" v-model="registerForm.username" placeholder="请输入用户名"/>
            <input class="form__input" type="email" v-model="registerForm.email" placeholder="请输入邮箱"/>
            <input class="form__input" type="password" v-model="registerForm.password" placeholder="请输入密码"/>
            <input class="form__input" type="password" v-model="registerForm.confirmPassword" placeholder="请确认密码"/>
            <div class="captcha-wrapper">
              <img :src="verifyCodeImgUrl" alt="Verification" @click="fetchVerifyCode" class="captcha-image" title="点击图片刷新验证码"/>
              <input class="form__input captcha-input" type="text" v-model="enteredVerifyCode" placeholder="输入验证码"/>
            </div>
            <div class="form__button" @click="register">立即注册</div>
          </form>
        </div>
        <div :class="['container', 'container-login', { 'is-txl is-z200': isLogin }]">
          <form @submit.prevent="login">
            <h2 class="title">登录</h2>
            <input class="form__input" type="text" v-model="loginForm.username" placeholder="请输入用户名"/>
            <input class="form__input" type="password" v-model="loginForm.password" placeholder="请输入密码"/>
            <div class="captcha-wrapper">
              <img :src="verifyCodeImgUrl" alt="Verification" @click="fetchVerifyCode" class="captcha-image" title="点击图片刷新验证码"/>
              <input class="form__input captcha-input" type="text" v-model="enteredVerifyCode" placeholder="输入验证码"/>
            </div>
            <div class="form__button" @click="login">立即登录</div>
            <p class="forgot-password" @click="openModal">忘记密码？</p>
          </form>
        </div>
        <div :class="['switch', { 'login': isLogin }]">
          <div class="switch__circle"></div>
          <div class="switch__circle switch__circle_top"></div>
          <div class="switch__container">
            <h2>{{ isLogin ? '您好 !' : '欢迎回来 !' }}</h2>
            <p>
              {{
                isLogin
                    ? '如果您还没有账号，请点击下方立即注册按钮进行账号注册'
                    : '如果您已经注册过账号，请点击下方立即登录按钮进行登录'
              }}
            </p>
            <div class="form__button" @click="isLogin = !isLogin">
              {{ isLogin ? '立即注册' : '立即登录' }}
            </div>
          </div>
        </div>
      </div>

      <div v-if="showEmailModal" class="email-modal">
        <div class="modal-content">
          <h2>邮箱验证登录</h2>
          <form @submit.prevent="sendVerifyEmail">
            <div class="modal-input">
              <input type="text" v-model="modalUsername" placeholder="请输入用户名" required/>
              <button type="submit" :disabled="!canSendEmail">发送验证邮件</button>
            </div>
          </form>

          <form @submit.prevent="verifyEmailCode">
            <div class="modal-input">
              <input v-model="enteredConfirmCode" type="text" placeholder="输入验证码" required/>
            </div>
            <div class="modal-actions">
              <button type="submit">确认</button>
              <button @click="closeModal" type="button">取消</button>
            </div>
          </form>
        </div>
      </div>

      <div v-if="notification.show" :class="['notification', notification.type]">
        {{ notification.message }}
      </div>
    </div>
  </div>
</template>
  
<script>
import { ref, onMounted } from 'vue';
import { loginService, registerService, sendVerificationEmailService, verifyEmailCodeService } from '@/api/authService';
import { verifyService } from '@/api/toolsService';
import { useRouter } from 'vue-router';
import CryptoJS from 'crypto-js';
  
export default {
  name: 'Login',
  setup() {
    const isLogin = ref(true);
    const router = useRouter();
    const loginForm = ref({
      username: '',
      password: '',
    });
    const registerForm = ref({
      username: '',
      email: '',
      password: '',
      confirmPassword: '',
    });

    const verifyCode = ref('');
    const verifyCodeImgUrl = ref('');
    const enteredVerifyCode = ref('');
    let canFetchCaptcha = true;

    const showEmailModal = ref(false);
    const modalUsername = ref('');
    const enteredConfirmCode = ref('');
    const canSendEmail = ref(true);
    const lastSentTime = ref(0);

    const notification = ref({
      show: false,
      message: '',
      type: 'info'
    });

    async function fetchVerifyCode() {
      if (!canFetchCaptcha) {
        showNotification("请求过于频繁，请稍候再试。", "error");
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
          showNotification("获取验证码失败。" + res, "error");
        }
      } catch (error) {
        showNotification("验证码请求错误：" + error.message, "error");
      }
    }

    function validateInput(form, isRegistering = false) {
      const usernamePattern = /^[a-zA-Z0-9_]{3,15}$/;
      const captchaPattern = /^[a-zA-Z0-9]{5}$/;

      if (!usernamePattern.test(isRegistering ? form.username : form.username)) {
        showNotification("用户名不合法，请使用3-15个字母、数字或下划线。", "error");
        return false;
      }

      if (isRegistering) {
        const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailPattern.test(form.email)) {
          showNotification("请输入有效的邮箱地址。", "error");
          return false;
        }
      }

      if (!captchaPattern.test(enteredVerifyCode.value)) {
        showNotification("验证码格式不正确。", "error");
        return false;
      }

      return true;
    }

    async function login() {
      if (!validateInput(loginForm.value)) {
        return;
      }

      const encryptedPassword = CryptoJS.SHA256(loginForm.value.password).toString();

      if (enteredVerifyCode.value != verifyCode.value) {
        showNotification("验证码错误，请重试。", "error");
        return;
      }

      try {
        const response = await loginService(loginForm.value.username, encryptedPassword);
        if (response.success) {
          showNotification("登录成功！", "success");
          sessionStorage.setItem("isAuthenticated", "true");
          sessionStorage.setItem("UserName", loginForm.value.username);
          router.push("/");
          resetForms();
        } else if (response.message === "Invalid password") {
          showNotification("密码错误，请重试。", "error");
        } else if (response.message === "Invalid username") {
          showNotification("用户名未找到，请注册。", "error");
        }
      } catch (error) {
        showNotification("登录错误：" + error.message, "error");
        await fetchVerifyCode();
      }
    }

    async function register() {
      if (!validateInput(registerForm.value, true)) {
        return;
      }

      if (registerForm.value.password !== registerForm.value.confirmPassword) {
        showNotification("两次输入的密码不一致", "error");
        return;
      }

      const encryptedPassword = CryptoJS.SHA256(registerForm.value.password).toString();

      if (enteredVerifyCode.value != verifyCode.value) {
        showNotification("验证码错误，请重试。", "error");
        return;
      }

      try {
        const response = await registerService(
          registerForm.value.username, 
          registerForm.value.email, 
          encryptedPassword
        );
        if (response.success) {
          showNotification("注册成功，您可以现在登录。", "success");
          isLogin.value = true;
          resetForms();
        } else if (response.message === "Username already exists") {
          showNotification("用户名已存在，请选择另一个。", "error");
        } else if (response.message === "Email already exists") {
          showNotification("该邮箱已被注册。", "error");
        } else if (response.message === "User inserting failed") {
          showNotification("注册失败，请稍后重试", "error");
        }
      } catch (error) {
        showNotification("注册错误：" + error.message, "error");
      }
    }

    const openModal = () => {
      showEmailModal.value = true;
    };

    const closeModal = () => {
      showEmailModal.value = false;
      enteredConfirmCode.value = '';
    };

    async function sendVerifyEmail() {
      const currentTime = Date.now();
      if (currentTime - lastSentTime.value < 30000) {
        showNotification("验证邮件发送过于频繁，请稍等片刻再试。", "error");
        return;
      }

      lastSentTime.value = currentTime;
      canSendEmail.value = false;
      setTimeout(() => {
        canSendEmail.value = true;
      }, 30000);

      try {
        const res = await sendVerificationEmailService(modalUsername.value);
        if (res == "Invalid username") {
          showNotification("验证邮件已发送", "success");
        } else {
          showNotification("发送邮件失败：" + res, "error");
        }
      } catch (error) {
        showNotification("发送邮件错误：" + error.message, "error");
      }
    }

    async function verifyEmailCode() {
      try {
        const res = await verifyEmailCodeService(modalUsername.value, enteredConfirmCode.value);
        if (res) {
          showNotification("验证码验证成功，正在跳转...", "success");
          sessionStorage.setItem("isAuthenticated", "true");
          sessionStorage.setItem("UserName", modalUsername.value);
          router.push("/");
          resetForms();
        } else {
          showNotification("验证码错误，请重试。", "error");
        }
      } catch (error) {
        showNotification("验证失败：" + error.message, "error");
      }
    }

    function resetForms() {
      loginForm.value = {
        username: '',
        password: '',
      };
      registerForm.value = {
        username: '',
        email: '',
        password: '',
        confirmPassword: '',
      };
      enteredVerifyCode.value = '';
    }

    const showNotification = (message, type = 'info') => {
      notification.value.show = true;
      notification.value.message = message;
      notification.value.type = type;
      
      setTimeout(() => {
        notification.value.show = false;
      }, 3000);
    };

    onMounted(fetchVerifyCode);

    return {
      isLogin,
      loginForm,
      registerForm,
      verifyCodeImgUrl,
      enteredVerifyCode,
      showEmailModal,
      modalUsername,
      enteredConfirmCode,
      canSendEmail,
      login,
      register,
      fetchVerifyCode,
      openModal,
      closeModal,
      sendVerifyEmail,
      verifyEmailCode,
      notification
    };
  }
}
</script>
  
<style lang="scss" scoped>
.page-background {
  width: 100vw;
  height: 100vh;
  position: fixed;
  top: 0;
  left: 0;
  background-image: url('@/assets/images/background.png');
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  z-index: 0;
}

.body {
  position: static;
  width: 100%;
  height: 100vh;
  display: flex;   
  justify-content: center;
  align-items: center;
  font-family: "Montserrat", sans-serif;
  font-size: 12px;
  color: #a0a5a8;
}

.main-box {
  position: relative;
  width: 1000px;
  min-width: 1000px;
  min-height: 600px;
  height: 600px;
  padding: 25px;
  background-color: #ecf0f3;
  box-shadow: 1px 1px 100px 10PX #ecf0f3;
  border-radius: 12px;
  overflow: hidden;
  z-index: 1;
}

.container, .switch, .email-modal {
  z-index: 2;
}

.container {
  display: flex;
  justify-content: center;
  align-items: center;
  position: absolute;
  top: 0;
  width: 600px;
  height: 100%;
  padding: 25px;
  background-color: #ecf0f3;
  transition: all 1.25s;

  form {
    display: flex;
    justify-content: center;
    align-items: center;
    flex-direction: column;
    width: 100%;
    height: 100%;
    color: #a0a5a8;

    .form__icon {
      object-fit: contain;
      width: 30px;
      margin: 0 5px;
      opacity: .5;
      transition: .15s;

      &:hover {
        opacity: 1;
        transition: .15s;
        cursor: pointer;
      }
    }

    .title {
      font-size: 34px;
      font-weight: 700;
      line-height: 3;
      color: #181818;
    }

    .text {
      margin-top: 30px;
      margin-bottom: 12px;
    }

    .form__input {
      width: 350px;
      height: 40px;
      margin: 8px;
      padding-left: 25px;  
      font-size: 17px;
      letter-spacing: 0.15px;
      border: none;
      outline: none;
      font-family: 'Great Vibes', 'Pacifico', cursive;
      background-color: #ecf0f3;
      transition: 0.25s ease;
      border-radius: 8px;
      box-shadow: inset 2px 2px 4px #d1d9e6, inset -2px -2px 4px #f9f9f9;

      &::placeholder {
        color: #a0a5a8;
      }
    }
  }
}

.container-register {
  z-index: 100;
  left: calc(100% - 600px);
}

.container-login {
  left: calc(100% - 600px);
  z-index: 0;
}

.is-txl {
  left: 0;
  transition: 1.25s;
  transform-origin: right;
}

.is-z200 {
  z-index: 200;
  transition: 1.25s;
}

.switch {
  display: flex;
  justify-content: center;
  align-items: center;
  position: absolute;
  top: 0;
  left: 0;
  height: 100%;
  width: 400px;
  padding: 50px;
  z-index: 200;
  transition: 1.25s;
  background-color: #ecf0f3;
  overflow: hidden;
  box-shadow: 4px 4px 10px #d1d9e6, -4px -4px 10px #f9f9f9;
  color: #a0a5a8;

  .switch__circle {
    position: absolute;
    width: 500px;
    height: 500px;
    border-radius: 50%;
    background-color: #ecf0f3;
    box-shadow: inset 8px 8px 12px #d1d9e6, inset -8px -8px 12px #f9f9f9;
    bottom: -60%;
    left: -60%;
    transition: 1.25s;
  }

  .switch__circle_top {
    top: -30%;
    left: 60%;
    width: 300px;
    height: 300px;
  }

  .switch__container {
    display: flex;
    justify-content: center;
    align-items: center;
    flex-direction: column;
    position: absolute;
    width: 400px;
    padding: 50px 55px;
    transition: 1.25s;

    h2 {
      font-size: 34px;
      font-weight: 700;
      line-height: 3;
      color: #181818;
    }

    p {
      font-size: 14px;
      letter-spacing: 0.25px;
      text-align: center;
      line-height: 1.6;
    }
  }
}

.login {
  left: calc(100% - 400px);

  .switch__circle {
    left: 0;
  }
}

.form__button {
  width: 180px;
  height: 50px;
  border-radius: 25px;
  margin-top: 50px;
  text-align: center;
  line-height: 50px;
  font-size: 14px;
  letter-spacing: 2px;
  background-color: #4b70e2;
  color: #f9f9f9;
  cursor: pointer;
  box-shadow: 8px 8px 16px #d1d9e6, -8px -8px 16px #f9f9f9;

  &:hover {
    box-shadow: 2px 2px 3px 0 rgba(255, 255, 255, 50%),
    -2px -2px 3px 0 rgba(116, 125, 136, 50%),
    inset -2px -2px 3px 0 rgba(255, 255, 255, 20%),
    inset 2px 2px 3px 0 rgba(0, 0, 0, 30%);
  }
}

.captcha-wrapper {
  display: flex;
  align-items: center;
  gap: 10px;
  width: 350px;
  margin: 4px 0;

  .captcha-image {
    width: 100px;
    height: 40px;
    cursor: pointer;
    border-radius: 8px;
  }

  .captcha-input {
    flex: 1;
  }
}

.forgot-password {
  margin-top: 20px;
  color: #4b70e2;
  cursor: pointer;
  font-size: 14px;

  &:hover {
    text-decoration: underline;
  }
}

.email-modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;

  .modal-content {
    background-color: #ecf0f3;
    padding: 30px;
    border-radius: 12px;
    box-shadow: 4px 4px 10px #d1d9e6, -4px -4px 10px #f9f9f9;
    width: 90%;
    max-width: 450px;

    h2 {
      font-size: 24px;
      color: #181818;
      margin-bottom: 20px;
    }

    input {
      width: 100%;
      height: 40px;
      margin: 8px;
      padding-left: 25px;
      font-size: 15px;
      border: none;
      outline: none;
      background-color: #ecf0f3;
      border-radius: 8px;
      box-shadow: inset 2px 2px 4px #d1d9e6, inset -2px -2px 4px #f9f9f9;

      &::placeholder {
        color: #a0a5a8;
      }
    }

    button {
      width: auto;
      min-width: 120px;
      height: 40px;
      margin: 8px;
      border-radius: 20px;
      background-color: #4b70e2;
      color: #f9f9f9;
      border: none;
      cursor: pointer;
      box-shadow: 8px 8px 16px #d1d9e6, -8px -8px 16px #f9f9f9;

      &:hover {
        box-shadow: 2px 2px 3px 0 rgba(255, 255, 255, 50%),
                   -2px -2px 3px 0 rgba(116, 125, 136, 50%),
                   inset -2px -2px 3px 0 rgba(255, 255, 255, 20%),
                   inset 2px 2px 3px 0 rgba(0, 0, 0, 30%);
      }

      &:disabled {
        background-color: #a0a5a8;
        cursor: not-allowed;
      }
    }

    .modal-actions {
      display: flex;
      justify-content: space-between;
      margin-top: 20px;
      gap: 15px;

      button {
        flex: 1;
      }
    }
  }
}

.form__icons {
  display: flex;
  justify-content: center;
  margin-bottom: 20px;

  .form__icon {
    width: 40px;
    height: 40px;
    opacity: 0.8;
    transition: 0.15s;

    &:hover {
      opacity: 1;
      transform: scale(1.1);
    }
  }
}

.notification {
  position: fixed;
  top: 20px;
  right: 20px;
  padding: 15px 25px;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 500;
  z-index: 9999;
  animation: slideIn 0.3s ease-out;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  
  &.info {
    background-color: #ecf0f3;
    color: #4b70e2;
    border-left: 4px solid #4b70e2;
  }
  
  &.success {
    background-color: #ecf0f3;
    color: #2ecc71;
    border-left: 4px solid #2ecc71;
  }
  
  &.error {
    background-color: #ecf0f3;
    color: #e74c3c;
    border-left: 4px solid #e74c3c;
  }
}

@keyframes slideIn {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

@keyframes fadeOut {
  from {
    opacity: 1;
  }
  to {
    opacity: 0;
  }
}
</style>