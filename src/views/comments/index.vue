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
const selectedRating = ref(0); // 添加评分筛选
const messagesRef = ref(null);

// 过滤后的评论列表
const filteredComments = computed(() => {
  let filtered = comments.value;
  
  // 按医生姓名筛选
  if (selectedDoctor.value) {
    const query = selectedDoctor.value.toLowerCase();
    filtered = filtered.filter(comment => 
      comment.doctor.toLowerCase().includes(query)
    );
  }
  
  // 按评分筛选
  if (selectedRating.value > 0) {
    filtered = filtered.filter(comment => 
      comment.rating === selectedRating.value
    );
  }
  
  return filtered;
});

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

// 重置筛选条件
const resetFilters = () => {
    selectedDoctor.value = '';
    selectedRating.value = 0;
    getComments();
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
    
    <!-- 消息通知组件 -->
    <Messages ref="messagesRef" />
    
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
      
      <!-- 页面内容 -->
      <div class="layout-main" :style="mainContentStyle">
        <div class="content-wrapper">
          <h1>医生评价系统</h1>
          
          <!-- 导航选项卡 -->
          <div class="tabs">
            <div 
              class="tab" 
              :class="{ active: activeTab === 'commentsList' }"
              @click="switchTab('commentsList')"
            >
              评价列表
            </div>
            <div 
              class="tab" 
              :class="{ active: activeTab === 'addComment' }"
              @click="switchTab('addComment')"
            >
              添加评价
            </div>
          </div>
          
          <!-- 加载中提示 -->
          <div v-if="loading" class="loading-container">
            <CircleLoading />
            <span>加载中...</span>
          </div>
          
          <div v-else>
            <!-- 评价列表 -->
            <div v-if="activeTab === 'commentsList'" class="comments-list-container">
              <!-- 筛选工具栏 -->
              <div class="filter-bar">
                <div class="search-box">
                  <input
                    type="text"
                    placeholder="搜索医生姓名..."
                    v-model="selectedDoctor"
                    @keyup.enter="getCommentsByDoctor"
                  />
                  <button class="search-btn" @click="getCommentsByDoctor">
                    <i class="ivu-icon ivu-icon-ios-search"></i>
                    搜索
                  </button>
                </div>
                
                <div class="rating-filter">
                  <label>评分筛选：</label>
                  <div class="rating-selector">
                    <span 
                      v-for="n in 5" 
                      :key="n" 
                      class="star-selector"
                      :class="{ 
                        selected: n <= selectedRating,
                        hovered: n <= hoverRating
                      }"
                      @click="selectedRating = selectedRating === n ? 0 : n"
                      @mouseover="hoverRating = n"
                      @mouseleave="hoverRating = 0"
                    >★</span>
                    <span class="rating-text">{{ selectedRating ? `${selectedRating}星` : '全部' }}</span>
                  </div>
                </div>
                
                <button class="reset-btn" @click="resetFilters">
                  <i class="ivu-icon ivu-icon-ios-refresh"></i>
                  重置筛选
                </button>
              </div>
              
              <!-- 评价列表 -->
              <div class="comments-grid">
                <div 
                  v-for="(comment, index) in filteredComments" 
                  :key="index"
                  class="comment-card"
                >
                  <div class="comment-header">
                    <h3>{{ comment.doctor }}</h3>
                    <div class="rating-badge">
                      <span v-for="n in 5" :key="n" class="star" :class="{ filled: n <= comment.rating }">★</span>
                    </div>
                  </div>
                  <div class="comment-content">{{ comment.content }}</div>
                </div>
                <div v-if="filteredComments.length === 0" class="empty-data">
                  暂无评价数据
                </div>
              </div>
            </div>
            
            <!-- 添加评价表单 -->
            <div v-if="activeTab === 'addComment'" class="add-comment-container">
              <div class="comment-form">
                <div class="form-group">
                  <label>医生姓名：</label>
                  <input type="text" v-model="newComment.doctor" placeholder="请输入医生姓名" required />
                </div>
                
                <div class="form-group">
                  <label>评价内容：</label>
                  <textarea v-model="newComment.content" placeholder="请输入您的评价内容" rows="4" required></textarea>
                </div>
                
                <div class="form-group">
                  <label>评分：</label>
                  <div class="rating-selector">
                    <span 
                      v-for="n in 5" 
                      :key="n" 
                      class="star-selector"
                      :class="{ 
                        selected: n <= newComment.rating,
                        hovered: n <= hoverRating
                      }"
                      @click="newComment.rating = n"
                      @mouseover="hoverRating = n"
                      @mouseleave="hoverRating = 0"
                    >★</span>
                    <span class="rating-text">{{ newComment.rating ? `${newComment.rating}星` : '请选择评分' }}</span>
                  </div>
                </div>
                
                <div class="form-actions">
                  <button class="submit-btn" @click="addComment">提交评价</button>
                  <button class="cancel-btn" @click="switchTab('commentsList')">取消</button>
                </div>
              </div>
            </div>
          </div>
        </div>
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

h1 {
  margin-bottom: 30px;
  color: #343a40;
  text-align: center;
  font-size: 28px;
  font-weight: bold;
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

/* 标签页 */
.tabs {
  display: flex;
  margin-bottom: 30px;
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

.tab:hover {
  color: #2daa9e;
}

.tab.active {
  color: #2daa9e;
  font-weight: bold;
}

.tab.active:after {
  content: '';
  position: absolute;
  bottom: -1px;
  left: 0;
  width: 100%;
  height: 2px;
  background: #2daa9e;
}

/* 筛选工具栏 */
.filter-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  flex-wrap: wrap;
  gap: 15px;
  background: white;
  padding: 15px;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
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
  white-space: nowrap;
}

.search-btn:hover {
  background: #248f85;
}

.rating-filter {
  display: flex;
  align-items: center;
  gap: 10px;
}

.rating-filter label {
  font-weight: bold;
  color: #606266;
  white-space: nowrap;
}

.reset-btn {
  display: flex;
  align-items: center;
  gap: 5px;
  padding: 10px 15px;
  background: #909399;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  transition: background-color 0.3s;
  white-space: nowrap;
}

.reset-btn:hover {
  background: #a6a9ad;
}

.reset-btn i {
  font-size: 16px;
}

/* 评价列表网格 */
.comments-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
  margin-top: 20px;
}

.comment-card {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  padding: 20px;
  display: flex;
  flex-direction: column;
  transition: transform 0.3s, box-shadow 0.3s;
}

.comment-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.15);
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

/* 添加评价表单 */
.add-comment-container {
  max-width: 600px;
  margin: 0 auto;
}

.comment-form {
  background: white;
  border-radius: 8px;
  padding: 30px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
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
  gap: 10px;
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
  color: #606266;
  font-size: 14px;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 15px;
  margin-top: 30px;
}

.submit-btn, .cancel-btn {
  padding: 10px 20px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  color: white;
  transition: background-color 0.3s;
}

.submit-btn {
  background: #2daa9e;
}

.submit-btn:hover {
  background: #248f85;
}

.cancel-btn {
  background: #909399;
}

.cancel-btn:hover {
  background: #a6a9ad;
}

.empty-data {
  text-align: center;
  padding: 30px;
  color: #909399;
  grid-column: 1 / -1;
  background: white;
  border-radius: 8px;
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