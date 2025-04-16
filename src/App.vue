<script setup>
import { ref, provide, watch } from 'vue'
import { useRoute } from 'vue-router'
import Messages from '@/views/components/messages.vue'

const messages = ref(null)

// 提供统一的消息通知方法
const showNotification = (message, type = 'success') => {
  if (messages.value) {
    messages.value.show(message, type)
  }
}
provide('showNotification', showNotification)

// 监听路由变化，刷新页面
const route = useRoute()
watch(route, (to, from) => {
  if (to.name !== from.name) {
    window.location.reload()
  }
})
</script>

<template>
  <div id="app">
    <Messages ref="messages" />
    <router-view />
  </div>
</template>
