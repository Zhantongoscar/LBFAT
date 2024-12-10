<template>
  <div class="test-report">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>测试报告查询</span>
        </div>
      </template>

      <!-- 查询条件 -->
      <el-form :inline="true" class="search-form">
        <el-form-item label="产品序列号">
          <el-input v-model="searchForm.serialNumber" />
        </el-form-item>
        <el-form-item label="图纸编号">
          <el-input v-model="searchForm.drawingCode" />
        </el-form-item>
        <el-form-item label="开始时间">
          <el-date-picker
            v-model="searchForm.startTime"
            type="datetime"
            format="YYYY-MM-DD HH:mm:ss"
            placeholder="选择开始时间"
          />
        </el-form-item>
        <el-form-item label="结束时间">
          <el-date-picker
            v-model="searchForm.endTime"
            type="datetime"
            format="YYYY-MM-DD HH:mm:ss"
            placeholder="选择结束时间"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="searchRecords">查询</el-button>
        </el-form-item>
      </el-form>

      <!-- 测试记录列表 -->
      <el-table :data="testRecords" style="width: 100%">
        <el-table-column prop="serialNumber" label="产品序列号" />
        <el-table-column prop="drawingCode" label="图纸编号" />
        <el-table-column prop="testTime" label="测试时间" />
        <el-table-column prop="status" label="状态">
          <template #default="{ row }">
            <el-tag :type="row.status === '完成' ? 'success' : 'info'">
              {{ row.status }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="result" label="结果">
          <template #default="{ row }">
            <el-tag :type="row.result === '通过' ? 'success' : 'danger'">
              {{ row.result }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="100">
          <template #default="{ row }">
            <el-button type="primary" link @click="showDetail(row)">
              详情
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 测试详情抽屉 -->
    <el-drawer
      v-model="detailDrawer.visible"
      title="测试详情"
      size="800px"
      direction="rtl"
    >
      <template v-if="detailDrawer.record">
        <div class="detail-header">
          <div class="detail-item">
            <span class="label">产品序列号:</span>
            <span class="value">{{ detailDrawer.record.serialNumber }}</span>
          </div>
          <div class="detail-item">
            <span class="label">图纸编号:</span>
            <span class="value">{{ detailDrawer.record.drawingCode }}</span>
          </div>
          <div class="detail-item">
            <span class="label">测试时间:</span>
            <span class="value">{{ detailDrawer.record.testTime }}</span>
          </div>
        </div>

        <!-- 详情内容 -->
        <div class="detail-content">
          <!-- 这里添加详细的测试结果内容 -->
        </div>
      </template>

      <template #footer>
        <div class="drawer-footer">
          <el-button @click="detailDrawer.visible = false">关闭</el-button>
          <el-button type="primary" @click="exportReport">导出报告</el-button>
        </div>
      </template>
    </el-drawer>
  </div>
</template>

<script lang="ts">
import { defineComponent, ref } from 'vue'

export default defineComponent({
  name: 'TestReport',
  setup() {
    const searchForm = ref({
      serialNumber: '',
      drawingCode: '',
      startTime: null,
      endTime: null
    })

    const recordColumns = [
      { title: '测试ID', dataIndex: 'testId', key: 'testId' },
      { title: '产品序列号', dataIndex: 'serialNumber', key: 'serialNumber' },
      { title: '图纸编号', dataIndex: 'drawingCode', key: 'drawingCode' },
      { title: '测试时间', dataIndex: 'testTime', key: 'testTime' },
      { title: '使用设备', dataIndex: 'devices', key: 'devices' },
      { 
        title: '状态', 
        dataIndex: 'status', 
        key: 'status',
        slots: { customRender: 'status' }
      },
      { 
        title: '结果', 
        dataIndex: 'result', 
        key: 'result',
        slots: { customRender: 'result' }
      },
      {
        title: '操作',
        key: 'action',
        slots: { customRender: 'action' }
      }
    ]

    const testRecords = ref([
      {
        testId: '#001',
        serialNumber: 'P2024001',
        drawingCode: 'DRW-001',
        testTime: '2024-01-20 12:00:00',
        devices: 'EDB4-1,2',
        status: '完成',
        result: '通过'
      },
      {
        testId: '#002',
        serialNumber: 'P2024002',
        drawingCode: 'DRW-001',
        testTime: '2024-01-20 12:10:00',
        devices: 'EDB4-1,3',
        status: '完成',
        result: '失败'
      }
    ])

    const stepColumns = [
      { title: 'Step', dataIndex: 'step', key: 'step' },
      { title: '设备', dataIndex: 'device', key: 'device' },
      { title: 'Unit', dataIndex: 'unit', key: 'unit' },
      { title: '操作', dataIndex: 'operation', key: 'operation' },
      { title: '实际值', dataIndex: 'actualValue', key: 'actualValue' },
      { 
        title: '结果', 
        dataIndex: 'result', 
        key: 'result',
        slots: { customRender: 'result' }
      }
    ]

    const detailDrawer = ref({
      visible: false,
      record: null
    })

    const activeGroups = ref(['1'])

    const testGroups = ref([
      {
        id: '1',
        name: '测试组1：初始状态检查',
        testId: 'test_01',
        steps: [
          {
            step: 1,
            device: 'EDB4-1',
            unit: 'AI1',
            operation: 'read',
            actualValue: 0.5,
            result: { success: true }
          },
          {
            step: 1,
            device: 'EDB4-2',
            unit: 'AI1',
            operation: 'read',
            actualValue: 1.5,
            result: { success: true }
          }
        ]
      }
    ])

    const searchRecords = () => {
      // TODO: 实现查询记录逻辑
    }

    const showDetail = (record: any) => {
      detailDrawer.value.record = record
      detailDrawer.value.visible = true
    }

    const exportPDF = () => {
      // TODO: 实现导出PDF逻辑
    }

    const exportExcel = () => {
      // TODO: 实现导出Excel逻辑
    }

    return {
      searchForm,
      recordColumns,
      testRecords,
      stepColumns,
      detailDrawer,
      activeGroups,
      testGroups,
      searchRecords,
      showDetail,
      exportPDF,
      exportExcel
    }
  }
})
</script>

<style scoped>
.test-report {
  padding: 20px;
}

.box-card {
  margin-bottom: 20px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.search-form {
  margin-bottom: 20px;
}

.detail-header {
  background-color: #f5f7fa;
  padding: 20px;
  border-radius: 4px;
  margin-bottom: 20px;
}

.detail-item {
  margin-bottom: 10px;
  display: flex;
  align-items: center;
}

.detail-item .label {
  font-weight: bold;
  margin-right: 10px;
  color: #606266;
  width: 100px;
}

.detail-item .value {
  color: #303133;
}

.drawer-footer {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 20px;
  background: #fff;
  border-top: 1px solid #e4e7ed;
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

.detail-content {
  padding: 0 20px;
  margin-bottom: 60px;
}
</style> 