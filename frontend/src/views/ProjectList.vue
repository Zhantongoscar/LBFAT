<template>
  <div class="project-list">
    <h1>项目管理</h1>
    
    <!-- 项目列表 -->
    <el-table :data="projects" style="width: 100%">
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="project_name" label="项目名称" />
      <el-table-column prop="is_subscribed" label="订阅状态" width="120">
        <template #default="scope">
          <el-switch
            v-model="scope.row.is_subscribed"
            active-text="已订阅"
            inactive-text="未订阅"
            :active-value="1"
            :inactive-value="0"
            @change="updateSubscription(scope.row)"
          />
        </template>
      </el-table-column>
      <el-table-column label="操作" width="120">
        <template #default="scope">
          <el-button
            type="primary"
            link
            @click="viewDevices(scope.row)"
          >
            查看设备
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 创建项目对话框 -->
    <el-dialog
      v-model="dialogVisible"
      title="创建新项目"
      width="30%"
      :close-on-click-modal="false"
    >
      <el-form :model="newProject" label-width="80px">
        <el-form-item label="项目名称">
          <el-input v-model="newProject.name" placeholder="请输入项目名称" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="submitProject">
            确认
          </el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 创建项目按钮 -->
    <div class="create-project">
      <el-button type="primary" @click="showCreateDialog">
        创建新项目
      </el-button>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import projectApi from '../api/project'

export default {
  name: 'ProjectList',
  setup() {
    const router = useRouter()
    const projects = ref([])
    const dialogVisible = ref(false)
    const newProject = ref({
      name: ''
    })

    // 加载项目列表
    const loadProjects = async () => {
      try {
        const response = await projectApi.getAllProjects()
        projects.value = response.data.data
      } catch (error) {
        ElMessage.error('加载项目列表失败')
      }
    }

    // 显示创建对话框
    const showCreateDialog = () => {
      newProject.value.name = ''
      dialogVisible.value = true
    }

    // 提交创建项目
    const submitProject = async () => {
      if (!newProject.value.name) {
        ElMessage.warning('请输入项目名称')
        return
      }

      try {
        await projectApi.createProject(newProject.value.name)
        ElMessage.success('创建项目成功')
        dialogVisible.value = false
        loadProjects()
      } catch (error) {
        ElMessage.error('创建项目失败')
      }
    }

    // 更新订阅状态
    const updateSubscription = async (project) => {
      try {
        await projectApi.updateSubscription(
          project.project_name,
          project.is_subscribed
        )
        ElMessage.success('更新订阅状态成功')
        loadProjects() // 重新加载列表以确保数据同步
      } catch (error) {
        project.is_subscribed = !project.is_subscribed // 恢复状态
        ElMessage.error('更新订阅状态失败')
      }
    }

    // 查看设备
    const viewDevices = (project) => {
      router.push({
        name: 'DeviceList',
        query: { project: project.project_name }
      })
    }

    onMounted(loadProjects)

    return {
      projects,
      dialogVisible,
      newProject,
      showCreateDialog,
      submitProject,
      updateSubscription,
      viewDevices
    }
  }
}
</script>

<style scoped>
.project-list {
  padding: 20px;
}

.create-project {
  margin: 20px 0;
  display: flex;
  justify-content: flex-end;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

:deep(.el-switch__label) {
  color: #606266;
}

:deep(.el-switch__label.is-active) {
  color: #409EFF;
}
</style> 