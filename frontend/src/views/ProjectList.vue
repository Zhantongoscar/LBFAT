<template>
  <div class="project-list">
    <h1>项目管理</h1>
    
    <!-- 创建项目 -->
    <div class="create-project">
      <el-input
        v-model="newProjectName"
        placeholder="输入项目名称"
        class="input-with-select"
      >
        <template #append>
          <el-button type="primary" @click="createProject">
            创建项目
          </el-button>
        </template>
      </el-input>
    </div>

    <!-- 项目列表 -->
    <el-table :data="projects" style="width: 100%">
      <el-table-column prop="project_name" label="项目名称" />
      <el-table-column prop="is_subscribed" label="订阅状态">
        <template #default="scope">
          <el-switch
            v-model="scope.row.is_subscribed"
            @change="updateSubscription(scope.row)"
          />
        </template>
      </el-table-column>
      <el-table-column prop="created_at" label="创建时间">
        <template #default="scope">
          {{ formatDate(scope.row.created_at) }}
        </template>
      </el-table-column>
      <el-table-column prop="updated_at" label="更新时间">
        <template #default="scope">
          {{ formatDate(scope.row.updated_at) }}
        </template>
      </el-table-column>
      <el-table-column label="操作">
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
    const newProjectName = ref('')

    // 加载项目列表
    const loadProjects = async () => {
      try {
        const response = await projectApi.getAllProjects()
        projects.value = response.data.data
      } catch (error) {
        ElMessage.error('加载项目列表失败')
      }
    }

    // 创建项目
    const createProject = async () => {
      if (!newProjectName.value) {
        ElMessage.warning('请输入项目名称')
        return
      }

      try {
        await projectApi.createProject(newProjectName.value)
        ElMessage.success('创建项目成功')
        newProjectName.value = ''
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

    // 格式化日期
    const formatDate = (date) => {
      return new Date(date).toLocaleString()
    }

    onMounted(loadProjects)

    return {
      projects,
      newProjectName,
      createProject,
      updateSubscription,
      viewDevices,
      formatDate
    }
  }
}
</script>

<style scoped>
.project-list {
  padding: 20px;
}

.create-project {
  margin-bottom: 20px;
  max-width: 500px;
}
</style> 