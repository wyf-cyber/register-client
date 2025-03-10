<template>
    <!-- 403页面 -->
    <div class="error403">
        <div class="error403-body-con">
            <Card>
                <!-- 403动画 -->
                <div class="error403-body-con-title">
                    <span class="error403-0-span">
                        <Icon size="220" type="ios-lock"></Icon>
                    </span>
                    <span class="error403-key-span">
                        <Icon size="220" type="ios-lock"></Icon>
                    </span>
                    <span class="error403-0-span">
                        <Icon size="220" type="ios-lock"></Icon>
                    </span>
                </div>
                <!-- 403提示信息 -->
                <p class="error403-body-con-message">抱歉，您没有访问权限</p>
                <!-- 按钮 -->
                <div class="error403-btn-con">
                    <!-- 返回首页 -->
                    <Button @click="goHome" size="large" class="error-btn" type="text">返回首页</Button>
                    <!-- 返回上一页 -->
                    <Button @click="backPage" size="large" class="error-btn primary" type="primary">返回上一页</Button>
                </div>
            </Card>
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
    @keyframes error403animation {
        0% {
            transform: rotateZ(0deg);
        }
        40% {
            transform: rotateZ(-20deg);
        }
        45% {
            transform: rotateZ(-15deg);
        }
        50% {
            transform: rotateZ(-20deg);
        }
        55% {
            transform: rotateZ(-15deg);
        }
        60% {
            transform: rotateZ(-20deg);
        }
        100% {
            transform: rotateZ(0deg);
        }
    }
    .error403{
        &-body-con{
            width: 700px;
            height: 500px;
            position: absolute;
            left: 50%;
            top: 50%;
            transform: translate(-50%,-50%);
            &-title{
                text-align: center;
                font-size: 240px;
                font-weight: 700;
                color: #2d8cf0;
                height: 260px;
                line-height: 260px;
                margin-top: 40px;
                .error403-0-span{
                    display: inline-block;
                    position: relative;
                    width: 170px;
                    height: 170px;
                    border-radius: 50%;
                    border: 20px solid #ed3f14;
                    color: #ed3f14;
                    margin-right: 10px;
                    i{
                        display: inline-block;
                        font-size: 120px;
                        position: absolute;
                        left: 50%;
                        top: 50%;
                        transform: translate(-50%,-50%);
                    }
                }
                .error403-key-span{
                    display: inline-block;
                    position: relative;
                    width: 100px;
                    height: 190px;
                    border-radius: 50%;
                    margin-right: 10px;
                    i{
                        display: inline-block;
                        font-size: 190px;
                        position: absolute;
                        left: 20px;
                        transform: translate(-50%,-60%);
                        transform-origin: center bottom;
                        animation: error403animation 2.8s ease 0s infinite;
                    }
                }
            }
            &-message{
                display: block;
                text-align: center;
                font-size: 30px;
                font-weight: 500;
                letter-spacing: 4px;
                color: #dddde2;
            }
        }
        &-btn-con{
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