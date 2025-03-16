<template>
    <div class="header">
        <div class="header-left">
            <img src="@/assets/logo.png" alt="医院logo" class="logo">
            <h1 class="hospital-name">XX医院预约挂号系统</h1>
        </div>
        <div class="header-right">
            <div class="user-info">
                <Icon type="ios-person" size="18" />
                <span class="username">{{ username }}</span>
                <Icon type="ios-arrow-down" size="14" class="arrow-icon" />
            </div>
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
        background: linear-gradient(to right, #2c3e50, #3c5a76);
        box-shadow: 0 2px 10px rgba(0,0,0,.1);
        display: flex;
        justify-content: space-between;
        align-items: center;
        
        &-left {
            display: flex;
            align-items: center;
            
            .logo {
                height: 36px;
                margin-right: 12px;
                border-radius: 4px;
                transition: transform 0.3s;
                
                &:hover {
                    transform: scale(1.05);
                }
            }

            .hospital-name {
                font-size: 18px;
                font-weight: 600;
                color: #fff;
                letter-spacing: 0.5px;
            }
        }

        &-right {
            .user-info {
                display: flex;
                align-items: center;
                background: rgba(255,255,255,0.1);
                padding: 6px 12px;
                border-radius: 20px;
                cursor: pointer;
                transition: background-color 0.3s;
                
                &:hover {
                    background: rgba(255,255,255,0.2);
                }
                
                .username {
                    color: #fff;
                    font-weight: 500;
                    margin: 0 6px;
                }
                
                .arrow-icon {
                    color: rgba(255,255,255,0.7);
                }
            }
        }
    }

    @media (max-width: 768px) {
        .header {
            padding: 0 10px;
            
            &-left {
                .hospital-name {
                    font-size: 16px;
                }
            }
        }
    }
</style>
    