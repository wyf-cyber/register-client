<!-- 收缩侧边栏 -->
<template>
    <div>
      <template v-for="(item, index) in menuList" :key="index">
        <div style="text-align: center;">
          <Dropdown
            transfer
            v-if="item.children.length !== 1"
            placement="right-start"
            @on-click="changeMenu"
          >
            <Button style="width: 70px;height: 42px;margin-left: -5px;padding:10px 0;" type="text">
              <Icon :size="20" :color="iconColor" :type="item.icon"></Icon>
            </Button>
            <DropdownMenu style="width: 200px;" slot="list">
              <template v-for="(child, i) in item.children" :key="i">
                <DropdownItem :name="child.name">
                  <Icon :type="child.icon"></Icon>
                  <span style="padding-left:10px;">{{ itemTitle(child) }}</span>
                </DropdownItem>
              </template>
            </DropdownMenu>
          </Dropdown>
          <Dropdown transfer v-else placement="right-start" @on-click="changeMenu">
            <Button
              @click="changeMenu(item.children[0].name)"
              style="width: 70px;height: 42px;margin-left: -5px;padding:10px 0;"
              type="text"
            >
              <Icon :size="20" :color="iconColor" :type="item.children[0].icon || item.icon"></Icon>
            </Button>
            <DropdownMenu style="width: 200px;" slot="list">
              <DropdownItem :name="item.children[0].name" :key="'d' + index">
                <Icon :type="item.children[0].icon || item.icon"></Icon>
                <span style="padding-left:10px;">{{ itemTitle(item.children[0]) }}</span>
              </DropdownItem>
            </DropdownMenu>
          </Dropdown>
        </div>
      </template>
    </div>
  </template>
  
  <script>
  export default {
    name: "sidebarMenuShrink",
    props: {
      menuList: {
        type: Array
      },
      iconColor: {
        type: String,
        default: "white"
      },
      menuTheme: {
        type: String,
        default: "dark"
      }
    },
    methods: {
      changeMenu(active) {
        this.$emit("on-change", active);
      },
      itemTitle(item) {
        return item.title;
      }
    }
  };
  </script>
  