<template>
    <!-- 圆形加载动画 -->
    <div style="display: inline-block;">
        <Icon type="ios-loading" size="18" color="#2d8cf0" class="spin-icon-load"></Icon>
    </div>
</template>
    
<script setup>
// 使用 script setup 语法
defineOptions({
  name: 'CircleLoading'
})
</script>
    
<style lang="less">
/* 圆形加载动画 */
.spin-icon-load {
    animation: ani-demo-spin 1s linear infinite;
}
</style>