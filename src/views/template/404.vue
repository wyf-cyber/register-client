<template>
  <div class="not-found-container">
    <div class="content">
      <div class="number-container">
        <div class="number four-left">4</div>
        <div class="planet-container">
          <div class="planet">
            <div class="crater crater-1"></div>
            <div class="crater crater-2"></div>
            <div class="crater crater-3"></div>
            <div class="crater crater-4"></div>
            <div class="crater crater-5"></div>
          </div>
          <div class="astronaut">
            <div class="astronaut-body"></div>
            <div class="astronaut-head"></div>
            <div class="astronaut-arm arm-left"></div>
            <div class="astronaut-arm arm-right"></div>
            <div class="astronaut-leg leg-left"></div>
            <div class="astronaut-leg leg-right"></div>
          </div>
        </div>
        <div class="number four-right">4</div>
      </div>
      <h1 class="title">页面走丢了</h1>
      <p class="description">抱歉，您请求的页面不存在或已被移动</p>
      <div class="button-container">
        <button class="home-button" @click="goHome">返回首页</button>
        <button class="back-button" @click="backPage">返回上一页</button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Error404',
  methods: {
    /* 返回上一页 */
    backPage() {
      this.$router.go(-1);
    },
    /* 返回登录页面 */
    goHome() {
      this.$router.push({
        name: 'login'
      });
    }
  }
};
</script>

<style lang="less" scoped>
/* 更强力的全局重置 */
:global(body), :global(html) {
  margin: 0 !important;
  padding: 0 !important;
  width: 100% !important;
  overflow-x: hidden !important;
}

/* 使用更强力的方式确保容器占满整个视口 */
.not-found-container {
  position: fixed !important;
  top: 0 !important;
  left: 0 !important;
  right: 0 !important;
  bottom: 0 !important;
  width: 100vw !important; /* 使用视口宽度单位 */
  height: 100vh !important;
  margin: 0 !important;
  padding: 0 !important;
  display: flex;
  justify-content: center;
  align-items: center;
  background: linear-gradient(135deg, #1e2b38 0%, #2a3f54 100%);
  font-family: 'PingFang SC', 'Microsoft YaHei', sans-serif;
  overflow: hidden;
  box-sizing: border-box !important;
  z-index: 9999; /* 确保在最上层 */
}

.content {
  width: 100%;
  max-width: 1200px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  color: #fff;
  padding: 2rem;
  box-sizing: border-box;
}

.number-container {
  display: flex;
  align-items: center;
  margin-bottom: 2rem;
}

.number {
  font-size: 12rem;
  font-weight: 700;
  color: #f5f5f5;
  text-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
  line-height: 1;
}

.four-left {
  animation: float 6s ease-in-out infinite;
}

.four-right {
  animation: float 6s ease-in-out 0.5s infinite;
}

.planet-container {
  width: 150px;
  height: 150px;
  margin: 0 1rem;
  position: relative;
  animation: rotate 20s linear infinite;
}

.planet {
  width: 100%;
  height: 100%;
  background: #46dff0;
  border-radius: 50%;
  position: relative;
  box-shadow: 0 0 60px rgba(70, 223, 240, 0.6);
  overflow: hidden;
}

.crater {
  position: absolute;
  background: rgba(30, 43, 56, 0.3);
  border-radius: 50%;
}

.crater-1 {
  width: 30px;
  height: 30px;
  top: 20px;
  left: 80px;
}

.crater-2 {
  width: 20px;
  height: 20px;
  top: 40px;
  left: 40px;
}

.crater-3 {
  width: 35px;
  height: 35px;
  bottom: 30px;
  right: 20px;
}

.crater-4 {
  width: 15px;
  height: 15px;
  bottom: 20px;
  left: 60px;
}

.crater-5 {
  width: 25px;
  height: 25px;
  top: 70px;
  right: 30px;
}

.astronaut {
  position: absolute;
  width: 40px;
  height: 50px;
  left: -60px;
  top: 60px;
  animation: orbit 8s linear infinite;
}

.astronaut-body {
  position: absolute;
  width: 22px;
  height: 30px;
  background: #f5f5f5;
  border-radius: 8px;
  left: 9px;
  top: 10px;
}

.astronaut-head {
  position: absolute;
  width: 18px;
  height: 18px;
  background: #f5f5f5;
  border-radius: 50%;
  left: 11px;
  top: 0;
}

.astronaut-arm {
  position: absolute;
  width: 8px;
  height: 15px;
  background: #f5f5f5;
  border-radius: 4px;
}

.arm-left {
  left: 2px;
  top: 15px;
  transform: rotate(15deg);
}

.arm-right {
  right: 2px;
  top: 15px;
  transform: rotate(-15deg);
}

.astronaut-leg {
  position: absolute;
  width: 8px;
  height: 15px;
  background: #f5f5f5;
  border-radius: 4px;
  bottom: 0;
}

.leg-left {
  left: 8px;
}

.leg-right {
  right: 8px;
}

.title {
  font-size: 3rem;
  margin-bottom: 1rem;
  color: #fff;
  text-shadow: 0 5px 10px rgba(0, 0, 0, 0.2);
}

.description {
  font-size: 1.2rem;
  color: rgba(255, 255, 255, 0.8);
  margin-bottom: 2.5rem;
}

.button-container {
  display: flex;
  gap: 1rem;
}

.home-button, .back-button {
  padding: 0.8rem 1.5rem;
  font-size: 1rem;
  border: none;
  border-radius: 50px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 500;
}

.home-button {
  background-color: #46dff0;
  color: #1e2b38;
  box-shadow: 0 5px 15px rgba(70, 223, 240, 0.4);
}

.home-button:hover {
  background-color: #3bc1d1;
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(70, 223, 240, 0.6);
}

.back-button {
  background-color: transparent;
  color: #fff;
  border: 2px solid rgba(255, 255, 255, 0.5);
}

.back-button:hover {
  background-color: rgba(255, 255, 255, 0.1);
  transform: translateY(-2px);
}

@keyframes float {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-20px);
  }
}

@keyframes rotate {
  0% {
    transform: rotate(0);
  }
  100% {
    transform: rotate(360deg);
  }
}

@keyframes orbit {
  0% {
    transform: rotate(0deg) translateX(100px) rotate(0deg);
  }
  100% {
    transform: rotate(360deg) translateX(100px) rotate(-360deg);
  }
}

@media screen and (max-width: 768px) {
  .number {
    font-size: 8rem;
  }
  
  .planet-container {
    width: 120px;
    height: 120px;
  }
  
  .title {
    font-size: 2.5rem;
  }
  
  .description {
    font-size: 1rem;
  }
}

@media screen and (max-width: 480px) {
  .number {
    font-size: 6rem;
  }
  
  .planet-container {
    width: 90px;
    height: 90px;
  }
  
  .title {
    font-size: 2rem;
  }
  
  .button-container {
    flex-direction: column;
  }
  
  .home-button, .back-button {
    width: 100%;
  }
}
</style>
    