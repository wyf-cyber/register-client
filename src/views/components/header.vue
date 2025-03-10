<template>
    <div style="display: inline-block;">
        <Icon type="ios-loading" size="18" color="#2d8cf0" class="spin-icon-load"></Icon>
    </div>
</template>
    
<script>
    export default {
        name: "header"
    };
</script>

<style lang="less">
    /* 头部样式 */
    .header {
        margin-top: 8vh;
        margin-bottom: 5vh;
        text-align: center;
        
        .description {
            font-size: 14px;
            color: rgba(0, 0, 0, 0.45);
            margin-top: 1vh;
        }
    }
</style>
    