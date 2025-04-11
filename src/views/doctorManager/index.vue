<!-- 医生人员管理页面，涉及医生人员信息管理、医生人员排班管理 -->
<script setup>
import { ref, onMounted, computed, reactive, nextTick, watch, onUnmounted } from "vue";
import { useRouter } from "vue-router";
import PageHeader from "@/views/components/header.vue";
import CircleLoading from "@/views/components/circle_loading.vue";
import ShrinkableMenu from "@/views/navbar/menu.vue";
import Messages from "@/views/components/messages.vue";
import { 
  addDoctorService, 
  updateDoctorService, 
  deleteDoctorService, 
  getDoctorsByDepartmentService, 
  getDoctorScheduleService
} from "@/views/doctorManager/api";

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

// 医生管理数据
const activeTab = ref("doctorList"); // doctorList, addDoctor, schedule
const doctorsList = ref([]);
const allDoctorsList = ref([]); // 存储所有医生信息
const scheduleList = ref([]);
const selectedDate = ref(formatDate(new Date()));
const departments = ref(['内科', '外科', '儿科', '眼科', '皮肤科', '妇科', '骨科', '神经科', '精神科', '口腔科']);
const selectedDepartment = ref('全部');
const searchQuery = ref('');
const isGlobalSearch = ref(false); // 控制是否进行全局搜索

// 新增/编辑医生的表单
const doctorForm = reactive({
  department: '',
  doctor: '',
  detail: '',
  day: formatDate(new Date()),
  isEdit: false,
  originalDepartment: '',
  originalDoctor: '',
  originalDay: ''
});

// 新增存储原始医生信息的变量，用于更新操作
const originalDoctor = reactive({
  department: '',
  doctor: '',
  day: '',
  detail: ''
});

// 删除确认框
const deleteModal = reactive({
  visible: false,
  department: '',
  doctor: '',
  day: ''
});

// 医生详情模态框
const doctorDetailModal = reactive({
  visible: false,
  department: '',
  doctor: '',
  detail: '',
  state: 0
});

// 消息通知引用
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

// 过滤后的医生列表
const filteredDoctors = computed(() => {
  // 确定使用哪个数据源
  let sourceList = isGlobalSearch.value ? allDoctorsList.value : doctorsList.value;
  let filtered = sourceList;
  
  // 按科室筛选
  if (selectedDepartment.value !== '全部') {
    filtered = filtered.filter(doctor => doctor.department === selectedDepartment.value);
  }
  
  // 按搜索词筛选
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase();
    filtered = filtered.filter(doctor => 
      (doctor.doctor && doctor.doctor.toLowerCase().includes(query)) || 
      (doctor.detail && doctor.detail.toLowerCase().includes(query))
    );
  }
  
  return filtered;
});

// 获取医生列表
const fetchDoctorSchedule = async () => {
  loading.value = true;
  try {
    const response = await getDoctorScheduleService(selectedDate.value);
    scheduleList.value = response || [];
    doctorsList.value = scheduleList.value;
  } catch (error) {
    console.error("获取医生排班出错:", error);
  } finally {
    loading.value = false;
  }
};

// 获取所有科室的医生信息
const fetchAllDoctors = async () => {
  loading.value = true;
  try {
    const allDoctors = [];
    
    // 遍历所有科室，获取各科室医生
    for (const dept of departments.value) {
      try {
        const deptDoctors = await getDoctorsByDepartmentService(dept);
        // 调试日志
        console.log(`${dept}科室医生原始数据:`, deptDoctors);
        
        if (deptDoctors && deptDoctors.length > 0) {
          // 添加科室信息到医生数据中
          deptDoctors.forEach(doctor => {
            // 确保work_date字段存在，如果不存在则使用当前选中日期
            const doctorData = {
              ...doctor,   // 解构医生对象
              department: doctor.department || dept, // 确保科室信息正确
              state: doctor.state || 0, // 确保状态信息存在
              work_date: doctor.work_date || selectedDate.value // 确保工作日期存在
            };
            
            allDoctors.push(doctorData);
          });
        }
      } catch (deptError) {
        console.error(`获取${dept}科室医生出错:`, deptError);
      }
    }
    
    allDoctorsList.value = allDoctors;
    console.log("已获取所有医生信息:", allDoctorsList.value);
  } catch (error) {
    console.error("获取所有医生信息出错:", error);
  } finally {
    loading.value = false;
  }
};

// 切换标签页
const switchTab = (tab) => {
  activeTab.value = tab;
  if (tab === 'doctorList') {
    // 切换到医生列表时，需要同时获取当前日期的排班数据和全局医生数据
    fetchDoctorSchedule();
    
    // 如果之前已有全局搜索，则刷新全局医生列表
    if (isGlobalSearch.value || allDoctorsList.value.length === 0) {
      fetchAllDoctors();
    }
  } else if (tab === 'schedule') {
    fetchDoctorSchedule();
  } else if (tab === 'addDoctor') {
    // 重置表单
    Object.assign(doctorForm, {
      department: '',
      doctor: '',
      detail: '',
      day: formatDate(new Date()),
      isEdit: false
    });
    
    // 重置原始医生信息
    Object.assign(originalDoctor, {
      department: '',
      doctor: '',
      day: '',
      detail: ''
    });
  }
};

// 删除医生
const confirmDeleteDoctor = (department, doctor, day) => {
  deleteModal.visible = true;
  deleteModal.department = department;
  deleteModal.doctor = doctor;
  deleteModal.day = day;
};

const deleteDoctor = async () => {
  loading.value = true;
  try {
    await deleteDoctorService(
      deleteModal.department, 
      deleteModal.doctor, 
      deleteModal.day
    );
    messagesRef.value.show("医生信息删除成功", "success");
    deleteModal.visible = false;
    
    // 更新所有医生数据
    fetchDoctorSchedule();
    fetchAllDoctors(); // 更新全局医生列表
  } catch (error) {
    console.error("删除医生信息出错:", error);
    messagesRef.value.show("删除医生信息失败，请重试", "error");
  } finally {
    loading.value = false;
  }
};

// 编辑医生信息
const editDoctor = (doctor) => {
  // 调试日志，查看doctor对象原始数据
  console.log("编辑医生原始数据:", doctor);
  
  // 关键点：确保工作日期是正确的
  // 如果是从全局医生列表编辑，必须使用当前选中日期作为work_date
  // 如果是从排班表编辑，则直接使用doctor.work_date
  const workDate = doctor.work_date || selectedDate.value;
  
  // 记录日志，帮助调试
  console.log("使用的工作日期:", workDate);
  
  // 存储原始医生信息，这些信息将用作数据库查询条件
  Object.assign(originalDoctor, {
    department: doctor.department,
    doctor: doctor.doctor,
    day: workDate,
    detail: doctor.detail
  });
  
  // 设置表单数据，这些将是用户可以编辑的新值
  Object.assign(doctorForm, {
    department: doctor.department,
    doctor: doctor.doctor,
    detail: doctor.detail,
    day: workDate,
    isEdit: true
  });
  
  // 记录表单数据日志，方便调试
  console.log("编辑数据:", {
    原始数据: {
      科室: originalDoctor.department,
      医生: originalDoctor.doctor,
      日期: originalDoctor.day,
      详情: originalDoctor.detail
    },
    表单数据: {
      科室: doctorForm.department,
      医生: doctorForm.doctor,
      日期: doctorForm.day,
      详情: doctorForm.detail
    }
  });
  
  activeTab.value = 'addDoctor';
};

// 查看医生详情
const viewDoctorDetail = (doctor) => {
  Object.assign(doctorDetailModal, {
    visible: true,
    department: doctor.department,
    doctor: doctor.doctor,
    detail: doctor.detail,
    state: doctor.state
  });
};

// 提交医生表单
const submitDoctorForm = async () => {
  if (!doctorForm.department || !doctorForm.doctor || !doctorForm.detail || !doctorForm.day) {
    messagesRef.value.show("请填写完整的医生信息", "warning");
    return;
  }
  
  loading.value = true;
  try {
    if (doctorForm.isEdit) {
      // 检查原始数据是否完整
      if (!originalDoctor.department || !originalDoctor.doctor || !originalDoctor.day) {
        messagesRef.value.show("缺少原始医生信息，无法更新", "error");
        console.error("缺少原始医生信息:", originalDoctor);
        return;
      }
      
      // 更新前记录日志
      console.log("准备更新医生信息:", {
        原始数据: {
          科室: originalDoctor.department,
          医生: originalDoctor.doctor,
          日期: originalDoctor.day
        },
        新数据: {
          科室: doctorForm.department,
          医生: doctorForm.doctor,
          详情: doctorForm.detail,
          日期: doctorForm.day
        }
      });
      
      // SQL调试日志 - 显示预期的SQL查询条件
      // alert(`预期执行的SQL: UPDATE doctors SET department='${doctorForm.department}', doctor='${doctorForm.doctor}', detail='${doctorForm.detail}', work_date='${doctorForm.day}' WHERE department='${originalDoctor.department}' AND doctor='${originalDoctor.doctor}' AND work_date='${originalDoctor.day}'`);
      
      // 注意：参数顺序必须与后端API一致
      // 后端方法签名：updateDoctor(String department, String doctor, String day, String newDepartment, String newDoctor, String newDetail, String newDay)
      const response = await updateDoctorService(
        originalDoctor.department,  // 原科室 - 查询键
        originalDoctor.doctor,      // 原医生 - 查询键
        originalDoctor.day,         // 原日期 - 查询键
        doctorForm.department,      // 新科室 - 新值
        doctorForm.doctor,          // 新医生 - 新值
        doctorForm.detail,          // 新详情 - 新值
        doctorForm.day              // 新日期 - 新值
      );
      
      console.log("更新返回结果:", response);
      messagesRef.value.show("医生信息更新成功", "success");
    } else {
      // 添加新医生
      const response = await addDoctorService(
        doctorForm.department,
        doctorForm.doctor,
        doctorForm.detail,
        doctorForm.day
      );
      console.log("添加返回结果:", response);
      messagesRef.value.show("医生信息添加成功", "success");
    }
    
    // 先切换标签页，确保日期已设置正确
    switchTab('doctorList');
    
    // 由于后端数据库使用 department, doctor, work_date 作为联合主键
    // 更新完成后需要刷新当前日期下的排班数据
    await fetchDoctorSchedule();
    
    // 同时刷新全局医生列表
    await fetchAllDoctors();
  } catch (error) {
    console.error("提交医生信息出错:", error);
    messagesRef.value.show("操作失败，请重试", "error");
  } finally {
    loading.value = false;
  }
};

// 日期变更处理
const handleDateChange = () => {
  fetchDoctorSchedule();
};

// 窗口大小变化时重新调整图表大小
const handleResize = () => {
  // 如果有图表，可以在这里处理图表大小调整
};

// 组件挂载时获取数据
onMounted(async () => {
  // 获取用户信息
  loading.value = true;
  try {
    await fetchDoctorSchedule();
    // 预加载所有医生信息
    await fetchAllDoctors();
  } catch (error) {
    console.error("加载数据出错:", error);
  } finally {
    loading.value = false;
  }
  
  window.addEventListener('resize', handleResize);
});

// 组件卸载时移除事件监听
onUnmounted(() => {
  window.removeEventListener('resize', handleResize);
});

// 监听日期变化
watch(selectedDate, () => {
  fetchDoctorSchedule();
});

// 搜索处理函数
const handleSearch = () => {
  if (searchQuery.value.trim()) {
    // 当有搜索词时，启用全局搜索
    isGlobalSearch.value = true;
    
    // 如果还没有获取过所有医生数据，先获取
    if (allDoctorsList.value.length === 0) {
      fetchAllDoctors();
    }
  } else {
    // 当搜索词为空时，恢复普通模式
    isGlobalSearch.value = false;
  }
};
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
          <h1>医生管理系统</h1>
          
          <!-- 导航选项卡 -->
          <div class="tabs">
            <div 
              class="tab" 
              :class="{ active: activeTab === 'doctorList' }"
              @click="switchTab('doctorList')"
            >
              医生列表
            </div>
            <div 
              class="tab" 
              :class="{ active: activeTab === 'addDoctor' }"
              @click="switchTab('addDoctor')"
            >
              {{ doctorForm.isEdit ? '编辑医生' : '添加医生' }}
            </div>
            <div 
              class="tab" 
              :class="{ active: activeTab === 'schedule' }"
              @click="switchTab('schedule')"
            >
              排班管理
            </div>
          </div>
          
          <!-- 加载中提示 -->
          <div v-if="loading" class="loading-container">
            <CircleLoading />
            <span>加载中...</span>
          </div>
          
          <div v-else>
            <!-- 医生列表 -->
            <div v-if="activeTab === 'doctorList'" class="doctor-list-container">
              <!-- 筛选工具栏 -->
              <div class="filter-bar">
                <div class="search-box">
                  <input
                    type="text"
                    placeholder="搜索医生姓名或介绍..."
                    v-model="searchQuery"
                    @keyup.enter="handleSearch"
                  />
                  <button class="search-btn" @click="handleSearch">
                    <i class="ivu-icon ivu-icon-ios-search"></i>
                    搜索
                  </button>
                </div>
                <div class="department-filter">
                  <label>科室：</label>
                  <select v-model="selectedDepartment">
                    <option value="全部">全部科室</option>
                    <option v-for="dept in departments" :key="dept" :value="dept">{{ dept }}</option>
                  </select>
                </div>
              </div>
              
              <!-- 医生列表 -->
              <div class="doctors-grid">
                <div 
                  v-for="(doctor, index) in filteredDoctors" 
                  :key="index"
                  class="doctor-card"
                >
                  <div class="doctor-header">
                    <h3>{{ doctor.doctor }}</h3>
                    <span class="department-badge">{{ doctor.department }}</span>
                  </div>
                  <div class="doctor-detail">{{ doctor.detail }}</div>
                  <div class="status-bar">
                    <span class="status-badge" :class="{ 'status-busy': doctor.state > 0 }">
                      {{ doctor.state > 0 ? `已预约: ${doctor.state}` : '空闲' }}
                    </span>
                    <span class="work-date" v-if="doctor.work_date">{{ doctor.work_date }}</span>
                  </div>
                  <div class="doctor-actions">
                    <button class="view-btn" @click="viewDoctorDetail(doctor)">查看</button>
                    <button class="edit-btn" @click="editDoctor(doctor)">编辑</button>
                    <button class="delete-btn" @click="confirmDeleteDoctor(doctor.department, doctor.doctor, doctor.work_date || selectedDate)">删除</button>
                  </div>
                </div>
                <div v-if="filteredDoctors.length === 0" class="empty-data">
                  暂无医生数据
                </div>
              </div>
            </div>
            
            <!-- 添加/编辑医生表单 -->
            <div v-if="activeTab === 'addDoctor'" class="add-doctor-container">
              <div class="doctor-form">
                <div class="form-group">
                  <label>科室：</label>
                  <select v-model="doctorForm.department" required>
                    <option value="">请选择科室</option>
                    <option v-for="dept in departments" :key="dept" :value="dept">{{ dept }}</option>
                  </select>
                </div>
                
                <div class="form-group">
                  <label>医生姓名：</label>
                  <input type="text" v-model="doctorForm.doctor" placeholder="请输入医生姓名" required />
                </div>
                
                <div class="form-group">
                  <label>医生介绍：</label>
                  <textarea v-model="doctorForm.detail" placeholder="请输入医生详细介绍" rows="4" required></textarea>
                </div>
                
                <div class="form-group">
                  <label>排班日期：</label>
                  <input type="date" v-model="doctorForm.day" required />
                </div>
                
                <div class="form-actions">
                  <button class="submit-btn" @click="submitDoctorForm">{{ doctorForm.isEdit ? '更新' : '添加' }}</button>
                  <button class="cancel-btn" @click="switchTab('doctorList')">取消</button>
                </div>
              </div>
            </div>
            
            <!-- 排班管理 -->
            <div v-if="activeTab === 'schedule'" class="schedule-container">
              <div class="date-filter">
                <label>选择日期：</label>
                <input type="date" v-model="selectedDate" @change="handleDateChange" />
              </div>
              
              <div class="schedule-table">
                <table>
                  <thead>
                    <tr>
                      <th>科室</th>
                      <th>医生</th>
                      <th>介绍</th>
                      <th>预约状态</th>
                      <th>编辑</th>
                      <th>删除</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="(doctor, index) in scheduleList" :key="index">
                      <td>{{ doctor.department }}</td>
                      <td>{{ doctor.doctor }}</td>
                      <td class="detail-cell">{{ doctor.detail }}</td>
                      <td>
                        <span :class="doctor.state > 0 ? 'status-busy' : 'status-free'">
                          {{ doctor.state > 0 ? `已预约: ${doctor.state}` : '空闲' }}
                        </span>
                      </td>
                      <td>
                        <button class="edit-btn small" @click="editDoctor(doctor)">编辑</button>
                      </td>
                      <td>
                        <button class="delete-btn small" @click="confirmDeleteDoctor(doctor.department, doctor.doctor, doctor.work_date || selectedDate)">删除</button>
                      </td>
                    </tr>
                  </tbody>
                </table>
                <div v-if="scheduleList.length === 0" class="empty-data">
                  当前日期暂无排班数据
                </div>
              </div>
            </div>
          </div>
          
          <!-- 删除确认模态框 -->
          <div v-if="deleteModal.visible" class="modal">
            <div class="modal-content">
              <h2>确认删除</h2>
              <p>确定删除 {{ deleteModal.department }} 科室的 {{ deleteModal.doctor }} 医生吗？</p>
              <div class="modal-actions">
                <button class="confirm-btn" @click="deleteDoctor">确认</button>
                <button class="cancel-btn" @click="deleteModal.visible = false">取消</button>
              </div>
            </div>
          </div>
          
          <!-- 医生详情模态框 -->
          <div v-if="doctorDetailModal.visible" class="modal">
            <div class="modal-content doctor-detail-modal">
              <h2>医生详情</h2>
              <div class="detail-info">
                <div class="info-item">
                  <label>科室：</label>
                  <span>{{ doctorDetailModal.department }}</span>
                </div>
                <div class="info-item">
                  <label>姓名：</label>
                  <span>{{ doctorDetailModal.doctor }}</span>
                </div>
                <div class="info-item">
                  <label>状态：</label>
                  <span :class="doctorDetailModal.state > 0 ? 'status-busy' : 'status-free'">
                    {{ doctorDetailModal.state > 0 ? `已预约: ${doctorDetailModal.state}` : '空闲' }}
                  </span>
                </div>
                <div class="info-item">
                  <label>医生介绍：</label>
                  <p class="doctor-bio">{{ doctorDetailModal.detail }}</p>
                </div>
              </div>
              <div class="modal-actions">
                <button class="close-btn" @click="doctorDetailModal.visible = false">关闭</button>
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

.sidebar-shrink-button {
  position: absolute;
  right: -15px;
  top: 50%;
  transform: translateY(-50%);
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #dedbdb;
  border-radius: 50%;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  cursor: pointer;
  z-index: 1001;
  transition: all 0.3s ease;
  
  &:hover {
    transform: translateY(-50%) scale(1.1);
    box-shadow: 0 3px 10px rgba(0, 0, 0, 0.2);
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
}

.search-box {
  display: flex;
  align-items: center;
  gap: 10px;
}

.search-box input {
  padding: 10px 15px;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  width: 300px;
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
}

.search-btn:hover {
  background: #248f85;
}

.search-btn i {
  font-size: 16px;
}

.department-filter {
  display: flex;
  align-items: center;
  gap: 10px;
}

.department-filter select {
  padding: 10px;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  font-size: 14px;
  min-width: 150px;
}

/* 医生列表网格 */
.doctors-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
  margin-top: 20px;
}

.doctor-card {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  padding: 20px;
  display: flex;
  flex-direction: column;
  transition: transform 0.3s, box-shadow 0.3s;
}

.doctor-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.15);
}

.doctor-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.doctor-header h3 {
  margin: 0;
  font-size: 18px;
  color: #303133;
}

.department-badge {
  background: #f0f2f5;
  padding: 3px 8px;
  border-radius: 4px;
  font-size: 12px;
  color: #606266;
}

.doctor-detail {
  margin-bottom: 15px;
  color: #606266;
  font-size: 14px;
  flex-grow: 1;
  max-height: 80px;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
}

.status-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.status-badge {
  padding: 3px 8px;
  border-radius: 4px;
  font-size: 12px;
  color: #67c23a;
}

.status-busy {
  color: #e6a23c;
}

.status-free {
  color: #67c23a;
}

.work-date {
  font-size: 12px;
  color: #909399;
}

.doctor-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

.view-btn, .edit-btn, .delete-btn {
  padding: 5px 10px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 12px;
  color: white;
  transition: background-color 0.3s;
}

.view-btn {
  background: #409eff;
}

.view-btn:hover {
  background: #66b1ff;
}

.edit-btn {
  background: #67c23a;
}

.edit-btn:hover {
  background: #85ce61;
}

.delete-btn {
  background: #f56c6c;
}

.delete-btn:hover {
  background: #f78989;
}

.small {
  padding: 4px 8px;
  font-size: 12px;
}

.empty-data {
  text-align: center;
  padding: 30px;
  color: #909399;
  grid-column: 1 / -1;
  background: white;
  border-radius: 8px;
}

/* 添加医生表单 */
.add-doctor-container {
  max-width: 600px;
  margin: 0 auto;
}

.doctor-form {
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
.form-group select, 
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

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 15px;
  margin-top: 30px;
}

.submit-btn, .cancel-btn, .confirm-btn, .close-btn {
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

.confirm-btn {
  background: #f56c6c;
}

.confirm-btn:hover {
  background: #f78989;
}

.close-btn {
  background: #409eff;
}

.close-btn:hover {
  background: #66b1ff;
}

/* 排班管理 */
.schedule-container {
  background: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.date-filter {
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  gap: 15px;
}

.date-filter label {
  font-weight: bold;
  color: #606266;
}

.date-filter input {
  padding: 8px 12px;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  font-size: 14px;
}

.schedule-table {
  width: 100%;
  overflow-x: auto;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th {
  background: #f5f7fa;
  padding: 12px 15px;
  text-align: left;
  color: #606266;
  font-weight: bold;
  border-bottom: 1px solid #ebeef5;
}

td {
  padding: 12px 15px;
  border-bottom: 1px solid #ebeef5;
}

/* 操作按钮列的宽度控制 */
th:nth-last-child(-n+2), 
td:nth-last-child(-n+2) {
  width: 100px;
  text-align: center;
  padding: 8px;
}

.detail-cell {
  max-width: 300px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.small {
  padding: 4px 8px;
  font-size: 12px;
  min-width: 60px;
}

/* 模态框 */
.modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1002;
}

.modal-content {
  background: white;
  padding: 30px;
  border-radius: 8px;
  max-width: 450px;
  width: 90%;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.modal-content h2 {
  margin-top: 0;
  color: #303133;
}

.modal-content p {
  margin-bottom: 25px;
  color: #606266;
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 15px;
}

/* 医生详情模态框 */
.doctor-detail-modal {
  max-width: 600px;
}

.detail-info {
  margin: 20px 0;
}

.info-item {
  margin-bottom: 15px;
  display: flex;
  flex-direction: column;
}

.info-item label {
  font-weight: bold;
  color: #606266;
  margin-bottom: 5px;
}

.doctor-bio {
  margin-top: 5px;
  background: #f5f7fa;
  padding: 15px;
  border-radius: 4px;
  color: #606266;
  line-height: 1.6;
}

@media screen and (max-width: 768px) {
  .doctors-grid {
    grid-template-columns: 1fr;
  }
  
  .filter-bar {
    flex-direction: column;
    align-items: stretch;
  }
  
  .search-box input {
    width: 100%;
  }
  
  .form-actions {
    flex-direction: column;
  }
  
  .form-actions button {
    width: 100%;
  }
  
  .doctor-actions {
    flex-wrap: wrap;
  }
  
  .doctor-actions button {
    flex-grow: 1;
  }
}
</style>

