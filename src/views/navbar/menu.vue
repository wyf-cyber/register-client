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
        <el-icon size="24"><User /></el-icon>
      </div>
      <div class="user-info" v-show="!shrink">
        <div class="user-name">{{ username || '用户' }}</div>
        <div class="user-role">{{ userRole || '用户' }}</div>
      </div>
    </div>
    
    <div :style="{background: bgColor}" class="ivu-shrinkable-menu">
      <slot name="top"></slot>
      <!-- 使用 Element UI 菜单组件 -->
      <el-menu
        :default-active="$route.name"
        :default-openeds="openNames"
        :collapse="shrink"
        :unique-opened="true"
        :background-color="bgColor"
        :text-color="textColor"
        :active-text-color="activeTextColor"
        class="el-menu-vertical"
        @select="handleChange"
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
    ChatDotRound
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
      default: false
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
            { name: "evaluate", title: "医生评价", icon: "ios-search" },
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
    handleChange(name) {
      let willpush = true;
      // 如果 beforePush 存在，则调用 beforePush 方法
      if (this.beforePush !== undefined) {
        if (!this.beforePush(name)) {
          willpush = false;
        }
      }
      // 如果点击的是个人资料，则跳转到个人资料页面
      if (name === "profile") {
        this.$router.push({
          name: "profile"
        });
      }
      // 如果点击的是账号设置，则跳转到账号设置页面
      if (name === "settings") {
        this.$router.push({
          name: "settings"
        });
      }
      // 如果点击的是挂号流量统计，则跳转到挂号流量统计页面
      if (name === "trafficView") {
        this.$router.push({
          name: "trafficView"
        });
      }
      // 如果点击的是AI问诊助手，则跳转到AI问诊助手页面
      if (name === "assistant") {
        this.$router.push({
          name: "assistant"
        });
      }
      // 如果点击的页面未知（未在菜单列表中），跳转至404页面
      if (true) {
        this.$router.push({
          name: "error404"
        });
      }
      
      if (willpush) {
        // 存储当前展开的菜单项到sessionStorage
        for (const item of this.activeMenuList) {
          if (item.children && item.children.some(child => child.name === name)) {
            // 保存父菜单名称
            this.currentOpenedMenu = [item.name];
            sessionStorage.setItem('openedMenuItems', JSON.stringify(this.currentOpenedMenu));
            break;
          }
        }
        
        this.$router.push({
          name: name
        });
      }
      this.$emit("on-change", name);
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
    // 恢复展开的菜单状态
    if (this.currentOpenedMenu.length > 0) {
      this.$nextTick(() => {
        // 确保菜单组件已完全加载
        setTimeout(() => {
          // 直接设置默认展开项，避免动画
          const menuEl = document.querySelector('.el-menu');
          if (menuEl && menuEl.__vue__) {
            menuEl.__vue__.openedMenus = this.currentOpenedMenu;
          }
        }, 0);
      });
    }
  }
};
</script>