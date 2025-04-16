<script setup>
import { ref } from 'vue';
import { registerGetMyService, deleteAppointmentService} from '@/api/register.js';
import Navbar from './Navbar.vue';

// 预约挂号信息
const registerlist = ref([]);

// 当前页码和每页显示的条数
const currentPage = ref(1);
const itemsPerPage = ref(8);  // 每页显示 8 条挂号信息
const totalPages = ref(Math.ceil(registerlist.value.length / itemsPerPage.value));  // 总页数
const username = sessionStorage.getItem("UserName");

// 获取我的挂号信息
const getMyRegister = async function () {
    try {
        // 调用后端服务
        let data = await registerGetMyService(username);

        // 将响应数据映射到只包含 `department` 和 `doctor` 的格式
        console.log("Fetched appointments:", data);
        registerlist.value = data.map(item => ({
            department: item.department,
            doctor: item.doctor,
            time: item.time,
            day: item.day
        }));

        // 更新分页信息
        totalPages.value = registerlist.value.length > 0
            ? Math.ceil(registerlist.value.length / itemsPerPage.value)
            : 1;

        updateDisplayedRecords(); // 更新当前显示记录
    } catch (error) {
        console.error("Failed to fetch data:", error);
    }
};


// 占位函数：挂号操作逻辑
const deleteAppointment = async (department, doctor, day) => {
    console.log(`Deleting appointment for ${department}, ${doctor}, user: ${username}`);
    // 实现挂号删除的逻辑
    try {
        // 调用后端服务
        const res = await deleteAppointmentService(department, doctor, username, day);
    } catch (error) {
        console.error("Fail to delete appointment: ", error);
    }
};

// 更新当前页显示的挂号记录
const updateDisplayedRecords = () => {
    const startIndex = (currentPage.value - 1) * itemsPerPage.value;
    const endIndex = startIndex + itemsPerPage.value;
    displayedRecords.value = registerlist.value.slice(startIndex, endIndex);
};

// 当前显示的挂号记录
const displayedRecords = ref([]);
getMyRegister();

// 切换到下一页
const nextPage = () => {
    if (currentPage.value < totalPages.value) {
        currentPage.value++;
        updateDisplayedRecords();
    }
};

// 切换到上一页
const prevPage = () => {
    if (currentPage.value > 1) {
        currentPage.value--;
        updateDisplayedRecords();
    }
};
</script>

<template>
    <div class="container">
        <h1>我的挂号信息</h1>
        <table class="register-table">
            <thead>
                <tr>
                    <th>序号</th>
                    <th>科室</th>
                    <th>医生</th>
                    <th>预约时间</th>
                    <th>前方队伍人数</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="(item, index) in displayedRecords" :key="item.doctor">
                    <td>{{ (currentPage - 1) * itemsPerPage + index + 1 }}</td> 
                    <td>{{ item.department }}</td>
                    <td>{{ item.doctor }}</td>
                    <td>{{ item.day }}</td>
                    <td>{{ item.time }}</td>
                    <td>
                        <button @click="() => { deleteAppointment(item.department, item.doctor, item.day); getMyRegister(); updateStateToFree(item.department, item.doctor); }" class="delete-button">取消挂号</button>
                    </td>
                </tr>
            </tbody>
        </table>

        <!-- 分页控制 -->
        <div class="pagination">
            <button @click="prevPage" :disabled="currentPage === 1">上一页</button>
            <span>第 {{ currentPage }} 页，共 {{ totalPages }} 页</span>
            <button @click="nextPage" :disabled="currentPage === totalPages">下一页</button>
        </div>
    </div>
</template>


<style scoped>
.container {
    background-color: #ffffff;
    padding: 60px;
    border-radius: 12px;
    box-shadow: 0 6px 20px rgba(0, 0, 0, 0.2);
    width: 90vw;
    max-width: 1200px;
    margin: 20px auto;
    height: auto;
}

h1 {
    margin-bottom: 40px;
    color: #343a40;
    font-size: 28px;
}

.register-table {
    width: 100%;
    border-collapse: collapse;
}

.register-table th, .register-table td {
    border: 1px solid #dee2e6;
    padding: 15px;
    text-align: left;
}

.register-table th {
    background-color: #f8f9fa;
    color: #495057;
}

.register-table tbody tr:nth-child(even) {
    background-color: #f2f2f2;
}

.pagination {
    display: flex;
    justify-content: center;
    margin-top: 20px;
}

.pagination button {
    padding: 10px 20px;
    background-color: #007bff;
    color: white;
    border: none;
    border-radius: 6px;
    cursor: pointer;
}

.pagination button:disabled {
    background-color: #cccccc;
    cursor: not-allowed;
}

.pagination span {
    font-size: 16px;
    margin: 0 10px;
}

.delete-button {
  padding: 8px 16px;
  background-color: #28a745;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  margin-left: 20px;
}

.delete-button:hover {
  background-color: #218838;
}
</style>
