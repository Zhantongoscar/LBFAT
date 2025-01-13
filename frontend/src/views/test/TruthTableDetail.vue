<el-table-column prop="point_index" label="通道" width="80" />
<el-table-column label="模式" width="100">
  <template #default="{ row }">
    <el-tag 
      :type="row.mode === 'read' ? 'success' : 'warning'"
      size="small"
    >
      {{ row.mode === 'read' ? '读取' : '写入' }}
    </el-tag>
  </template>
</el-table-column>
<el-table-column prop="name" label="测试项名称" min-width="120" /> 