<script setup>
// import ApiVue from './Api.vue'
// import MyAppointment from './MyAppointments.vue'
// import HealthRecords from './HealthRecords.vue'
// import Navbar from './Navbar.vue'
import { ref, provide } from 'vue'
import Messages from '@/views/components/messages.vue'

const messages = ref(null)

// 提供统一的消息通知方法
const showNotification = (message, type = 'success') => {
  if (messages.value) {
    messages.value.show(message, type)
  }
}

// 向所有子组件提供这个方法
provide('showNotification', showNotification)
</script>

<template>
  <div id="app">
    <Messages ref="messages" />
    <router-view />
  </div>
</template>

<style scoped>

</style>
