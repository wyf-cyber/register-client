<template>
    <!-- 403页面 -->
    <div class="not-found-container">
        <div class="content">
            <div class="number-container">
                <div class="number four-left">4</div>
                <div class="lock-container">
                    <div class="lock-body">
                        <div class="keyhole"></div>
                    </div>
                    <div class="lock-shackle"></div>
                    <div class="astronaut">
                        <div class="astronaut-body"></div>
                        <div class="astronaut-head"></div>
                        <div class="astronaut-arm arm-left"></div>
                        <div class="astronaut-arm arm-right"></div>
                        <div class="astronaut-leg leg-left"></div>
                        <div class="astronaut-leg leg-right"></div>
                    </div>
                </div>
                <div class="number four-right">3</div>
            </div>
            <h1 class="title">禁止访问</h1>
            <p class="description">抱歉，您没有访问权限</p>
            <div class="button-container">
                <button class="home-button" @click="goHome">返回首页</button>
                <button class="back-button" @click="backPage">返回上一页</button>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    name: 'Error403',
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
    width: 100vw !important;
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
    z-index: 9999;
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

.lock-container {
    width: 150px;
    height: 150px;
    margin: 0 1rem;
    position: relative;
}

.lock-body {
    width: 100px;
    height: 100px;
    background: #f5a623;
    border-radius: 10px;
    position: absolute;
    bottom: 0;
    left: 50%;
    transform: translateX(-50%);
    box-shadow: 0 0 60px rgba(245, 166, 35, 0.6);
    overflow: hidden;
}

.keyhole {
    width: 30px;
    height: 50px;
    background: #1e2b38;
    border-radius: 50% 50% 0 0;
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -40%);
}

.lock-shackle {
    width: 70px;
    height: 70px;
    border: 15px solid #f5a623;
    border-bottom: none;
    border-radius: 70px 70px 0 0;
    position: absolute;
    top: 0;
    left: 50%;
    transform: translateX(-50%);
    box-shadow: 0 0 30px rgba(245, 166, 35, 0.4);
    animation: jiggle 5s ease-in-out infinite;
}

.astronaut {
    position: absolute;
    width: 40px;
    height: 50px;
    top: 20px;
    left: 50%;
    transform: translateX(-50%);
    animation: tryUnlock 8s ease-in-out infinite;
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
    transform-origin: top left;
    animation: reachLeft 8s ease-in-out infinite;
}

.arm-right {
    right: 2px;
    top: 15px;
    transform-origin: top right;
    animation: reachRight 8s ease-in-out infinite;
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
    background-color: #f5a623;
    color: #1e2b38;
    box-shadow: 0 5px 15px rgba(245, 166, 35, 0.4);
}

.home-button:hover {
    background-color: #e09416;
    transform: translateY(-2px);
    box-shadow: 0 8px 20px rgba(245, 166, 35, 0.6);
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

@keyframes jiggle {
    0%, 100% {
        transform: translateX(-50%) rotate(0deg);
    }
    25% {
        transform: translateX(-50%) rotate(-5deg);
    }
    75% {
        transform: translateX(-50%) rotate(5deg);
    }
}

@keyframes tryUnlock {
    0%, 100% {
        transform: translateX(-50%) translateY(0);
    }
    50% {
        transform: translateX(-50%) translateY(20px);
    }
}

@keyframes reachLeft {
    0%, 15%, 85%, 100% {
        transform: rotate(15deg);
    }
    50%, 70% {
        transform: rotate(-30deg);
    }
}

@keyframes reachRight {
    0%, 15%, 85%, 100% {
        transform: rotate(-15deg);
    }
    50%, 70% {
        transform: rotate(30deg);
    }
}

@media screen and (max-width: 768px) {
    .number {
        font-size: 8rem;
    }
    
    .lock-container {
        width: 120px;
        height: 120px;
    }
    
    .lock-body {
        width: 80px;
        height: 80px;
    }
    
    .lock-shackle {
        width: 60px;
        height: 60px;
        border-width: 12px;
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
    
    .lock-container {
        width: 90px;
        height: 90px;
    }
    
    .lock-body {
        width: 60px;
        height: 60px;
    }
    
    .lock-shackle {
        width: 40px;
        height: 40px;
        border-width: 10px;
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