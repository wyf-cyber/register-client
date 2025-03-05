import { createRouter, createWebHistory } from 'vue-router';
import Auth from '@/Auth.vue'; // 新增登录/注册页面组件
import Settings from '@/Settings.vue'; // 新增设置页面组件

const routes = [
  {
    path: '/',
    redirect: '/settings'
  },
  {
    path: '/auth',
    name: 'auth',
    component: Auth,
    meta: { requiresUnauth: true }  // 添加未认证标志
  },
  {
    path: '/settings',
    name: 'settings',
    component: Settings,
    meta: { requiresAuth: true }
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

// 路由导航守卫，检查用户是否已登录
router.beforeEach((to, from, next) => {
  const isAuthenticated = sessionStorage.getItem("isAuthenticated") === "true";

  if (to.meta.requiresAuth && !isAuthenticated) {
    next({ name: 'auth' });
  } else if (to.meta.requiresUnauth && isAuthenticated) {
    next({ name: 'settings' });
  } else {
    next();
  }
});

export default router;
