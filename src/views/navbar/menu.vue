<!-- 菜单组件 -->
<style lang="less">
@import "./styles/menu.less";
</style>

<template>
  <div class="sidebar-wrapper">
    <!-- 移动端菜单开关按钮 -->
    <div class="mobile-menu-toggle" v-if="showMobileToggle" @click="handleMobileToggle">
      <Icon type="ios-menu" size="30" />
    </div>
    
    <div :style="{background: bgColor}" class="ivu-shrinkable-menu">
      <slot name="top"></slot>
      <sidebar-menu
        v-show="!shrink"
        :menu-theme="theme"
        :menu-list="menuList"
        :open-names="openNames"
        @on-change="handleChange"
      ></sidebar-menu>
      <sidebar-menu-shrink
        v-show="shrink"
        :menu-theme="theme"
        :menu-list="menuList"
        :icon-color="shrinkIconColor"
        @on-change="handleChange"
      ></sidebar-menu-shrink>
    </div>
  </div>
</template>

<script>
import sidebarMenu from "./components/sidebar.vue";
import sidebarMenuShrink from "./components/sidebarshrink.vue";
import util from "@/utils/util";
export default {
  name: "shrinkableMenu",
  components: {
    sidebarMenu,
    sidebarMenuShrink
  },
  props: {
    shrink: {
      type: Boolean,
      default: false
    },
    menuList: {
      type: Array,
      required: true
    },
    theme: {
      type: String,
      default: "dark",
      validator(val) {
        return util.oneOf(val, ["dark", "light"]);
      }
    },
    beforePush: {
      type: Function
    },
    openNames: {
      type: Array
    },
    // 新增属性：是否显示移动端菜单开关
    showMobileToggle: {
      type: Boolean,
      default: true
    }
  },
  computed: {
    bgColor() {
      return "#323232";
    },
    /* 收缩状态下的图标颜色 */
    shrinkIconColor() {
      return this.theme == "dark" ? "#fff" : "#515a6e";
    }
  },
  methods: {
    /**
     * 菜单变化时触发
     * @param {string} name - 菜单名称
     */
    handleChange(name) {
      let willpush = true;
      if (this.beforePush !== undefined) {
        if (!this.beforePush(name)) {
          willpush = false;
        }
      }
      if (willpush) {
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
    }
  }
};
</script>