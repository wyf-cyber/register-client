import { createRouter, createWebHistory } from 'vue-router';
import Login from '@/views/login/index.vue'; // 新增登录/注册页面组件
import Settings from '@/views/userSetting/index.vue'; // 新增设置页面组件
import Profile from '@/views/userinfo/index.vue'; // 新增个人资料页面组件
import TrafficView from '@/views/trafficView/index.vue'; // 新增挂号流量统计页面组件
import Error404 from '@/views/template/404.vue';
import Error403 from '@/views/template/403.vue';
import Error500 from '@/views/template/500.vue';

const routes = [
  {
    path: '/',
    redirect: '/settings'
  },
  {
    path: '/login',
    name: 'login',
    component: Login,
    meta: { requiresUnauth: true }  // 添加未认证标志
  },
  {
    path: '/settings',
    name: 'settings',
    component: Settings,
    meta: { requiresAuth: true }
  },
  {
    path: '/profile',
    name: 'profile',
    component: Profile,
    meta: { requiresAuth: true }
  },
  {
    path: '/trafficView',
    name: 'trafficView',
    component: TrafficView,
    meta: { requiresAuth: true, requiresAdmin: true }
  },
  {
    path: '/403',
    name: 'error403',
    component: Error403
  },
  {
    path: '/404',
    name: 'error404',
    component: Error404
  },
  {
    path: '/500',
    name: 'error500',
    component: Error500
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/404'
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

// 路由导航守卫，检查用户是否已登录
router.beforeEach((to, from, next) => {
  const isAuthenticated = sessionStorage.getItem("isAuthenticated") === "true";
  const isAdmin = sessionStorage.getItem("UserRole") === "admin";

  // 处理需要认证的路由
  if (to.meta.requiresAuth && !isAuthenticated) {
    next({ name: 'login' }); // 改为重定向到登录页面
  } 
  // 处理未认证用户的路由
  else if (to.meta.requiresUnauth && isAuthenticated) {
    next({ name: 'settings' });
  } 
  // 处理管理员用户的路由
  else if (to.meta.requiresAdmin && !isAdmin) {
    next({ name: 'error403' });
  }
  else {
    next();
  }
});

export default router;
