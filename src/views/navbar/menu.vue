<!-- 菜单组件 -->
<style lang="less">
@import "./styles/menu.less";
</style>

<template>
  <div class="sidebar-wrapper">
    <!-- 移动端菜单开关按钮 -->
    <div class="mobile-menu-toggle" v-if="showMobileToggle" @click="handleMobileToggle">
      <el-icon size="24"><Menu /></el-icon>
    </div>
    
    <!-- 收缩按钮 -->
    <div class="sidebar-shrink-button" v-if="showShrinkButton" @click="handleShrink">
      <el-icon size="20">
        <ArrowRight v-if="shrink" />
        <ArrowLeft v-else />
      </el-icon>
    </div>
    
    <!-- 用户面板 -->
    <div class="user-panel" v-if="showUserPanel">
      <div class="user-avatar">
        <!-- <el-icon size="24"><User /></el-icon> -->
      </div>
      <!-- <div class="user-info" v-show="!shrink">
        <div class="user-name">{{ username || '用户' }}</div>
        <div class="user-role">{{ userRole || '用户' }}</div>
      </div> -->
      <AvatarPopover 
      :username = "username"
      :userRole = "userRole"/>
    </div>
    
    <div :style="{background: bgColor}" class="ivu-shrinkable-menu">
      <slot name="top"></slot>
      <!-- 使用 Element UI 菜单组件 -->
      <el-menu
        :default-active="$route.name"
        :default-openeds="currentOpenedMenu"
        :collapse="shrink"
        :unique-opened="true"
        :background-color="bgColor"
        :text-color="textColor"
        :active-text-color="activeTextColor"
        class="el-menu-vertical"
        @select="handleChange"
        @open="handleOpen"
        @close="handleClose"
      >
        <template v-for="item in activeMenuList" :key="item.name">
          <el-sub-menu v-if="item.children && item.children.length" :index="item.name">
            <template #title>
              <el-icon>
                <component :is="getIcon(item.icon)" />
              </el-icon>
              <span>{{ item.title }}</span>
            </template>
            <el-menu-item 
              v-for="child in item.children" 
              :key="child.name" 
              :index="child.name"
            >
              <el-icon>
                <component :is="getIcon(child.icon)" />
              </el-icon>
              <span>{{ child.title }}</span>
            </el-menu-item>
          </el-sub-menu>
          <el-menu-item v-else :index="item.name">
            <el-icon>
              <component :is="getIcon(item.icon)" />
            </el-icon>
            <span>{{ item.title }}</span>
          </el-menu-item>
        </template>
      </el-menu>
    </div>
  </div>
</template>

<script>
import { User, Menu, Setting, Document, Location, Search, Star, Calendar, ArrowRight, ArrowLeft, ChatDotRound } from '@element-plus/icons-vue';
import AvatarPopover from '@/components/AvatarPopover.vue' 
export default {
  name: "shrinkableMenu",
  components: {
    User,
    Menu,
    Setting,
    Document,
    Location,
    Search,
    Star,
    Calendar,
    ArrowRight,
    ArrowLeft,
    ChatDotRound,
    AvatarPopover
  },
  props: {
    menuList: {
      type: Array,
      default: () => []
    },
    theme: {
      type: String,
      default: "dark",
      validator(val) {
        // 自行实现 oneOf 方法，不依赖 util
        return ["dark", "light"].includes(val);
      }
    },
    beforePush: {
      type: Function
    },
    openNames: {
      type: Array
    },
    // 是否收缩菜单
    shrink: {
      type: Boolean,
      default: false
    },
    // 显示移动端菜单开关
    showMobileToggle: {
      type: Boolean,
      default: true
    },
    // 显示用户面板
    showUserPanel: {
      type: Boolean,
      // default: false
      default: true
    },
    // 显示收缩按钮
    showShrinkButton: {
      type: Boolean,
      default: false
    },
    // 用户名
    username: {
      type: String,
      default: ""
    },
    // 用户角色
    userRole: {
      type: String,
      default: "user"
    },
    // 是否是管理员
    isAdmin: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    bgColor() {
      return this.theme === "dark" ? "#2daa9e" : "#fff";
    },
    textColor() {
      return this.theme === "dark" ? "rgba(255, 255, 255, 0.7)" : "#303133";
    },
    activeTextColor() {
      return this.theme === "dark" ? "#fff" : "#409EFF";
    },
    // 根据用户角色选择菜单
    activeMenuList() {
      // 如果外部传入了menuList，则优先使用外部传入的
      if (this.menuList && this.menuList.length > 0) {
        return this.menuList;
      }
      
      // 否则根据isAdmin属性选择内置菜单
      return this.isAdmin ? this.adminMenuList : this.userMenuList;
    }
  },
  data() {
    return {
      // 存储当前展开的菜单项
      currentOpenedMenu: sessionStorage.getItem('openedMenuItems') ? 
                         JSON.parse(sessionStorage.getItem('openedMenuItems')) : [],
                         
      // 管理员菜单列表
      adminMenuList: [
        {
          name: "adminbusinesscenter",
          title: "业务中心",
          icon: "ios-document",
          children: [
            { name: "trafficView", title: "平台流量统计", icon: "ios-document" },
            { name: "doctorManager", title: "医生管理", icon: "ios-person" },
          ],
        },
        {
          name: "adminusercenter",
          title: "用户中心",
          icon: "ios-person",
          children: [
            { name: "profile", title: "个人资料", icon: "ios-person" },
            { name: "settings", title: "账号设置", icon: "ios-settings" },
          ],
        },
      ],
      
      // 普通用户菜单列表
      userMenuList: [
        {
          name: "registercenter",
          title: "预约挂号",
          icon: "ios-calendar",
          children: [
            { name: "register", title: "预约挂号", icon: "ios-navigate" },
            { name: "comments", title: "医生评价", icon: "ios-search" },
          ],
        },
        {
          name: "usercenter",
          title: "用户中心",
          icon: "ios-person",
          children: [
            { name: "reserverecords", title: "预约记录", icon: "ios-calendar" },
            { name: "profile", title: "个人资料", icon: "ios-contact" },
            { name: "settings", title: "账号设置", icon: "ios-settings" },
          ],
        },
        {
          name: "assistant",
          title: "AI问诊助手",
          icon: "ios-chatbubble",
          children: [
            { name: "assistant", title: "AI问诊助手", icon: "ios-chatbubble" },
          ],
        },
      ]
    }
  },
  methods: {
    /**
     * 菜单变化时触发
     * @param {string} name - 菜单名称
     */
    // 在handleChange方法中添加强制刷新逻辑
    handleChange(name) {
      let willpush = true;
      // 如果 beforePush 存在，则调用 beforePush 方法
      if (this.beforePush !== undefined) {
        if (!this.beforePush(name)) {
          willpush = false;
        }
      }
      
      // 确定要跳转的路由名称
      let targetRoute = name;
      
      // 找到当前选中菜单项所属的父菜单
      let parentMenu = null;
      for (const item of this.activeMenuList) {
        if (item.children && item.children.some(child => child.name === name)) {
          parentMenu = item.name;
          break;
        }
      }
      
      // 如果找到父菜单，将其保存到sessionStorage
      if (parentMenu) {
        this.currentOpenedMenu = [parentMenu];
        sessionStorage.setItem('openedMenuItems', JSON.stringify(this.currentOpenedMenu));
      }
      
      if (willpush) {
        this.$router.push({
          name: targetRoute
        }).then(() => {
          // 添加强制刷新逻辑
          if (this.$route.name === targetRoute) {
            window.location.reload(); // 或使用 nextTick + 组件key更新
          }
        });
      }
      
      this.$emit("on-change", name);
    },
    
    /**
     * 处理子菜单展开事件
     * @param {string} index - 菜单索引
     */
    handleOpen(index) {
      // 更新当前展开的菜单到sessionStorage
      if (!this.currentOpenedMenu.includes(index)) {
        this.currentOpenedMenu.push(index);
        sessionStorage.setItem('openedMenuItems', JSON.stringify(this.currentOpenedMenu));
      }
    },
    
    /**
     * 处理子菜单关闭事件
     * @param {string} index - 菜单索引
     */
    handleClose(index) {
      // 从展开菜单列表中移除
      const i = this.currentOpenedMenu.indexOf(index);
      if (i > -1) {
        this.currentOpenedMenu.splice(i, 1);
        sessionStorage.setItem('openedMenuItems', JSON.stringify(this.currentOpenedMenu));
      }
    },
    
    /**
     * 处理移动端菜单开关点击
     */
    handleMobileToggle() {
      this.$emit("on-mobile-toggle");
    },

    /**
     * 处理收缩按钮点击
     */
    handleShrink() {
      this.$emit("on-shrink");
    },

    /**
     * 将原有图标转换为 Element UI 图标
     */
    getIcon(iconName) {
      // 简单映射一些常用的图标，实际使用时可能需要更完整的映射
      const iconMap = {
        'ios-person': 'User',
        'ios-settings': 'Setting',
        'ios-contact': 'User',
        'ios-document': 'Document',
        'ios-navigate': 'Location',
        'ios-search': 'Search',
        'ios-star': 'Star',
        'ios-calendar': 'Calendar',
        'ios-arrow-forward': 'ArrowRight',
        'ios-arrow-back': 'ArrowLeft',
        'ios-menu': 'Menu'
      };
      
      return iconMap[iconName] || 'Document'; // 默认返回 Document 图标
    }
  },
  mounted() {
    // 从当前路由确定需要展开的菜单
    if (this.$route.name) {
      for (const item of this.activeMenuList) {
        if (item.children && item.children.some(child => child.name === this.$route.name)) {
          if (!this.currentOpenedMenu.includes(item.name)) {
            this.currentOpenedMenu.push(item.name);
            sessionStorage.setItem('openedMenuItems', JSON.stringify(this.currentOpenedMenu));
          }
          break;
        }
      }
    }
  },
  
  // 监听路由变化，同步更新菜单展开状态
  watch: {
    '$route'(to) {
      if (to.name) {
        for (const item of this.activeMenuList) {
          if (item.children && item.children.some(child => child.name === to.name)) {
            if (!this.currentOpenedMenu.includes(item.name)) {
              this.currentOpenedMenu = [item.name];
              sessionStorage.setItem('openedMenuItems', JSON.stringify(this.currentOpenedMenu));
            }
            break;
          }
        }
      }
    }
  }
};
</script>