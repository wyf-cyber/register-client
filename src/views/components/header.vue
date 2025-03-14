<template>
    <div class="header">
        <div class="header-left">
            <img src="@/assets/logo.png" alt="医院logo" class="logo">
            <h1 class="hospital-name">XX医院预约挂号系统</h1>
        </div>
        <div class="header-right">
            <span class="welcome">欢迎您,</span>
            <span class="username">{{ username }}</span>
        </div>
    </div>
</template>
    
<script>
    export default {
        name: "PageHeader",
        data() {
            return {
                username: sessionStorage.getItem("UserName") || "未登录"
            }
        }
    };
</script>

<style lang="less" scoped>
    .header {
        width: 100%;
        height: 60px;
        padding: 0 20px;
        background: #fff;
        box-shadow: 0 1px 4px rgba(0,21,41,.08);
        display: flex;
        justify-content: space-between;
        align-items: center;
        
        &-left {
            display: flex;
            align-items: center;
            
            .logo {
                height: 40px;
                margin-right: 10px;
            }

            .hospital-name {
                font-size: 18px;
                font-weight: bold;
                color: #1890ff;
            }
        }

        &-right {
            .welcome {
                color: #666;
                margin-right: 5px;
            }

            .username {
                color: #1890ff;
                font-weight: bold;
            }
        }
    }
</style>
    