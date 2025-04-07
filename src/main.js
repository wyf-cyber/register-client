import './assets/main.css'
import { createApp } from 'vue'
import App from './App.vue'
import router from './router/router.js';
import ViewUIPlus from 'view-ui-plus'
import 'view-ui-plus/dist/styles/viewuiplus.css'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'


const app= createApp(App)
app.use(router)
app.use(ViewUIPlus)
app.use(ElementPlus)
app.mount('#app');

