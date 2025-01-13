<template>
  <div class="truth-table-manager">
    <el-container direction="vertical">
      <!-- 上部分：真值表列表和当前真值表信息 -->
      <el-container :style="{ height: isCollapse ? 'auto' : '300px' }">
        <!-- 真值表列表 -->
        <el-main class="list-container" style="width: 100%;">
          <el-card class="list-card">
            <template #header>
              <div class="card-header">
                <div class="header-left">
                  <el-button 
                    type="text" 
                    @click="isCollapse = !isCollapse"
                  >
                    <el-icon>
                      <component :is="isCollapse ? 'ArrowRight' : 'ArrowDown'" />
                    </el-icon>
                    真值表列表
                  </el-button>
                  <template v-if="currentTable">
                    <el-divider direction="vertical" />
                    <span class="current-info">
                      当前编辑：{{ currentTable.name }} | 
                      图纸编号：{{ getDrawingNumber(currentTable.drawing_id) }} | 
                      版本：{{ currentTable.version }}
                    </span>
                  </template>
                </div>
                <el-button type="primary" @click="showCreateDialog">新建真值表</el-button>
              </div>
            </template>

            <!-- 真值表列表 -->
            <el-collapse-transition>
              <div v-show="!isCollapse">
                <el-table 
                  :data="truthTables" 
                  style="width: 100%" 
                  v-loading="loading"
                  highlight-current-row
                  @current-change="handleCurrentChange"
                  :row-class-name="tableRowClassName"
                  max-height="200"
                >
                  <el-table-column prop="name" label="名称" width="300" />
                  <el-table-column label="图纸编号" width="180">
                    <template #default="{ row }">
                      {{ getDrawingNumber(row.drawing_id) }}
                    </template>
                  </el-table-column>
                  <el-table-column prop="version" label="版本" width="120" />
                  <el-table-column label="操作" width="280" fixed="right">
                    <template #default="{ row }">
                      <el-button-group>
                        <el-button 
                          type="success" 
                          size="small" 
                          @click="handleSelectTable(row)"
                        >
                          设为当前编辑表
                        </el-button>
                        <el-button 
                          type="primary" 
                          size="small" 
                          @click="handleEdit(row)"
                        >
                          编辑
                        </el-button>
                        <el-button 
                          type="danger" 
                          size="small" 
                          @click="handleDelete(row)"
                        >
                          删除
                        </el-button>
                      </el-button-group>
                    </template>
                  </el-table-column>
                </el-table>
              </div>
            </el-collapse-transition>
          </el-card>
        </el-main>
      </el-container>

      <!-- 测试组列表部分 -->
      <el-container :style="{ height: 'auto', marginTop: '20px' }">
        <el-main class="list-container" style="width: 100%;">
          <el-card class="list-card">
            <template #header>
              <div class="card-header">
                <div class="header-left">
                  <span>测试组列表</span>
                  <template v-if="currentTable">
                    <el-divider direction="vertical" />
                    <span class="current-info">
                      所属真值表：{{ currentTable.name }}
                    </span>
                  </template>
                </div>
                <el-button 
                  type="primary" 
                  @click="showCreateTestGroupDialog"
                  :disabled="!currentTable"
                >
                  新建测试组
                </el-button>
              </div>
            </template>

            <el-table 
              :data="testGroups" 
              style="width: 100%" 
              v-loading="testGroupLoading"
              @current-change="handleTestGroupClick"
              highlight-current-row
            >
              <el-table-column prop="id" label="ID" width="80" />
              <el-table-column prop="description" label="描述" />
              <el-table-column prop="level" label="级别" width="100">
                <template #default="{ row }">
                  <el-tag :type="row.level === 1 ? 'danger' : 'info'">
                    {{ row.level === 1 ? '安全类' : '普通类' }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="sequence" label="序号" width="80" />
              <el-table-column label="操作" width="200" fixed="right">
                <template #default="{ row }">
                  <el-button-group>
                    <el-button 
                      type="primary" 
                      size="small" 
                      @click.stop="handleEditTestGroup(row)"
                    >
                      编辑
                    </el-button>
                    <el-button 
                      type="danger" 
                      size="small" 
                      @click.stop="handleDeleteTestGroup(row)"
                    >
                      删除
                    </el-button>
                  </el-button-group>
                </template>
              </el-table-column>
            </el-table>
          </el-card>
        </el-main>
      </el-container>

      <!-- 测试项列表部分 -->
      <el-container :style="{ height: 'auto', marginTop: '20px' }">
        <el-main class="list-container" style="width: 100%;">
          <el-card class="list-card">
            <template #header>
              <div class="card-header">
                <div class="header-left">
                  <span>测试项列表</span>
                  <template v-if="currentTestGroup">
                    <el-divider direction="vertical" />
                    <span class="current-info">
                      所属测试组：{{ currentTestGroup.description }}
                    </span>
                  </template>
                </div>
                <el-button 
                  type="primary" 
                  @click="showCreateTestItemDialog"
                  :disabled="!currentTestGroup"
                >
                  新建测试项
                </el-button>
              </div>
            </template>

            <el-table 
              :data="testItems" 
              style="width: 100%" 
              v-loading="testItemLoading"
              :max-height="400"
            >
              <el-table-column prop="id" label="ID" width="60" />
              <el-table-column prop="device_id" label="设备ID" width="80" />
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
              <el-table-column prop="input_values" label="输入值" width="100" />
              <el-table-column prop="expected_values" label="期望值" width="100" />
              <el-table-column prop="timeout" label="超时(ms)" width="100" />
              <el-table-column label="操作" width="200" fixed="right">
                <template #default="scope">
                  <el-button-group>
                    <el-button 
                      type="primary" 
                      size="small" 
                      @click="handleEditTestItem(scope.row)"
                    >
                      编辑
                    </el-button>
                    <el-button 
                      type="danger" 
                      size="small" 
                      @click="handleDeleteTestItem(scope.row)"
                    >
                      删除
                    </el-button>
                  </el-button-group>
                </template>
              </el-table-column>
            </el-table>
          </el-card>
        </el-main>
      </el-container>

      <!-- 测试组对话框 -->
      <el-dialog
        :title="testGroupDialogTitle"
        v-model="testGroupDialogVisible"
        width="50%"
        :close-on-click-modal="false"
      >
        <el-form 
          ref="testGroupFormRef"
          :model="testGroupForm"
          :rules="testGroupRules"
          label-width="100px"
        >
          <el-form-item label="描述" prop="description">
            <el-input
              v-model="testGroupForm.description"
              type="textarea"
              rows="3"
              placeholder="请输入描述信息"
            />
          </el-form-item>
          <el-form-item label="级别" prop="level">
            <el-select v-model="testGroupForm.level" placeholder="请选择级别">
              <el-option label="普通" :value="0" />
              <el-option label="安全" :value="1" />
            </el-select>
          </el-form-item>
          <el-form-item label="序号" prop="sequence">
            <el-input-number 
              v-model="testGroupForm.sequence" 
              :min="1"
              :max="999"
              placeholder="请输入序号"
            />
          </el-form-item>
        </el-form>
        <template #footer>
          <span class="dialog-footer">
            <el-button @click="testGroupDialogVisible = false">取消</el-button>
            <el-button type="primary" @click="handleTestGroupSubmit">确定</el-button>
          </span>
        </template>
      </el-dialog>

      <!-- 真值表对话框 -->
      <el-dialog
        :title="dialogTitle"
        v-model="dialogVisible"
        width="60%"
        :close-on-click-modal="false"
      >
        <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
          <el-form-item label="名称" prop="name">
            <el-input v-model="form.name" placeholder="请输入真值表名称" />
          </el-form-item>
          <el-form-item label="图纸" prop="drawing_id">
            <el-select 
              v-model="form.drawing_id" 
              placeholder="请选择图纸"
              @change="handleDrawingChange"
              filterable
            >
              <el-option
                v-for="drawing in availableDrawings"
                :key="drawing.id"
                :label="drawing.drawing_number"
                :value="drawing.id"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="版本" prop="version">
            <el-select 
              v-model="form.version" 
              placeholder="请选择版本"
              :disabled="!form.drawing_id"
            >
              <el-option
                v-for="version in availableVersions"
                :key="version"
                :label="version"
                :value="version"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="描述" prop="description">
            <el-input
              v-model="form.description"
              type="textarea"
              rows="3"
              placeholder="请输入描述信息"
            />
          </el-form-item>
        </el-form>
        <template #footer>
          <span class="dialog-footer">
            <el-button @click="dialogVisible = false">取消</el-button>
            <el-button type="primary" @click="handleSubmit">确定</el-button>
          </span>
        </template>
      </el-dialog>

      <!-- 测试项对话框 -->
      <el-dialog
        :title="testItemDialogTitle"
        v-model="testItemDialogVisible"
        width="60%"
        :close-on-click-modal="false"
      >
        <el-form 
          ref="testItemFormRef"
          :model="testItemForm"
          :rules="testItemRules"
          label-width="100px"
        >
          <el-form-item label="测试组" prop="test_group_id">
            <el-input v-model="testItemForm.test_group_id" disabled />
          </el-form-item>
          <el-form-item label="设备" prop="device_id">
            <el-select 
              v-model="testItemForm.device_id" 
              placeholder="请选择设备" 
              clearable 
              filterable
              :loading="deviceListLoading"
            >
              <el-option
                v-for="device in sortedDeviceList"
                :key="device.id"
                :label="`${device.project_name} - ${device.module_type} (${device.serial_number})`"
                :value="device.id"
              >
                <span style="float: left">{{ device.project_name }} - {{ device.module_type }}</span>
                <span style="float: right; color: #8492a6; font-size: 13px">
                  {{ device.serial_number }}
                  <el-tag size="small" :type="device.status === 'online' ? 'success' : 'info'">
                    {{ device.status === 'online' ? '在线' : '离线' }}
                  </el-tag>
                </span>
              </el-option>
            </el-select>
          </el-form-item>
          <el-form-item label="单元序号" prop="point_index">
            <el-input-number 
              v-model="testItemForm.point_index" 
              :min="0"
              :max="999"
              placeholder="请输入单元序号"
            />
          </el-form-item>
          <el-form-item label="模式" prop="mode">
            <el-select v-model="testItemForm.mode" placeholder="请选择模式">
              <el-option label="读取" value="read" />
              <el-option label="写入" value="write" />
            </el-select>
          </el-form-item>
          <el-form-item label="描述" prop="description">
            <el-input
              v-model="testItemForm.description"
              type="textarea"
              :rows="2"
              placeholder="请输入测试项描述"
            />
          </el-form-item>
          <el-form-item label="输入值" prop="input_values">
            <el-input-number
              v-model="testItemForm.input_values"
              :precision="2"
              :step="0.1"
              placeholder="请输入数值"
            />
          </el-form-item>
          <el-form-item label="期望值" prop="expected_values">
            <el-input-number
              v-model="testItemForm.expected_values"
              :precision="2"
              :step="0.1"
              placeholder="请输入数值"
            />
          </el-form-item>
          <el-form-item label="超时时间" prop="timeout">
            <el-input-number 
              v-model="testItemForm.timeout" 
              :min="1000"
              :step="1000"
              :max="60000"
              placeholder="请输入超时时间(毫秒)"
            />
          </el-form-item>
        </el-form>
        <template #footer>
          <span class="dialog-footer">
            <el-button @click="testItemDialogVisible = false">取消</el-button>
            <el-button type="primary" @click="handleTestItemSubmit">确定</el-button>
          </span>
        </template>
      </el-dialog>
    </el-container>
  </div>
</template>

<script>
import { ref, onMounted, computed, watch, reactive } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { ArrowDown, ArrowRight } from '@element-plus/icons-vue'
import { useRouter } from 'vue-router'
import { getAvailableDrawings, getTruthTables, createTruthTable, updateTruthTable, deleteTruthTable, getTruthTable } from '@/api/truthTable'
import { getTestGroups, createTestGroup, updateTestGroup, deleteTestGroup } from '@/api/testGroup'
import testItemApi from '@/api/testItem'
import api from '@/utils/api'

export default {
  name: 'TemplateManager',
  components: {
    ArrowDown,
    ArrowRight
  },
  setup() {
    const router = useRouter()
    
    // 真值表数据
    const truthTables = ref([])
    const availableDrawings = ref([])
    const availableVersions = ref([])
    const loading = ref(false)
    const isCollapse = ref(true)
    const currentTable = ref(null)

    // 对话框控制
    const dialogVisible = ref(false)
    const dialogTitle = ref('')
    const isEdit = ref(false)

    // 表单数据
    const formRef = ref(null)
    const form = ref({
      id: null,
      name: '',
      drawing_id: '',
      version: '',
      description: ''
    })

    // 表单验证规则
    const rules = {
      name: [{ required: true, message: '请输入真值表名称', trigger: 'blur' }],
      drawing_id: [{ required: true, message: '请选择图纸', trigger: 'change' }],
      version: [{ required: true, message: '请选择版本', trigger: 'change' }]
    }

    // 测试组相关数据
    const testGroups = ref([])
    const testGroupLoading = ref(false)
    const currentTestGroup = ref(null)
    const testGroupDialogVisible = ref(false)
    const testGroupDialogTitle = ref('')
    const isTestGroupEdit = ref(false)

    // 测试组表单
    const testGroupFormRef = ref(null)
    const testGroupForm = ref({
      id: null,
      description: '',
      level: 0,
      sequence: 1,
      truth_table_id: null
    })

    // 测试组表单验证规则
    const testGroupRules = {
      description: [{ required: true, message: '请输入描述信息', trigger: 'blur' }],
      level: [{ required: true, message: '请选择级别', trigger: 'change' }],
      sequence: [{ required: true, message: '请输入序号', trigger: 'blur' }]
    }

    // 测试项相关数据
    const testItems = ref([])
    const testItemLoading = ref(false)
    const currentTestItem = ref(null)
    const testItemDialogVisible = ref(false)
    const testItemDialogTitle = ref('')
    const testItemFormRef = ref(null)
    const deviceList = ref([])
    const deviceListLoading = ref(false)

    // 获取设备列表
    const fetchDevices = async () => {
      console.log('=== 开始获取设备列表 ===');
      deviceListLoading.value = true;
      try {
        console.log('调用 API 获取设备列表...');
        const res = await api.get('/devices');
        console.log('设备列表 API 响应:', res);
        
        if (res && res.data && res.data.code === 200) {
          console.log('设备列表响应数据:', res.data);
          const devices = res.data.data;
          if (Array.isArray(devices)) {
            deviceList.value = devices.map(device => ({
              id: device.id,
              project_name: device.project_name || '',
              module_type: device.module_type || '',
              serial_number: device.serial_number || '',
              status: device.status || 'offline'
            }));
            console.log('设备列表更新成功，当前数量:', deviceList.value.length);
            console.log('当前设备列表数据:', JSON.stringify(deviceList.value, null, 2));
          } else if (Array.isArray(res.data)) { // 直接处理数组格式的响应
            deviceList.value = res.data.map(device => ({
              id: device.id,
              project_name: device.project_name || '',
              module_type: device.module_type || '',
              serial_number: device.serial_number || '',
              status: device.status || 'offline'
            }));
            console.log('设备列表更新成功(直接数组)，当前数量:', deviceList.value.length);
            console.log('当前设备列表数据:', JSON.stringify(deviceList.value, null, 2));
          } else {
            console.error('设备列表数据格式错误:', res.data);
            throw new Error('获取设备列表失败: 数据格式错误');
          }
        } else if (Array.isArray(res.data)) { // 处理直接返回数组的情况
          deviceList.value = res.data.map(device => ({
            id: device.id,
            project_name: device.project_name || '',
            module_type: device.module_type || '',
            serial_number: device.serial_number || '',
            status: device.status || 'offline'
          }));
          console.log('设备列表更新成功(直接响应)，当前数量:', deviceList.value.length);
          console.log('当前设备列表数据:', JSON.stringify(deviceList.value, null, 2));
        } else {
          console.error('API 响应格式错误:', res);
          throw new Error('获取设备列表失败: 响应格式错误');
        }
      } catch (error) {
        console.error('获取设备列表失败，详细错误:', error);
        ElMessage.error('获取设备列表失败: ' + (error.message || '未知错误'));
        deviceList.value = [];
      } finally {
        deviceListLoading.value = false;
      }
    };

    // 监听设备列表变化
    watch(deviceList, (newValue) => {
      console.log('设备列表发生变化，新数量:', newValue.length);
      console.log('新的设备列表:', JSON.stringify(newValue, null, 2));
    });

    // 计算属性：过滤和排序后的设备列表
    const sortedDeviceList = computed(() => {
      return deviceList.value
        .slice()
        .sort((a, b) => {
          // 首先按项目名称排序
          if (a.project_name !== b.project_name) {
            return a.project_name.localeCompare(b.project_name);
          }
          // 然后按模块类型排序
          if (a.module_type !== b.module_type) {
            return a.module_type.localeCompare(b.module_type);
          }
          // 最后按序列号排序
          return a.serial_number.localeCompare(b.serial_number);
        });
    });

    const testItemForm = reactive({
      device_id: '',
      point_index: 1,
      description: '',
      input_values: 0,
      expected_values: 0,
      timeout: 5000,
      mode: 'read',
      test_group_id: null
    });

    // 显示创建测试项对话框
    const showCreateTestItemDialog = async () => {
      console.log('=== 打开新建测试项对话框 ===');
      console.log('对话框打开前的设备列表数量:', deviceList.value.length);
      
      testItemDialogTitle.value = '新建测试项';
      testItemForm.id = undefined;
      testItemForm.test_group_id = currentTestGroup.value.id;
      testItemForm.device_id = '';
      testItemForm.point_index = 1;
      testItemForm.description = '';
      testItemForm.input_values = 0;
      testItemForm.expected_values = 0;
      testItemForm.timeout = 5000;
      testItemForm.mode = 'read';  // 默认为读取模式
      
      console.log('重新获取设备列表...');
      await fetchDevices();
      console.log('对话框打开后的设备列表数量:', deviceList.value.length);
      console.log('可选择的设备列表:', JSON.stringify(deviceList.value, null, 2));
      
      testItemDialogVisible.value = true;
    };

    // 显示编辑测试项对话框
    const handleEditTestItem = async (row) => {
      console.log('编辑测试项，原始数据:', row);
      if (!row || !row.id) {
        console.error('编辑的行数据为空');
        return;
      }

      testItemDialogTitle.value = '编辑测试项';
      testItemLoading.value = true;

      try {
        // 每次编辑时都重新获取设备列表
        await fetchDevices();
        
        // 设置表单数据，保留id用于区分编辑模式
        testItemForm.id = row.id;
        testItemForm.test_group_id = row.test_group_id;
        testItemForm.device_id = row.device_id;
        testItemForm.point_index = parseInt(row.point_index) || 1;
        testItemForm.description = row.description || '';
        testItemForm.input_values = parseFloat(row.input_values) || 0;
        testItemForm.expected_values = parseFloat(row.expected_values) || 0;
        testItemForm.timeout = parseInt(row.timeout) || 5000;
        testItemForm.mode = row.mode || 'read';  // 设置测试模式

        console.log('表单数据设置完成:', testItemForm);
      } catch (error) {
        console.error('处理测试项数据失败:', error);
        ElMessage.error('处理数据失败');
      } finally {
        testItemLoading.value = false;
        testItemDialogVisible.value = true;
      }
    };

    // 获取真值表列表
    const fetchTruthTables = async () => {
      loading.value = true
      try {
        console.log('开始获取真值表列表...');
        const res = await getTruthTables();
        console.log('获取真值表响应:', res);

        if (res.data.code === 200 && Array.isArray(res.data.data)) {
          truthTables.value = res.data.data;
          console.log('更新真值表数据:', truthTables.value);
          
          // 获取上次选中的真值表ID
          const lastSelectedId = localStorage.getItem('lastSelectedTruthTableId');
          let targetTable = null;

          if (lastSelectedId) {
            // 尝试找到上次选中的真值表
            targetTable = truthTables.value.find(t => t.id === parseInt(lastSelectedId));
          }

          // 如果没有上次选中的真值表或找不到对应记录，选择最新的真值表
          if (!targetTable && truthTables.value.length > 0) {
            targetTable = truthTables.value[0]; // 后端已按更新时间降序排序
          }

          // 如果找到目标真值表，设置当前编辑表
          if (targetTable) {
            console.log('自动选择真值表:', targetTable);
            await handleSelectTable(targetTable);
          } else {
            console.log('没有选的真值表');
            currentTable.value = null;
          }
        } else {
          console.error('获取真值表响应格式错误:', res.data);
          ElMessage.error('获取真值表数据格式错误');
          truthTables.value = [];
        }
      } catch (error) {
        console.error('获取真值表列表失败:', error);
        ElMessage.error('获取真值表表失败');
        truthTables.value = [];
      } finally {
        loading.value = false;
      }
    };

    // 处理当前选中行变化
    const handleCurrentChange = async (row) => {
      if (row && (!currentTable.value || currentTable.value.id !== row.id)) {
        currentTable.value = row
        localStorage.setItem('lastSelectedTruthTableId', row.id)
        await fetchTestGroups(row.id)
      }
    }

    // 设置表格行的类名
    const tableRowClassName = ({ row }) => {
      if (currentTable.value && row.id === currentTable.value.id) {
        return 'current-row'
      }
      return ''
    }

    // 获取可图纸列表
    const fetchAvailableDrawings = async () => {
      try {
        const res = await getAvailableDrawings()
        availableDrawings.value = res.data.data
      } catch (error) {
        console.error('获取可用图纸列表失败:', error)
        ElMessage.error('获取可用图纸列表失败')
      }
    }

    // 处理图纸选择变化
    const handleDrawingChange = (drawingId) => {
      form.value.version = '' // 清空版本选择
      if (drawingId) {
        const selectedDrawing = availableDrawings.value.find(d => d.id === drawingId)
        if (selectedDrawing) {
          // 获取选中图纸的所有版本
          const versions = availableDrawings.value
            .filter(d => d.drawing_number === selectedDrawing.drawing_number)
            .map(d => d.version)
          availableVersions.value = versions
        }
      } else {
        availableVersions.value = []
      }
    }

    // 显示创建对话框
    const showCreateDialog = () => {
      isEdit.value = false
      dialogTitle.value = '新建真值表'
      form.value = {
        id: null,
        name: '',
        drawing_id: '',
        version: '',
        description: ''
      }
      availableVersions.value = []
      dialogVisible.value = true
    }

    // 显示编辑对话框
    const handleEdit = (row) => {
      isEdit.value = true
      dialogTitle.value = '编辑真值表'
      form.value = { ...row }
      handleDrawingChange(row.drawing_id)
      dialogVisible.value = true
    }

    // 处理删除
    const handleDelete = async (row) => {
      try {
        await ElMessageBox.confirm('确定要删除这个真值表吗？', '提示', {
          type: 'warning'
        })
        await deleteTruthTable(row.id)
        ElMessage.success('删除成功')
        
        // 如果删除的是当前选中的真值表，清空选中状态
        if (currentTable.value && currentTable.value.id === row.id) {
          currentTable.value = null
          localStorage.removeItem('lastSelectedTruthTableId')
        }
        
        fetchTruthTables()
      } catch (error) {
        if (error !== 'cancel') {
          console.error('删除真值表失败:', error)
          ElMessage.error('删除真值表失败')
        }
      }
    }

    // 提交表单
    const handleSubmit = async () => {
      if (!formRef.value) return

      try {
        await formRef.value.validate()

        // 处理表单数据，确保没有undefined值
        const formData = {
          id: form.value.id || null,
          name: form.value.name || '',
          drawing_id: form.value.drawing_id || null,
          version: form.value.version || '',
          description: form.value.description || ''
        }

        if (isEdit.value) {
          await updateTruthTable(formData.id, formData)
          ElMessage.success('更新成功')
        } else {
          const res = await createTruthTable(formData)
          ElMessage.success('创建成功')
          // 选中新创建的真值表
          currentTable.value = res.data.data
          localStorage.setItem('lastSelectedTruthTableId', res.data.data.id)
        }

        dialogVisible.value = false
        fetchTruthTables()
      } catch (error) {
        if (error !== 'cancel') {
          console.error('保存真值表失败:', error)
          ElMessage.error('保存真值表失败')
        }
      }
    }

    // 获取图纸编号
    const getDrawingNumber = (drawingId) => {
      const drawing = availableDrawings.value.find(d => d.id === drawingId)
      return drawing ? drawing.drawing_number : '-'
    }

    // 格式化日期
    const formatDate = (date) => {
      return new Date(date).toLocaleString()
    }

    // 选择当前真值表
    const handleSelectTable = async (row) => {
      try {
        console.log('开始选择真值表，数据:', row)
        
        // 更新本地状态
        currentTable.value = row
        localStorage.setItem('lastSelectedTruthTableId', row.id)
        
        // 存储当前选中的真值表信息到 localStorage
        const tableInfo = {
          id: row.id,
          name: row.name,
          drawing_id: row.drawing_id,
          version: row.version,
          drawingNumber: getDrawingNumber(row.drawing_id)
        }
        localStorage.setItem('selectedTruthTable', JSON.stringify(tableInfo))
        
        // 加载测试组列表
        await fetchTestGroups(row.id)
        
        ElMessage.success('已设置为当前编辑表')
      } catch (error) {
        console.error('设置当前编辑表失败:', error)
        ElMessage.error('设置当前编辑表失败')
        
        // 发生错误时回滚状态
        currentTable.value = null
        localStorage.removeItem('selectedTruthTable')
        localStorage.removeItem('lastSelectedTruthTableId')
      }
    }

    // 获测试组列表
    const fetchTestGroups = async () => {
      if (!currentTable.value) return;
      testGroupLoading.value = true;
      try {
        const response = await getTestGroups(currentTable.value.id);
        testGroups.value = response.data.data;
      } catch (error) {
        console.error('获取测试组列表失败:', error);
        ElMessage.error('获取测试组列表失败');
      } finally {
        testGroupLoading.value = false;
      }
    }

    // 显示创建测试组对话框
    const showCreateTestGroupDialog = () => {
      if (!currentTable.value) {
        ElMessage.warning('请先选择一个真值表')
        return
      }
      isTestGroupEdit.value = false
      testGroupDialogTitle.value = '新建测试组'
      testGroupForm.value = {
        id: null,
        description: '',
        level: 1,
        sequence: testGroups.value.length + 1,
        truth_table_id: currentTable.value.id
      }
      testGroupDialogVisible.value = true
    }

    // 显示编辑测试组对话框
    const handleEditTestGroup = (row) => {
      isTestGroupEdit.value = true
      testGroupDialogTitle.value = '编辑测试组'
      testGroupForm.value = { ...row }
      testGroupDialogVisible.value = true
    }

    // 提交测试组表单
    const handleTestGroupSubmit = async () => {
      if (!testGroupFormRef.value) return;
      await testGroupFormRef.value.validate(async (valid) => {
        if (valid) {
          try {
            if (isTestGroupEdit.value) {
              await updateTestGroup(
                currentTable.value.id,
                testGroupForm.value.id,
                testGroupForm.value
              );
              ElMessage.success('更新成功');
            } else {
              await createTestGroup(
                currentTable.value.id,
                testGroupForm.value
              );
              ElMessage.success('创建成功');
            }
            testGroupDialogVisible.value = false;
            fetchTestGroups();
          } catch (error) {
            console.error('操作失败:', error);
            ElMessage.error('操作失败');
          }
        }
      });
    }

    // 删除测试组
    const handleDeleteTestGroup = async (row) => {
      try {
        await ElMessageBox.confirm(
          '确定要删除该测试组吗？',
          '提示',
          {
            confirmButtonText: '确定',
            cancelButtonText: '取消',
            type: 'warning'
          }
        );
        await deleteTestGroup(currentTable.value.id, row.id);
        ElMessage.success('删除成功');
        fetchTestGroups();
      } catch (error) {
        if (error !== 'cancel') {
          console.error('删除失败:', error);
          ElMessage.error('删除失败');
        }
      }
    }

    // 监听当前真值表变化
    watch(() => currentTable.value, (newVal) => {
      if (!newVal) {
        testGroups.value = []
      }
    })

    // 加载测试项列表
    const loadTestItems = async (groupId) => {
      if (!groupId) {
        console.log('无效的测试组ID');
        return;
      }
      
      console.log('开始加载测试组的测试项, 组ID:', groupId);
      testItemLoading.value = true;
      
      try {
        const response = await testItemApi.getByGroupId(groupId);
        console.log('获取到的测试项数据:', response);
        
        if (Array.isArray(response)) {
          testItems.value = response;
          console.log('测试项列表更新完成，数量:', testItems.value.length);
        } else {
          console.error('API返回数据格式错误:', response);
          testItems.value = [];
        }
      } catch (error) {
        console.error('加载测试项失败:', error);
        ElMessage.error('加载测试项失败');
        testItems.value = [];
      } finally {
        testItemLoading.value = false;
      }
    };

    // 处理测试项表单提交
    const handleTestItemSubmit = async () => {
      if (!testItemFormRef.value) return;
      
      try {
        await testItemFormRef.value.validate();
        
        const formData = {
          test_group_id: testItemForm.test_group_id,
          device_id: testItemForm.device_id,
          point_index: testItemForm.point_index,
          description: testItemForm.description,
          input_values: testItemForm.input_values,
          expected_values: testItemForm.expected_values,
          timeout: testItemForm.timeout,
          mode: testItemForm.mode  // 添加mode字段
        };

        let response;
        if (testItemForm.id) {
          // 编辑模式
          response = await testItemApi.update(testItemForm.id, formData);
          ElMessage.success('修改测试项成功');
        } else {
          // 新建模式
          response = await testItemApi.create(formData);
          ElMessage.success('创建测试项成功');
        }

        testItemDialogVisible.value = false;
        // 刷新当前测试组的测试项列表
        if (currentTestGroup.value) {
          handleTestGroupClick(currentTestGroup.value);
        }
      } catch (error) {
        console.error('提交测试项失败:', error);
        ElMessage.error('提交失败: ' + (error.message || '未知错误'));
      }
    };

    // 处理删除测试项
    const handleDeleteTestItem = async (row) => {
      console.log('=== 删除测试项开始 ===');
      console.log('要删除的数据:', JSON.stringify(row, null, 2));
      try {
        await ElMessageBox.confirm('确定要删除该测试项吗？', '提示', {
          type: 'warning'
        });
        
        console.log('[DELETE] 发送删除请求***，ID:', row.id);
        try {
          const response = await testItemApi.delete(row.id);
          console.log('[DELETE] 删除请求响应:', response);
          ElMessage.success('删除成功');
        } catch (deleteError) {
          console.error('[DELETE] 删除请求失败:', deleteError);
          ElMessage.error('删除失败: ' + (deleteError.message || '未知错误'));
          throw deleteError;
        }
      } catch (error) {
        if (error !== 'cancel') {
          console.error('[ERROR] 删除测试项失败:', error);
        }
      } finally {
        // 无论删除成功还是失败，都刷新列表
        console.log('[REFRESH] 开始刷新测试项列表...');
        if (currentTestGroup.value && currentTestGroup.value.id) {
          try {
            await loadTestItems(currentTestGroup.value.id);
            console.log('[REFRESH] 测试项列表已更新');
          } catch (refreshError) {
            console.error('[REFRESH] 刷新列表失败:', refreshError);
          }
        }
      }
    };

    // 处理测试项点击
    const handleTestItemClick = (row) => {
      currentTestItem.value = row;
    };

    // 在选择测试组时加载测试项
    const handleTestGroupClick = async (row) => {
      console.log('测试组点击，完整数据:', JSON.stringify(row, null, 2));
      if (!row || !row.id) {
        console.log('无效的行数据');
        return;
      }
      
      try {
        currentTestGroup.value = row;
        testItemLoading.value = true;
        const response = await testItemApi.getByGroupId(row.id);
        console.log('获取到的测试项数据:', response);
        
        if (Array.isArray(response)) {
          // API层已经处理了数据类型转换，这里直接使用
          testItems.value = response;
        } else {
          console.error('API返回数据格式错误:', response);
          testItems.value = [];
        }
      } catch (error) {
        console.error('加载测试项失败:', error);
        ElMessage.error('加载测试项失败');
        testItems.value = [];
      } finally {
        testItemLoading.value = false;
      }
    };

    const testItemRules = {
      device_id: [
        { required: true, message: '请选择设备', trigger: 'change' }
      ],
      point_index: [
        { required: true, message: '请输入单元序号', trigger: 'blur' },
        { type: 'number', min: 0, message: '单元序号必须大于等于0', trigger: 'blur' }
      ],
      input_values: [
        { required: true, message: '请输入输入值', trigger: 'blur' },
        { type: 'number', message: '输入值必须为数字', trigger: 'blur' }
      ],
      expected_values: [
        { required: true, message: '请输入期望值', trigger: 'blur' },
        { type: 'number', message: '期望值必须为数字', trigger: 'blur' }
      ],
      timeout: [
        { required: true, message: '请输入超时时间', trigger: 'blur' },
        { type: 'number', min: 1000, message: '超时时间必须大于1000ms', trigger: 'blur' }
      ],
      mode: [
        { required: true, message: '请选择测试模式', trigger: 'change' }
      ]
    };

    // 添加快速选择处理方法
    const handleQuickSelect = (row, field, value) => {
      row[field] = value;
      handleValueChange(row);
    };

    onMounted(() => {
      console.log('组件挂载，开始初始化...');
      fetchTruthTables();
      fetchAvailableDrawings();
      fetchDevices();
    });

    return {
      // 数据
      truthTables,
      availableDrawings,
      availableVersions,
      loading,
      isCollapse,
      currentTable,

      // 对话框
      dialogVisible,
      dialogTitle,
      form,
      formRef,
      rules,

      // 方法
      showCreateDialog,
      handleEdit,
      handleDelete,
      handleSubmit,
      handleDrawingChange,
      handleCurrentChange,
      tableRowClassName,
      getDrawingNumber,
      formatDate,
      handleSelectTable,
      fetchTestGroups,
      handleTestGroupSubmit,
      handleDeleteTestGroup,

      // 测试组相关数据
      testGroups,
      testGroupLoading,
      testGroupDialogVisible,
      testGroupDialogTitle,
      testGroupFormRef,
      testGroupForm,
      testGroupRules,
      showCreateTestGroupDialog,
      handleEditTestGroup,
      handleTestGroupSubmit,
      handleDeleteTestGroup,

      // 测试项相关数据
      testItems,
      testItemLoading,
      currentTestItem,
      testItemDialogVisible,
      testItemDialogTitle,
      testItemFormRef,
      testItemForm,
      testItemRules,
      showCreateTestItemDialog,
      handleEditTestItem,
      handleTestItemSubmit,
      handleDeleteTestItem,
      handleTestItemClick,
      handleTestGroupClick,
      currentTestGroup,

      // 设备列表相关
      deviceList,
      deviceListLoading,
      sortedDeviceList,

      // 快速选择处理方法
      handleQuickSelect,
    }
  }
}
</script>

<style scoped>
.truth-table-manager {
  height: 100%;
  padding: 20px;
}

.el-container {
  background-color: #fff;
}

.list-container {
  padding: 0;
  overflow: hidden;
  transition: height 0.3s ease-in-out;
}

.list-card {
  height: 100%;
  transition: height 0.3s ease-in-out;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-left {
  display: flex;
  align-items: center;
  flex: 1;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

:deep(.el-table .current-row) {
  background-color: #ecf5ff;
}

:deep(.el-button.el-button--text) {
  display: flex;
  align-items: center;
  gap: 4px;
}

:deep(.el-main) {
  padding: 0;
}

:deep(.el-card__body) {
  height: calc(100% - 60px);
  overflow-y: auto;
}

.current-info {
  color: #409EFF;
  font-weight: bold;
  margin-left: 8px;
  font-size: 14px;
}

.el-divider--vertical {
  margin: 0 12px;
  height: 20px;
}

.el-input-number {
  width: 100%;
}

.el-button-group {
  display: flex;
  gap: 5px;
}

.el-button-group .el-button {
  margin-left: 0;
}

.value-input-container {
  display: flex;
  align-items: center;
}

.el-dropdown-link {
  cursor: pointer;
  display: flex;
  align-items: center;
  padding: 0 5px;
}

:deep(.el-input-group__append) {
  padding: 0;
}

:deep(.el-input__wrapper) {
  padding-right: 0;
}
</style> 