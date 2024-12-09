<template>
  <div class="template-manager">
    <el-card class="box-card">
      <!-- 图纸信息 -->
      <template #header>
        <div class="card-header">
          <span class="title">图纸信息</span>
        </div>
      </template>
      <el-form :model="drawingInfo" label-width="100px" class="drawing-info">
        <el-row :gutter="20">
          <el-col :span="8">
            <el-form-item label="图纸编号">
              <el-input v-model="drawingInfo.code" placeholder="请输入图纸编号"/>
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="图纸名称">
              <el-input v-model="drawingInfo.name" placeholder="请输入图纸名称"/>
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="图纸版本">
              <el-input v-model="drawingInfo.version" placeholder="请输入版本号"/>
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
    </el-card>

    <!-- 真值表设计 -->
    <el-card class="box-card mt-4">
      <template #header>
        <div class="card-header">
          <span class="title">真值表设计</span>
          <el-button type="primary" @click="addNewTestId">新增TestID</el-button>
        </div>
      </template>

      <el-collapse v-model="activeGroups">
        <el-collapse-item v-for="group in testGroups" :key="group.id" :name="group.id">
          <template #title>
            <span class="group-title">{{ group.name }}</span>
          </template>
          
          <div class="group-devices mb-2">
            <el-tag v-for="device in group.devices" :key="device" class="mr-2">
              {{ device }}
            </el-tag>
            <el-button type="primary" link @click="addDevice(group)">添加设备</el-button>
          </div>

          <el-table :data="group.steps" border style="width: 100%">
            <el-table-column prop="step" label="Step" width="80" />
            <el-table-column prop="testId" label="TestID" width="120" />
            <el-table-column prop="unit" label="Unit" width="120" />
            <el-table-column prop="operation" label="操作" width="120">
              <template #default="{ row }">
                <el-select v-model="row.operation" placeholder="选择操作">
                  <el-option label="read" value="read" />
                  <el-option label="write" value="write" />
                </el-select>
              </template>
            </el-table-column>
            <el-table-column prop="expectedValue" label="期望值" width="120">
              <template #default="{ row }">
                <el-input v-model="row.expectedValue" />
              </template>
            </el-table-column>
            <el-table-column prop="tolerance" label="误差范围" width="120">
              <template #default="{ row }">
                <el-input v-model="row.tolerance" placeholder="±2" />
              </template>
            </el-table-column>
            <el-table-column label="操作" width="150">
              <template #default="{ $index, row }">
                <el-button type="danger" link @click="deleteStep(group, $index)">
                  删除
                </el-button>
              </template>
            </el-table-column>
          </el-table>

          <div class="group-actions mt-2">
            <el-button type="primary" @click="addStep(group)">添加步骤</el-button>
            <el-button type="danger" @click="deleteGroup(group)">删除组</el-button>
          </div>
        </el-collapse-item>
      </el-collapse>
    </el-card>

    <!-- 操作按钮 -->
    <div class="actions mt-4">
      <el-button type="primary" @click="saveTemplate">保存模板</el-button>
      <el-button type="success" @click="exportTemplate">导出模板</el-button>
      <el-button @click="previewTemplate">预览</el-button>
    </div>

    <!-- 添加设备对话框 -->
    <el-dialog v-model="deviceDialog.visible" title="添加测试设备" width="30%">
      <el-form :model="deviceDialog.form">
        <el-form-item label="设备">
          <el-select v-model="deviceDialog.form.device" placeholder="请选择设备">
            <el-option label="EDB4-1" value="EDB4-1" />
            <el-option label="EDB4-2" value="EDB4-2" />
            <el-option label="EDB4-3" value="EDB4-3" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="deviceDialog.visible = false">取消</el-button>
          <el-button type="primary" @click="confirmAddDevice">确认</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script>
import { defineComponent, ref } from 'vue'

export default defineComponent({
  name: 'TemplateManager',
  setup() {
    // 图纸信息
    const drawingInfo = ref({
      code: '',
      name: '',
      version: ''
    })

    // 测试组管理
    const activeGroups = ref(['1'])
    const testGroups = ref([
      {
        id: '1',
        name: '组1：初始状态检查',
        devices: ['EDB4-1', 'EDB4-2'],
        steps: [
          {
            step: 1,
            testId: 'test_01',
            unit: 'AI1',
            operation: 'read',
            expectedValue: 0,
            tolerance: '±2'
          }
        ]
      }
    ])

    // 添加设备对话框
    const deviceDialog = ref({
      visible: false,
      currentGroup: null,
      form: {
        device: ''
      }
    })

    // 添加测试组
    const addTestGroup = () => {
      const newId = String(testGroups.value.length + 1)
      testGroups.value.push({
        id: newId,
        name: `组${newId}：新测试组`,
        devices: [],
        steps: []
      })
      activeGroups.value.push(newId)
    }

    // 删除测试组
    const deleteGroup = (group) => {
      const index = testGroups.value.findIndex(g => g.id === group.id)
      if (index > -1) {
        testGroups.value.splice(index, 1)
      }
    }

    // 添加测试步骤
    const addStep = (group) => {
      const newStep = {
        step: group.steps.length + 1,
        testId: `test_${group.id}_${group.steps.length + 1}`,
        unit: '',
        operation: 'read',
        expectedValue: '',
        tolerance: ''
      }
      group.steps.push(newStep)
    }

    // 删除测试步骤
    const deleteStep = (group, index) => {
      group.steps.splice(index, 1)
      // 重新编号
      group.steps.forEach((step, idx) => {
        step.step = idx + 1
      })
    }

    // 添加设备
    const addDevice = (group) => {
      deviceDialog.value.currentGroup = group
      deviceDialog.value.visible = true
    }

    // 确认添加设备
    const confirmAddDevice = () => {
      if (deviceDialog.value.currentGroup && deviceDialog.value.form.device) {
        deviceDialog.value.currentGroup.devices.push(deviceDialog.value.form.device)
        deviceDialog.value.visible = false
        deviceDialog.value.form.device = ''
      }
    }

    // 保存模板
    const saveTemplate = () => {
      console.log('保存模板', {
        drawingInfo: drawingInfo.value,
        groups: testGroups.value
      })
    }

    // 导出模板
    const exportTemplate = () => {
      console.log('导出模板')
    }

    // 预览模板
    const previewTemplate = () => {
      console.log('预览模板')
    }

    return {
      drawingInfo,
      activeGroups,
      testGroups,
      deviceDialog,
      addTestGroup,
      deleteGroup,
      addStep,
      deleteStep,
      addDevice,
      confirmAddDevice,
      saveTemplate,
      exportTemplate,
      previewTemplate
    }
  }
})
</script>

<style scoped>
.template-manager {
  padding: 20px;
}

.mt-4 {
  margin-top: 20px;
}

.mb-2 {
  margin-bottom: 10px;
}

.mr-2 {
  margin-right: 10px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.title {
  font-size: 16px;
  font-weight: bold;
}

.group-title {
  font-weight: bold;
}

.group-devices {
  display: flex;
  align-items: center;
  gap: 10px;
}

.group-actions {
  margin-top: 10px;
  display: flex;
  gap: 10px;
}

.actions {
  display: flex;
  gap: 10px;
  justify-content: center;
}
</style> 