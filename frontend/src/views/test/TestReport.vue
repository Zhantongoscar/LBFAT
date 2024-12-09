<template>
  <div class="test-report">
    <a-card title="测试报告查询" :bordered="false">
      <!-- 查询条件 -->
      <a-form layout="inline" class="search-form">
        <a-form-item label="产品序列号">
          <a-input v-model:value="searchForm.serialNumber" />
        </a-form-item>
        <a-form-item label="图纸编号">
          <a-input v-model:value="searchForm.drawingCode" />
        </a-form-item>
        <a-form-item label="开始时间">
          <a-date-picker
            v-model:value="searchForm.startTime"
            show-time
            format="YYYY-MM-DD HH:mm:ss"
          />
        </a-form-item>
        <a-form-item label="结束时间">
          <a-date-picker
            v-model:value="searchForm.endTime"
            show-time
            format="YYYY-MM-DD HH:mm:ss"
          />
        </a-form-item>
        <a-form-item>
          <a-button type="primary" @click="searchRecords">查询</a-button>
        </a-form-item>
      </a-form>

      <!-- 测试记录列表 -->
      <a-table
        :columns="recordColumns"
        :data-source="testRecords"
        :pagination="{ total: 100 }"
        class="mt-4"
      >
        <template #status="{ text }">
          <a-tag :color="text === '完成' ? 'success' : 'processing'">
            {{ text }}
          </a-tag>
        </template>
        <template #result="{ text }">
          <a-tag :color="text === '通过' ? 'success' : 'error'">
            {{ text }}
          </a-tag>
        </template>
        <template #action="{ record }">
          <a @click="showDetail(record)">详情</a>
        </template>
      </a-table>

      <!-- 测试详情抽屉 -->
      <a-drawer
        v-model:visible="detailDrawer.visible"
        title="测试详情"
        width="800px"
        placement="right"
      >
        <template v-if="detailDrawer.record">
          <div class="detail-header mb-4">
            <div>产品序列号: {{ detailDrawer.record.serialNumber }}</div>
            <div>图纸编号: {{ detailDrawer.record.drawingCode }}</div>
            <div>测试时间: {{ detailDrawer.record.testTime }}</div>
          </div>

          <a-collapse v-model:activeKey="activeGroups">
            <a-collapse-panel
              v-for="group in testGroups"
              :key="group.id"
              :header="group.name"
            >
              <div class="mb-2">TestID: {{ group.testId }}</div>
              <a-table
                :columns="stepColumns"
                :data-source="group.steps"
                :pagination="false"
              >
                <template #result="{ text }">
                  <a-tag :color="text.success ? 'success' : 'error'">
                    {{ text.success ? '✓ 通过' : '✗ 失败' }}
                  </a-tag>
                </template>
              </a-table>
            </a-collapse-panel>
          </a-collapse>

          <div class="drawer-actions mt-4">
            <a-button type="primary" @click="exportPDF">导出PDF报告</a-button>
            <a-button class="ml-2" @click="exportExcel">导出Excel明细</a-button>
          </div>
        </template>
      </a-drawer>
    </a-card>
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
  padding: 24px;
}
.mt-4 {
  margin-top: 16px;
}
.mb-4 {
  margin-bottom: 16px;
}
.ml-2 {
  margin-left: 8px;
}
.search-form {
  margin-bottom: 16px;
}
.detail-header {
  background: #fafafa;
  padding: 16px;
  border-radius: 4px;
}
.drawer-actions {
  position: absolute;
  bottom: 24px;
  width: calc(100% - 48px);
}
</style> 