<template>
  <el-dialog
    v-model="dialogVisible"
    title="新建测试计划"
    width="600px"
    @close="handleClose"
  >
    <el-form
      ref="planFormRef"
      :model="planForm"
      :rules="planRules"
      label-width="100px"
    >
      <el-form-item label="计划名称" prop="name">
        <el-input v-model="planForm.name" placeholder="请输入计划名称" />
      </el-form-item>
      <el-form-item label="关联真值表" prop="truth_table_id">
        <el-select
          v-model="planForm.truth_table_id"
          placeholder="请选择真值表"
          style="width: 100%"
        >
          <el-option
            v-for="table in truthTables"
            :key="table.id"
            :label="table.name"
            :value="table.id"
          />
        </el-select>
      </el-form-item>
      <el-form-item label="执行模式" prop="execution_mode">
        <el-radio-group v-model="planForm.execution_mode">
          <el-radio label="sequential">顺序执行</el-radio>
          <el-radio label="parallel">并行执行</el-radio>
        </el-radio-group>
      </el-form-item>
      <el-form-item label="失败策略" prop="failure_strategy">
        <el-radio-group v-model="planForm.failure_strategy">
          <el-radio label="continue">继续执行</el-radio>
          <el-radio label="stop">停止执行</el-radio>
        </el-radio-group>
      </el-form-item>
      <el-form-item label="描述">
        <el-input
          v-model="planForm.description"
          type="textarea"
          rows="3"
          placeholder="请输入计划描述"
        />
      </el-form-item>
    </el-form>
    <template #footer>
      <span class="dialog-footer">
        <el-button @click="handleClose">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </span>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  modelValue: {
    type: Boolean,
    required: true
  },
  truthTables: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['update:modelValue', 'submit'])

const dialogVisible = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const planFormRef = ref(null)
const planForm = ref({
  name: '',
  truth_table_id: '',
  execution_mode: 'sequential',
  failure_strategy: 'stop',
  description: ''
})

const planRules = {
  name: [
    { required: true, message: '请输入计划名称', trigger: 'blur' },
    { min: 2, max: 50, message: '长度在 2 到 50 个字符', trigger: 'blur' }
  ],
  truth_table_id: [
    { required: true, message: '请选择真值表', trigger: 'change' }
  ],
  execution_mode: [
    { required: true, message: '请选择执行模式', trigger: 'change' }
  ],
  failure_strategy: [
    { required: true, message: '请选择失败策略', trigger: 'change' }
  ]
}

const handleClose = () => {
  dialogVisible.value = false
  planFormRef.value?.resetFields()
}

const handleSubmit = async () => {
  if (!planFormRef.value) return
  
  try {
    await planFormRef.value.validate()
    emit('submit', { ...planForm.value })
    handleClose()
  } catch (error) {
    // 表单验证失败
    console.error('表单验证失败:', error)
  }
}
</script>

<style scoped>
.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
</style> 