<!-- 展开侧边栏 -->
<style lang="less" scoped>
@import "../styles/menu.less";

.layout-text {
    display: inline-block;
    white-space: nowrap;
    position: relative;
}

.ivu-menu {
    height: 100%;
    
    .ivu-menu-submenu {
        .ivu-menu-item {
            padding-left: 43px !important;
        }
    }
}

.ivu-menu-vertical .ivu-menu-item, 
.ivu-menu-vertical .ivu-menu-submenu-title {
    padding: 14px 24px;
    position: relative;
    cursor: pointer;
    z-index: 1;
    transition: all .3s ease-in-out;
}
</style>
<template>
  <Menu
    ref="sideMenu"
    accordion
    :active-name="$route.name"
    :open-names="singleOpenName"
    :theme="menuTheme"
    width="auto"
    @on-select="changeMenu"
  >
    <!-- 添加具体的菜单渲染 -->
    <template v-for="item in menuList" :key="item.name">
      <Submenu :name="item.name">
        <template #title>
          <Icon :type="item.icon" />
          <span>{{ item.title }}</span>
        </template>
        <MenuItem v-for="child in item.children" 
                 :key="child.name"
                 :name="child.name">
          <Icon :type="child.icon" />
          <span>{{ child.title }}</span>
        </MenuItem>
      </Submenu>
    </template>
  </Menu>
</template>

<script>
export default {
  name: "sidebarMenu",
  data() {
    return {
      singleOpenName: [] // 单个展开的名称
    };
  },
  props: {
    menuList: Array, // 菜单列表
    iconSize: Number, // 图标大小
    menuTheme: {
      type: String,
      default: "dark" // 菜单主题
    },
    openNames: {
      type: Array
    }
  },
  methods: {
    changeMenu(active) {
      this.$emit("on-change", active);
    },
    handleSelect(name) {
      this.$emit("on-select", name);
    },
    itemTitle(item) {
      return item.title;
    },
    getOpenedNamesByActiveName(name) {
      return this.$route.matched
        .map(item => item.name)
        .filter(item => item !== name);
    }
  },
  updated() {
    this.$nextTick(() => {
      if (this.$refs.sideMenu) {
        this.$refs.sideMenu.updateOpened();
      }
    });
  },
  watch: {
    // 监听路由变化
    $route(to, from) {
      this.singleOpenName = [this.$route.matched[0].name];
    }
  },
  mounted() {
    this.singleOpenName = [this.$route.matched[0].name];
  }
};
</script>