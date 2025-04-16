<script setup>
import { ref, onMounted, computed, reactive, watch, onUnmounted } from "vue";
import { useRouter } from "vue-router";
import PageHeader from "@/views/components/header.vue";
import CircleLoading from "@/views/components/circle_loading.vue";
import ShrinkableMenu from "@/views/navbar/menu.vue";
import Messages from "@/views/components/messages.vue";
import {
  getAllDoctorService,
  registerSearchService,
  addAppointmentService,
  deleteAppointmentService, // <-- Added for cancellation
  payQRCodeService
} from "@/views/register/api"; // Adjust path if needed

// 格式化日期 (YYYY-MM-DD) - Handles Timezone
const formatDate = (dateObj) => {
  if (!dateObj) return '';
  const date = new Date(dateObj);
  const offset = date.getTimezoneOffset();
  const adjustedDate = new Date(date.getTime() - (offset * 60 * 1000));
  return adjustedDate.toISOString().split('T')[0];
};

// ------------- State Variables -------------
const router = useRouter();
const username = ref(sessionStorage.getItem("UserName") || "未登录");
const userRole = ref(sessionStorage.getItem("UserRole") === "admin" ? "管理员" : "普通用户");
const isAdmin = ref(sessionStorage.getItem("UserRole") === "admin");
const isCollapsed = ref(sessionStorage.getItem("sidebarCollapsed") === "true" ? true : false);
const loading = ref(true); // Global loading for list fetching
const actionLoading = ref(false); // Loading for booking/cancelling actions
const showMobileMenu = ref(false);
const singleOpenName = ref(["register"]);
const menuTheme = ref("dark");

// Appointment Data
const availableDoctors = ref([]);
const departments = ref(['内科', '外科', '儿科', '眼科', '皮肤科', '妇科', '骨科', '神经科', '精神科', '口腔科']);

// Search Filters
const searchFilters = reactive({
  department: '全部',
  date: formatDate(new Date()),
  state: '全部' // '全部', '空闲'
});

// Modals State
const confirmModal = reactive({ // Booking confirmation
  visible: false,
  department: '',
  doctor: '',
  day: ''
});

const cancelConfirmModal = reactive({ // Cancellation confirmation
  visible: false,
  department: '',
  doctor: '',
  day: ''
});

const paymentModal = reactive({ // Payment QR Code
  visible: false,
  qrCodeUrl: '',
  isLoading: false,
  error: null
});

// Message Component Ref
const messagesRef = ref(null);

// ------------- Layout and Menu Handlers (Consistent) -------------
const handleMenuChange = (name) => {
  router.push({ name });
};
const changeMenu = (name) => { handleMenuChange(name); };
const toggleCollapse = () => {
  isCollapsed.value = !isCollapsed.value;
  sessionStorage.setItem("sidebarCollapsed", isCollapsed.value);
};
const mainContentStyle = computed(() => {
  const sidebarWidth = isCollapsed.value ? 80 : 200;
  return { marginLeft: `${sidebarWidth}px`, width: `calc(100% - ${sidebarWidth}px)` };
});
const handleMobileToggle = () => { showMobileMenu.value = !showMobileMenu.value; }; // Added for consistency

// ------------- Core Logic -------------

// Fetch Doctor List
const fetchDoctors = async () => {
  if (!username.value || username.value === '未登录') {
    messagesRef.value?.show("请先登录", "warning");
    loading.value = false;
    availableDoctors.value = [];
    return;
  }
  loading.value = true;
  availableDoctors.value = [];
  try {
    let response;
    const searchDay = searchFilters.date || formatDate(new Date());
    const stateParam = searchFilters.state === '空闲' ? '0' : '';
    const departmentParam = searchFilters.department === '全部' ? '' : searchFilters.department;

    if (!departmentParam && !stateParam) { // Use getAll if no specific filters other than date
       response = await getAllDoctorService(username.value, searchDay);
    } else {
       response = await registerSearchService(departmentParam, stateParam, username.value, searchDay);
    }

    // **ASSUMPTION:** Backend response includes `isBookedByCurrentUser: boolean` field for each doctor slot
    availableDoctors.value = (response || []).map(doc => ({
        ...doc,
        work_date: doc.work_date || searchDay,
        isBookedByCurrentUser: doc.isBookedByCurrentUser || false // Default to false if backend doesn't provide it
    }));

  } catch (error) {
    console.error("获取医生列表出错:", error);
    messagesRef.value?.show("获取医生列表失败，请稍后重试", "error");
    availableDoctors.value = [];
  } finally {
    loading.value = false;
  }
};

// Search Handler
const handleSearch = () => {
  fetchDoctors();
};

// Date Change Handler
const handleDateChange = () => {
  // Debounce or directly fetch
  fetchDoctors();
};

// Show Booking Confirmation
const confirmAppointment = (doctor) => {
   if (!username.value || username.value === '未登录') {
      messagesRef.value?.show("请先登录再进行预约", "warning");
      return;
   }
   if (doctor.state > 0 && !doctor.isBookedByCurrentUser) { // Check state only if not already booked by user
       messagesRef.value?.show("该医生当前时段可能已被他人预约", "warning");
       // Allow confirmation still, backend will handle final check
   }
  Object.assign(confirmModal, {
    visible: true,
    department: doctor.department,
    doctor: doctor.doctor,
    day: doctor.work_date || searchFilters.date
  });
};

// Process Booking & Payment
const bookAppointment = async () => {
  confirmModal.visible = false;
  paymentModal.isLoading = true;
  paymentModal.error = null;
  paymentModal.qrCodeUrl = '';
  paymentModal.visible = true;
  actionLoading.value = true; // Indicate general action in progress

  try {
    const addResponse = await addAppointmentService(
      confirmModal.department,
      confirmModal.doctor,
      username.value,
      confirmModal.day
    );

    // **ADJUST based on actual backend success response:**
    if (addResponse && (typeof addResponse === 'string' && addResponse.includes('成功'))) {
        messagesRef.value?.show("预约请求成功，请支付", "success");

        // Refresh list immediately to reflect potential state change
        await fetchDoctors(); // Refresh in background while getting QR

        // Fetch QR Code
        try {
            const qrCodeResponse = await payQRCodeService(username.value);
            if (qrCodeResponse) {
                paymentModal.qrCodeUrl = qrCodeResponse;
            } else {
                 throw new Error("未能获取支付二维码");
            }
        } catch(qrError) {
            console.error("获取支付二维码出错:", qrError);
            paymentModal.error = "获取支付二维码失败，请稍后重试或联系客服。";
            // Keep modal open to show error
        } finally {
           paymentModal.isLoading = false;
        }
    } else {
       throw new Error(addResponse || "预约失败，该时段可能已被预约或发生错误");
    }

  } catch (error) {
    console.error("预约过程中出错:", error);
    messagesRef.value?.show(`${error.message || '预约失败，请重试'}`, "error");
    paymentModal.error = `预约失败: ${error.message || '请重试'}`;
    paymentModal.isLoading = false;
    // Optionally close payment modal on booking failure before QR:
    // paymentModal.visible = false;
  } finally {
       actionLoading.value = false; // Action finished
       // Refresh list again in case booking failed but state might need update
       if (paymentModal.error) await fetchDoctors();
  }
};

// Show Cancellation Confirmation
const confirmCancelAppointment = (doctor) => {
  Object.assign(cancelConfirmModal, {
    visible: true,
    department: doctor.department,
    doctor: doctor.doctor,
    day: doctor.work_date || searchFilters.date
  });
};

// Process Cancellation
const cancelAppointment = async () => {
  cancelConfirmModal.visible = false;
  actionLoading.value = true; // Indicate general action in progress
  try {
    const response = await deleteAppointmentService(
      cancelConfirmModal.department,
      cancelConfirmModal.doctor,
      username.value,
      cancelConfirmModal.day
    );

    // **ADJUST based on actual backend success response:**
    if (response && (typeof response === 'string' && response.includes('成功'))) {
      messagesRef.value?.show("预约取消成功", "success");
      await fetchDoctors(); // Refresh the list to update UI
    } else {
      throw new Error(response || "取消失败，请重试");
    }
  } catch (error) {
    console.error("取消预约出错:", error);
    messagesRef.value?.show(`取消预约失败: ${error.message || '请重试'}`, "error");
  } finally {
     actionLoading.value = false; // Action finished
  }
};

// Close Payment Modal
const closePaymentModal = () => {
    paymentModal.visible = false;
    // Consider if list needs refreshing after closing modal (e.g., if payment timed out)
    // fetchDoctors();
}

// ------------- Lifecycle Hooks -------------
onMounted(async () => {
  loading.value = true;
  if(username.value && username.value !== '未登录') {
      await fetchDoctors();
  } else {
      messagesRef.value?.show("请先登录以查看和管理预约", "info");
      loading.value = false;
  }
  window.addEventListener('resize', () => {/* Placeholder for potential future use */});
});

onUnmounted(() => {
  window.removeEventListener('resize', () => {});
});

// Watch for date changes
watch(() => searchFilters.date, (newDate) => {
  if (newDate) {
    fetchDoctors(); // Refetch when date changes
  }
});

</script>

<template>
  <div class="layout">
    <PageHeader class="layout-header" />
    <Messages ref="messagesRef" />

    <div class="layout-container">
      <!-- Sidebar -->
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

      <!-- Main Content -->
      <div class="layout-main" :style="mainContentStyle">
        <div class="content-wrapper">
          <h1>在线预约</h1>

          <!-- Filter Bar -->
          <div class="filter-bar appointment-filters">
             <div class="filter-item">
                <label>科室：</label>
                <select v-model="searchFilters.department" :disabled="loading || actionLoading">
                    <option value="全部">全部科室</option>
                    <option v-for="dept in departments" :key="dept" :value="dept">{{ dept }}</option>
                </select>
             </div>
             <div class="filter-item">
                <label>日期：</label>
                <input type="date" v-model="searchFilters.date" :disabled="loading || actionLoading" />
             </div>
             <div class="filter-item">
                <label>状态：</label>
                <select v-model="searchFilters.state" :disabled="loading || actionLoading">
                    <option value="全部">全部状态</option>
                    <option value="空闲">仅看空闲</option>
                </select>
             </div>
             <div class="filter-item">
                <button class="search-btn" @click="handleSearch" :disabled="loading || actionLoading">
                    <i class="ivu-icon ivu-icon-ios-search"></i>
                    <span v-if="!loading">搜索医生</span>
                    <span v-else>搜索中...</span>
                </button>
             </div>
          </div>

          <!-- Loading Indicator -->
          <div v-if="loading" class="loading-container">
            <CircleLoading />
            <span>正在加载医生信息...</span>
          </div>

          <!-- Doctors Grid -->
          <div v-else>
            <div class="doctors-grid">
              <div
                v-for="(doctor) in availableDoctors"
                :key="`${doctor.department}-${doctor.doctor}-${doctor.work_date}`"
                class="doctor-card"
                :class="{ 'action-in-progress': actionLoading }"
              >
                <div class="doctor-header">
                  <h3>{{ doctor.doctor }}</h3>
                  <span class="department-badge">{{ doctor.department }}</span>
                </div>
                <div class="doctor-detail">{{ doctor.detail }}</div>
                <div class="status-bar">
                  <span class="status-badge" :class="{ 'status-booked-other': doctor.state > 0 && !doctor.isBookedByCurrentUser, 'status-booked-user': doctor.isBookedByCurrentUser, 'status-free': doctor.state === 0 && !doctor.isBookedByCurrentUser }">
                     {{ doctor.isBookedByCurrentUser ? '您已预约' : (doctor.state > 0 ? '已预约' : '可预约') }}
                  </span>
                   <span class="work-date">{{ doctor.work_date }}</span>
                </div>
                <div class="doctor-actions">
                   <!-- Show Book Button if NOT booked by current user -->
                  <button
                    v-if="!doctor.isBookedByCurrentUser"
                    class="book-btn"
                    @click="confirmAppointment(doctor)"
                    :disabled="doctor.state > 0 || actionLoading || !username || username === '未登录'"
                    :title="doctor.state > 0 ? '当前时段不可预约' : (!username || username === '未登录' ? '请先登录' : '预约此医生')"
                   >
                    预约
                  </button>
                  <!-- Show Cancel Button if booked by current user -->
                   <button
                    v-if="doctor.isBookedByCurrentUser"
                    class="cancel-app-btn"
                    @click="confirmCancelAppointment(doctor)"
                    :disabled="actionLoading || !username || username === '未登录'"
                    title="取消您的预约"
                   >
                    取消预约
                  </button>
                </div>
              </div>
              <div v-if="availableDoctors.length === 0 && !loading" class="empty-data">
                根据当前条件，暂无可预约的医生
              </div>
            </div>
          </div>

          <!-- Appointment Confirmation Modal -->
          <div v-if="confirmModal.visible" class="modal">
            <div class="modal-content">
              <h2>确认预约</h2>
              <p>
                您确定要预约
                <strong>{{ confirmModal.day }}</strong> 的
                <strong>{{ confirmModal.department }}</strong> 科室
                <strong>{{ confirmModal.doctor }}</strong> 医生吗？
              </p>
              <div class="modal-actions">
                <button class="confirm-btn book-btn" @click="bookAppointment" :disabled="actionLoading">
                    <span v-if="!actionLoading">确认预约并支付</span>
                    <span v-else>处理中...</span>
                </button>
                <button class="cancel-btn" @click="confirmModal.visible = false" :disabled="actionLoading">取消</button>
              </div>
            </div>
          </div>

          <!-- Cancellation Confirmation Modal -->
          <div v-if="cancelConfirmModal.visible" class="modal">
            <div class="modal-content">
              <h2>确认取消预约</h2>
              <p>
                您确定要取消
                <strong>{{ cancelConfirmModal.day }}</strong> 的
                <strong>{{ cancelConfirmModal.department }}</strong> 科室
                <strong>{{ cancelConfirmModal.doctor }}</strong> 医生的预约吗？
              </p>
              <div class="modal-actions">
                <button class="confirm-btn cancel-app-btn" @click="cancelAppointment" :disabled="actionLoading">
                   <span v-if="!actionLoading">确认取消</span>
                   <span v-else>处理中...</span>
                </button>
                <button class="cancel-btn" @click="cancelConfirmModal.visible = false" :disabled="actionLoading">返回</button>
              </div>
            </div>
          </div>

           <!-- Payment Modal -->
          <div v-if="paymentModal.visible" class="modal payment-modal">
            <div class="modal-content">
              <h2>扫码支付</h2>
              <div v-if="paymentModal.isLoading" class="payment-loading">
                <CircleLoading />
                <span>正在生成支付信息...</span>
              </div>
              <div v-else-if="paymentModal.error" class="payment-error">
                 <p>抱歉，处理过程中出现问题：</p>
                 <p><strong>{{ paymentModal.error }}</strong></p>
                 <p>您可以关闭此窗口稍后重试，或联系客服。</p>
              </div>
              <div v-else-if="paymentModal.qrCodeUrl" class="payment-qr">
                 <p>请使用微信或支付宝扫描下方二维码完成支付。</p>
                 <!-- Assuming qrCodeUrl is the direct image data URL or a reachable URL -->
                 <img :src="paymentModal.qrCodeUrl" alt="支付二维码" class="qr-code-image" />
                 <p class="payment-note">支付完成后，您的预约将正式生效。</p>
              </div>
               <div v-else class="payment-error">
                 <p>未能加载支付信息，请关闭重试。</p>
              </div>
              <div class="modal-actions">
                <button class="close-btn" @click="closePaymentModal">关闭</button>
              </div>
            </div>
          </div>

        </div> <!-- /.content-wrapper -->
      </div> <!-- /.layout-main -->
    </div> <!-- /.layout-container -->
  </div> <!-- /.layout -->
</template>

<style lang="less" scoped>
/* Reuse styles from previous example, add/modify specific styles */

/* --- Base Layout, Header, Sider, Main (Assume identical to previous) --- */
.layout { min-height: 100vh; display: flex; flex-direction: column; width: 100%; overflow-x: hidden; background-color: #f5f7fa; }
.layout-header { height: 60px; width: 100%; position: fixed; top: 0; left: 0; right: 0; z-index: 1000; }
.layout-container { display: flex; position: fixed; left: 0; right: 0; bottom: 0; flex-direction: row; margin-top: 60px; height: calc(100vh - 60px); width: 100%; background-color: #f5f7fa; }
.layout-sider { width: 200px; height: 100%; flex-shrink: 0; background: #2daa9e; transition: width 0.3s ease; box-shadow: 2px 0 6px rgba(0,0,0,0.1); position: relative; &.collapsed { width: 80px; } }
.layout-main { flex: 1; padding: 20px; box-sizing: border-box; height: 100%; overflow-y: auto; background: #f5f7fa; transition: margin-left 0.3s ease; }

h1 { margin-bottom: 30px; color: #343a40; text-align: center; font-size: 28px; font-weight: bold; }
.content-wrapper { max-width: 1200px; margin: 0 auto; padding: 20px; }

/* Loading */
.loading-container { display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 50px; color: #606266; span { margin-top: 10px; } }

/* Filter Bar */
.filter-bar { display: flex; flex-wrap: wrap; gap: 15px; align-items: center; padding: 15px; background-color: #ffffff; border-radius: 8px; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05); margin-bottom: 25px; }
.filter-item { display: flex; align-items: center; gap: 8px; label { font-weight: 500; color: #606266; white-space: nowrap; } input[type="date"], select { padding: 8px 12px; border: 1px solid #dcdfe6; border-radius: 4px; font-size: 14px; min-width: 150px; &:disabled { background-color: #f5f7fa; cursor: not-allowed; } } }
.search-btn { display: flex; align-items: center; gap: 5px; padding: 9px 15px; background: #2daa9e; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 14px; transition: background-color 0.3s, opacity 0.3s; &:hover:not(:disabled) { background: #248f85; } i { font-size: 16px; } &:disabled { opacity: 0.6; cursor: not-allowed; } }

/* Doctors Grid & Cards */
.doctors-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; margin-top: 20px; }
.doctor-card { background: white; border-radius: 8px; box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1); padding: 20px; display: flex; flex-direction: column; transition: transform 0.3s, box-shadow 0.3s, opacity 0.3s; &:hover { transform: translateY(-5px); box-shadow: 0 5px 15px rgba(0, 0, 0, 0.15); } &.action-in-progress { opacity: 0.7; pointer-events: none; } } /* Disable interaction during action */
.doctor-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; h3 { margin: 0; font-size: 18px; color: #303133; } }
.department-badge { background: #eef8f7; color: #2daa9e; padding: 3px 8px; border-radius: 4px; font-size: 12px; font-weight: 500; border: 1px solid #b8e7e1; }
.doctor-detail { margin-bottom: 15px; color: #606266; font-size: 14px; flex-grow: 1; max-height: 80px; overflow: hidden; text-overflow: ellipsis; display: -webkit-box; -webkit-line-clamp: 3; line-clamp: 3; -webkit-box-orient: vertical; }
.status-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; margin-top: 10px; }
.status-badge { padding: 4px 10px; border-radius: 12px; font-size: 12px; font-weight: 500; border: 1px solid transparent; }
.status-booked-other { color: #f56c6c; background-color: #fef0f0; border-color: #fbc4c4; } /* Red for booked by others */
.status-booked-user { color: #409eff; background-color: #ecf5ff; border-color: #b3d8ff; } /* Blue for booked by user */
.status-free { color: #67c23a; background-color: #f0f9eb; border-color: #c2e7b0; } /* Green for free */
.work-date { font-size: 12px; color: #909399; }
.doctor-actions { display: flex; justify-content: flex-end; margin-top: auto; padding-top: 15px; border-top: 1px solid #f0f2f5; }

/* Action Buttons */
.book-btn, .cancel-app-btn { padding: 8px 18px; border: none; border-radius: 4px; cursor: pointer; font-size: 14px; color: white; transition: background-color 0.3s, opacity 0.3s; &:disabled { cursor: not-allowed; opacity: 0.6; } }
.book-btn { background: #2daa9e; &:hover:not(:disabled) { background: #248f85; } }
.cancel-app-btn { background: #f56c6c; /* Red for cancel */ &:hover:not(:disabled) { background: #f78989; } }

.empty-data { text-align: center; padding: 40px 20px; color: #909399; grid-column: 1 / -1; background: white; border-radius: 8px; margin-top: 20px; }

/* Modals */
.modal { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.6); display: flex; justify-content: center; align-items: center; z-index: 1002; padding: 15px; }
.modal-content { background: white; padding: 30px 35px; border-radius: 8px; max-width: 480px; width: 100%; box-shadow: 0 5px 20px rgba(0, 0, 0, 0.15); box-sizing: border-box; h2 { margin-top: 0; margin-bottom: 20px; color: #303133; text-align: center; font-size: 22px; } p { margin-bottom: 25px; color: #606266; line-height: 1.6; text-align: center; strong { color: #2daa9e; } } }
.modal-actions { display: flex; justify-content: center; gap: 15px; margin-top: 20px; button:disabled { opacity: 0.6; cursor: not-allowed; } }

/* Standard Modal Buttons */
.confirm-btn, .cancel-btn, .close-btn { padding: 10px 25px; border: none; border-radius: 4px; cursor: pointer; font-size: 14px; color: white; transition: background-color 0.3s; font-weight: 500; }
.confirm-btn.book-btn { background: #2daa9e; &:hover:not(:disabled) { background: #248f85; } } /* Confirm Book */
.confirm-btn.cancel-app-btn { background: #f56c6c; &:hover:not(:disabled) { background: #f78989; } } /* Confirm Cancel */
.cancel-btn { background: #909399; &:hover:not(:disabled) { background: #a6a9ad; } }
.close-btn { background: #409eff; &:hover:not(:disabled) { background: #66b1ff; } }

/* Payment Modal Specifics */
.payment-modal .modal-content { max-width: 400px; }
.payment-loading, .payment-error, .payment-qr { text-align: center; padding: 20px 0; }
.payment-loading span { margin-top: 15px; display: block; color: #606266; }
.payment-error p { color: #f56c6c; margin-bottom: 10px; }
.qr-code-image { display: block; margin: 15px auto; max-width: 200px; height: auto; border: 1px solid #eee; }
.payment-note { font-size: 13px; color: #909399; margin-top: 15px; }


/* Responsive */
@media screen and (max-width: 768px) {
  .layout-main { margin-left: 0 !important; width: 100% !important; }
  .filter-bar { flex-direction: column; align-items: stretch; }
  .filter-item { width: 100%; justify-content: space-between; select, input { flex-grow: 1; min-width: 0; } button.search-btn { width: 100%; justify-content: center; } }
  .doctors-grid { grid-template-columns: 1fr; }
  .modal-content { padding: 20px; h2 { font-size: 20px; } }
  .modal-actions { flex-direction: column; gap: 10px; button { width: 100%; } }
}

</style>