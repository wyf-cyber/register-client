<script setup>
import { ref, onMounted } from 'vue';
import { getAllCommentsService, getCommentsByDoctorService, addCommentService } from '@/views/comments/api';
import { ElMessage } from 'element-plus';

const comments = ref([]);
const newComment = ref({
    doctor: '',
    content: '',
    rating: 0
});
const selectedDoctor = ref('');
const getComments = async () => {
    try {
        const result = await getAllCommentsService();
        comments.value = result;
    } catch (error) {
        ElMessage.error('获取评论失败：' + error.message);
    }
};
const getCommentsByDoctor = async () => {
    try {
        const result = await getCommentsByDoctorService(selectedDoctor.value);
        comments.value = result;
    } catch (error) {
        ElMessage.error('获取该医生的评论失败：' + error.message);
    }
};
const addComment = async () => {
    if (!newComment.value.doctor || !newComment.value.content || newComment.value.rating === 0) {
        ElMessage.warning('请填写所有必填项');
        return;
    }
    try {
        const result = await addCommentService(newComment.value.doctor, newComment.value.content, newComment.value.rating);
        ElMessage.success('评论添加成功');
        getComments(); // 刷新评论列表
        newComment.value = {
            doctor: '',
            content: '',
            rating: 0
        };
    } catch (error) {
        ElMessage.error('评论添加失败：' + error.message);
    }
};
onMounted(() => {
    getComments();
});
</script>

<template>
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

        <h2>添加评论</h2>
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
</template>

<style scoped>
.comments-container {
    max-width: 1200px;
    border-radius: 8px;
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    padding: 20px;
}

.el-table {
    width: 100%;
    max-width: 800px;
}

.el-form {
    max-width: 600px;
    width: 100%;
}
</style>