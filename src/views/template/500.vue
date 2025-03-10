<template>
    <!-- 500页面 -->
    <div class="error500">
        <div class="error500-body-con">
            <!-- 卡片 -->
            <Card>
                <!-- 500动画 -->
                <div class="error500-body-con-title">
                    <span class="error500-5-span">
                        <Icon type="social-freebsd-devil"></Icon>
                    </span>
                    <span class="error500-0-span">
                        <Icon type="social-freebsd-devil"></Icon>
                    </span>
                    <span class="error500-0-span">
                        <Icon type="social-freebsd-devil"></Icon>
                    </span>
                </div>  
                <!-- 500提示信息 -->
                <p class="error500-body-con-message">抱歉，服务器出错了</p>
                <!-- 按钮 -->
                <div class="error500-btn-con">
                    <Button @click="goHome" size="large" class="error-btn" type="text">返回首页</Button>
                    <Button @click="backPage" size="large" class="error-btn primary" type="primary">返回上一页</Button>
                </div>
            </Card>
        </div>
    </div>
    </template>
    
    <script>
    export default {
        name: 'Error500',
        methods: {
            /* 返回上一页 */
            backPage() {
                this.$router.go(-1);
            },
            /* 返回首页 */
            goHome() {
                this.$router.push({
                    name: 'home_index'
                });
            }
        }
    };
    </script>
    
    <style lang="less">
    /* 500动画 */
    @keyframes error500animation {
        0% {
            transform: rotateZ(0deg);
        }
    
        20% {
            transform: rotateZ(-10deg);
        }
    
        40% {
            transform: rotateZ(5deg);
        }
    
        60% {
            transform: rotateZ(-5deg);
        }
    
        80% {
            transform: rotateZ(10deg);
        }
    
        100% {
            transform: rotateZ(0deg);
        }
    }
    
    .error500 {
        /* 500主体 */
        &-body-con {
            width: 700px;
            height: 500px;
            position: absolute;
            left: 50%;
            top: 50%;
            transform: translate(-50%, -50%);
    
            /* 500标题 */
            &-title {
                text-align: center;
                font-size: 240px;
                font-weight: 700;
                color: #2d8cf0;
                height: 260px;
                line-height: 260px;
                margin-top: 40px;
    
                /* 500动画 */
                .error500-0-span {
                    display: inline-block;
                    position: relative;
                    width: 170px;
                    height: 170px;
                    border-radius: 50%;
                    border: 20px solid #ed3f14;
                    color: #ed3f14;
                    margin-right: 10px;
    
                    i {
                        display: inline-block;
                        font-size: 120px;
                        position: absolute;
                        bottom: -10px;
                        left: 10px;
                        transform-origin: center bottom;
                        animation: error500animation 3s ease 0s infinite alternate;
                    }
                }
            }
    
            /* 500提示信息 */
            &-message {
                display: block;
                text-align: center;
                font-size: 30px;
                font-weight: 500;
                letter-spacing: 4px;
                color: #dddde2;
            }
        }
    
        /* 500按钮 */
        &-btn-con {
            text-align: center;
            padding: 20px 0;
            margin-bottom: 40px;
            
            .error-btn {
                width: 180px;
                &.primary {
                    margin-left: 20px;
                }
                @media screen and (max-width: 768px) {
                    width: 140px;
                    &.primary {
                        margin-left: 10px;
                    }
                }
            }
        }
    }
    </style>
    