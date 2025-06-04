<script setup>
import { ref, onMounted, computed, onUnmounted } from 'vue';
import { useRouter } from "vue-router";
import { getAllCommentsService, getCommentsByDoctorService, addCommentService } from '@/views/comments/api';
import { ElMessage } from 'element-plus';
import PageHeader from "@/views/components/header.vue";
import CircleLoading from "@/views/components/circle_loading.vue";
import ShrinkableMenu from "@/views/navbar/menu.vue";
import Messages from "@/views/components/messages.vue";

// 格式化日期
const formatDate = (dateObj) => {
  if (!dateObj) return '';
  const date = new Date(dateObj);
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
};

// 定义状态变量
const router = useRouter();
const username = ref(sessionStorage.getItem("UserName") || "未登录");
const userRole = ref(sessionStorage.getItem("UserRole") === "admin" ? "管理员" : "普通用户");
const isAdmin = ref(sessionStorage.getItem("UserRole") === "admin");
const isCollapsed = ref(sessionStorage.getItem("sidebarCollapsed") === "true" ? true : false);
const loading = ref(true);
const showMobileMenu = ref(false);
const singleOpenName = ref(["admin"]); // 控制菜单展开状态
const menuTheme = ref("dark"); // 菜单主题

// 添加活动标签页状态
const activeTab = ref("commentsList"); // commentsList, addComment

// 添加悬停评分状态
const hoverRating = ref(0);

const comments = ref([]);
const newComment = ref({
    doctor: '',
    content: '',
    rating: 0
});
const selectedDoctor = ref('');
const messagesRef = ref(null);

// 菜单处理
const handleMenuChange = (name) => {
  router.push({ name });
};

const changeMenu = (name) => {
  handleMenuChange(name);
};

// 侧边栏折叠切换
const toggleCollapse = () => {
  isCollapsed.value = !isCollapsed.value;
  sessionStorage.setItem("sidebarCollapsed", isCollapsed.value);
};

// 添加计算属性，计算主内容区域的样式
const mainContentStyle = computed(() => {
  const sidebarWidth = isCollapsed.value ? 80 : 80;  // 
  return {
    marginLeft: `${sidebarWidth}px`,
    width: `calc(100% - ${sidebarWidth}px)`
  };
});

// 处理移动端菜单切换
const handleMobileToggle = () => {
  showMobileMenu.value = !showMobileMenu.value;
};

// 切换标签页
const switchTab = (tab) => {
  activeTab.value = tab;
  if (tab === 'commentsList') {
    getComments();
  } else if (tab === 'addComment') {
    // 重置表单
    newComment.value = {
      doctor: '',
      content: '',
      rating: 0
    };
  }
};

const getComments = async () => {
    loading.value = true;
    try {
        const result = await getAllCommentsService();
        comments.value = result;
    } catch (error) {
        ElMessage.error('获取评论失败：' + error.message);
    } finally {
        loading.value = false;
    }
};

const getCommentsByDoctor = async () => {
    loading.value = true;
    try {
        if (!selectedDoctor.value.trim()) {
            await getComments();
            return;
        }
        const result = await getCommentsByDoctorService(selectedDoctor.value);
        comments.value = result;
    } catch (error) {
        ElMessage.error('获取该医生的评论失败：' + error.message);
    } finally {
        loading.value = false;
    }
};

const addComment = async () => {
    if (!newComment.value.doctor || !newComment.value.content || newComment.value.rating === 0) {
        messagesRef.value.show('请填写所有必填项', 'warning');
        return;
    }
    loading.value = true;
    try {
        const result = await addCommentService(newComment.value.doctor, newComment.value.content, newComment.value.rating);
        messagesRef.value.show('评论添加成功', 'success');
        
        // 重置表单
        newComment.value = {
            doctor: '',
            content: '',
            rating: 0
        };
        
        // 切换到评论列表页并刷新数据
        switchTab('commentsList');
    } catch (error) {
        messagesRef.value.show('评论添加失败：' + error.message, 'error');
    } finally {
        loading.value = false;
    }
};

// 窗口大小变化时重新调整
const handleResize = () => {
  // 如果有图表，可以在这里处理图表大小调整
};

onMounted(() => {
    getComments();
    window.addEventListener('resize', handleResize);
});

onUnmounted(() => {
  window.removeEventListener('resize', handleResize);
});
</script>

<template>
<div class="layout">
    <PageHeader class="layout-header" />
    
    <!-- 新增布局容器 -->
    <div class="layout-container">
      <!-- 侧边栏 -->
      <div class="layout-sider" :class="{ collapsed: isCollapsed, 'mobile-open': showMobileMenu }">
        <ShrinkableMenu 
          :shrink="isCollapsed"
          :theme="menuTheme"
          :open-names="singleOpenName"
          :show-mobile-toggle="true"
          :show-user-panel="true"
          :show-shrink-button="true"
          :username="username"
          :userRole="userRole"
          :isAdmin="isAdmin"
          @on-change="changeMenu"
          @on-mobile-toggle="handleMobileToggle"
          @on-shrink="toggleCollapse"
        />
      </div>
      <div class="comments-container">
        <el-row :gutter="10">
            <el-col :span="18">
                <el-input v-model="selectedDoctor" placeholder="医生姓名" suffix-icon="el-icon-search" />
            </el-col>
            <el-col :span="6">
                <el-button type="primary" @click="getCommentsByDoctor">查询</el-button>
            </el-col>
        </el-row>

        <el-table :data="comments" style="width: 100%" v-if="comments.length > 0">
            <el-table-column prop="doctor" label="医生" width="200" />
            <el-table-column prop="content" label="评论内容" width="300" />
            <el-table-column prop="rating" label="评分" width="200" />
        </el-table>

        <h2 style="text-align: center; font-weight: bold;">添加评论</h2>
        <el-form ref="addCommentForm" :model="newComment" label-width="80px">
            <el-form-item label="医生">
                <el-input v-model="newComment.doctor" placeholder="医生姓名"></el-input>
            </el-form-item>
            <el-form-item label="评论内容">
                <el-input type="textarea" v-model="newComment.content" placeholder="评论内容"></el-input>
            </el-form-item>
            <el-form-item label="评分">
                <el-input-number v-model="newComment.rating" :min="1" :max="5" placeholder="评分"></el-input-number>
            </el-form-item>
            <el-form-item>
                <el-button type="primary" @click="addComment">添加评论</el-button>
            </el-form-item>
        </el-form>
        </div>
      
    </div>
</div>
</template>

<style lang="less" scoped>
.layout {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  width: 100%;
  overflow-x: hidden;
  background-color: #f5f7fa;

  /* 头部 */
  &-header {
    height: 60px;
    width: 100%;
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    z-index: 1000;
  }
  
  /* 新增的容器层 */
  &-container {
    display: flex;
    position: fixed;
    left: 0;
    right: 0;
    bottom: 0;
    flex-direction: row;
    margin-top: 60px;
    height: calc(100vh - 60px);
    width: 100%;
    background-color: #f5f7fa;
  }

  /* 侧边栏 */
  &-sider {
    width: 200px;
    height: 100%;
    top: 0;
    // margin-top: 60px;
    flex-shrink: 0;
    // background: #4f959d;
    background: #2daa9e;
    transition: all 0.8s ease;
    box-shadow: 2px 0 6px rgba(0,0,0,0.1);
    position: relative;

    &.collapsed {
      width: 80px;
    }
  }

  /* 主内容区域 */
  &-main {
    flex: 1;  
    padding: 20px;
    box-sizing: border-box;
    // margin-top: 60px;
    height: calc(100vh - 60px);
    overflow-y: auto;
    background: #f5f7fa;
  }
}

.comments-container {
    max-width: 1200px;
    border-radius: 8px;
    display: flex;
    flex-direction: column;
    // align-items: flex-start;
    align-items: stretch;
    margin: 0 auto;
  /* 容器层 */
  &-container {
    display: flex;
    position: fixed;
    left: 0;
    right: 0;
    bottom: 0;
    flex-direction: row;
    margin-top: 60px;
    height: calc(100vh - 60px);
    width: 100%;
    background-color: #f5f7fa;
  }

  /* 侧边栏 */
  &-sider {
    width: 200px;
    height: 100%;
    top: 0;
    flex-shrink: 0;
    background: #2daa9e;
    transition: all 0.8s ease;
    box-shadow: 2px 0 6px rgba(0,0,0,0.1);
    position: relative;

    &.collapsed {
      width: 80px;
    }
  }

  /* 主内容区域 */
  &-main {
    flex: 1;  
    padding: 20px;
    box-sizing: border-box;
    height: calc(100vh - 60px);
    overflow-y: auto;
    background: #f5f7fa;
  }
}

/* 选项卡样式 */
.tabs {
  display: flex;
  margin-bottom: 20px;
  border-bottom: 1px solid #dcdfe6;
}

.tab {
  padding: 10px 20px;
  cursor: pointer;
  font-size: 16px;
  color: #606266;
  position: relative;
  transition: all 0.3s;
}

.tab.active {
  color: #2daa9e;
  font-weight: bold;
}

.tab.active::after {
  content: '';
  position: absolute;
  bottom: -1px;
  left: 0;
  width: 100%;
  height: 2px;
  background-color: #2daa9e;
}

.tab:hover {
  color: #2daa9e;
}

@media screen and (max-width: 768px) {
  .layout {
    &-container {
      flex-direction: column;
    }
    
    &-sider {
      width: 100% !important;
      height: auto;
      
      &.collapsed {
        display: none;
      }
      
      &.mobile-open {
        display: block;
      }
    }
  }
}

h1 {
  margin-bottom: 30px;
  color: #343a40;
  text-align: center;
  font-size: 28px;
  font-weight: bold;
}

h2 {
  font-size: 20px;
  margin: 30px 0 20px;
  font-weight: bold;
  color: #303133;
}

.content-wrapper {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

/* 加载动画 */
.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 50px;
}

/* 评论容器 */
.comments-container, .add-comment-container {
  display: flex;
  flex-direction: column;
  width: 100%;
}

/* 筛选工具栏 */
.filter-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  flex-wrap: wrap;
  gap: 15px;
}

.search-box {
  display: flex;
  align-items: center;
  gap: 10px;
  width: 100%;
  max-width: 500px;
}

.search-box input {
  padding: 10px 15px;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  width: 100%;
  font-size: 14px;
}

.search-btn {
  display: flex;
  align-items: center;
  gap: 5px;
  padding: 10px 15px;
  background: #2daa9e;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  transition: background-color 0.3s;
  width: 100px;
}

.search-btn:hover {
  background: #248f85;
}

.search-btn .search-icon {
  font-size: 16px;
  width: 20px;
  text-align: center;
}

.search-btn i {
  font-size: 16px;
}

/* 评论列表部分 */
.comments-section {
  background: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  margin-bottom: 30px;
}

.comments-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
  margin-top: 20px;
}

.comment-card {
  background: #f9f9f9;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  padding: 20px;
  display: flex;
  flex-direction: column;
  transition: transform 0.3s, box-shadow 0.3s;
}

.comment-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}

.comment-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
  border-bottom: 1px solid #eee;
  padding-bottom: 10px;
}

.comment-header h3 {
  margin: 0;
  font-size: 18px;
  color: #303133;
}

.rating-badge {
  display: flex;
}

.star {
  color: #dcdfe6;
  font-size: 18px;
}

.star.filled {
  color: #f7ba2a;
}

.comment-content {
  color: #606266;
  font-size: 14px;
  line-height: 1.6;
}

/* 添加评论部分 */
.add-comment-section {
  background: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.comment-form {
  max-width: 600px;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: bold;
  color: #606266;
}

.form-group input, 
.form-group textarea {
  width: 100%;
  padding: 10px;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  font-size: 14px;
  box-sizing: border-box;
}

.form-group textarea {
  resize: vertical;
  min-height: 100px;
}

.rating-selector {
  display: flex;
  align-items: center;
}

.star-selector {
  font-size: 24px;
  color: #dcdfe6;
  cursor: pointer;
  transition: color 0.3s;
}

.star-selector.selected {
  color: #f7ba2a;
}

.star-selector.hovered {
  color: #f7ba2a;
}

.rating-text {
  margin-left: 10px;
  color: #606266;
}

.form-actions {
  display: flex;
  justify-content: flex-start;
  margin-top: 20px;
}

.submit-btn {
  padding: 10px 20px;
  background: #2daa9e;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  transition: background-color 0.3s;
}

.submit-btn:hover {
  background: #248f85;
}

.empty-data {
  text-align: center;
  padding: 30px;
  color: #909399;
  background: #f9f9f9;
  border-radius: 8px;
  margin: 20px 0;
}

@media screen and (max-width: 768px) {
  .comments-grid {
    grid-template-columns: 1fr;
  }
  
  .filter-bar {
    flex-direction: column;
    align-items: stretch;
  }
  
  .search-box {
    width: 100%;
  }
  
  .form-actions {
    flex-direction: column;
  }
  
  .form-actions button {
    width: 100%;
  }
}
</style>