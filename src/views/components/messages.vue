<template>
  <transition name="notification-fade">
    <div v-if="notification.show" :class="['notification', notification.type]">
      {{ notification.message }}
    </div>
  </transition>
</template>

<script setup>
import { ref } from 'vue'

const notification = ref({
  show: false,
  message: '',
  type: 'info'
})

// 暴露给父组件的方法
const show = (message, type = 'info') => {
  notification.value = {
    show: true,
    message,
    type
  }
  
  setTimeout(() => {
    notification.value.show = false
  }, 3000)
}

// 暴露方法给父组件引用
defineExpose({
  show
})
</script>

<style lang="scss" scoped>
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
  
  &.warning {
    background-color: #ecf0f3;
    color: #f39c12;
    border-left: 4px solid #f39c12;
  }
}

.notification-fade-enter-active, .notification-fade-leave-active {
  transition: opacity 0.3s, transform 0.3s;
}

.notification-fade-enter-from {
  opacity: 0;
  transform: translateX(100%);
}

.notification-fade-leave-to {
  opacity: 0;
  transform: translateY(-20px);
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
</style>
