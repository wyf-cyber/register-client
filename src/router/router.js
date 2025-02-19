import { createRouter, createWebHistory } from 'vue-router';
import Auth from '@/Auth.vue'; // 新增登录/注册页面组件

const routes = [
  {
    path: '/auth', // 登录/注册页面路由
    component: Auth
  },
  {
    path: '/', 
    component: Navbar, 
    redirect: '/settings',   // 登陆后，重定向到主页面
    meta: { requiresAuth: true }, // 主页面路由，添加认证标志
    children: [
      // { path: '/', component: }
    ]
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
    next('/auth');
  } else if (to.path === '/auth' && isAuthenticated) {
    next('/'); 
  } else {
    next(); 
  }
});

export default router;
