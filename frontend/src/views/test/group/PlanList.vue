<template>
  <el-aside class="plan-list-aside">
    <div class="list-header">
      <h3>测试计划列表</h3>
      <el-input
        v-model="searchInput"
        placeholder="搜索测试计划"
        @input="$emit('search', searchInput)"
      />
    </div>
    <el-scrollbar>
      <el-menu
        :default-active="selectedPlanId"
        @select="handleSelect"
      >
        <el-menu-item
          v-for="plan in plans"
          :key="plan.id"
          :index="plan.id.toString()"
        >
          <div class="plan-item">
            <span>{{ plan.name }}</span>
            <el-button
              v-if="!plan.name.startsWith('默认测试计划')"
              type="danger"
              size="small"
              @click.stop="$emit('delete', plan.id)"
            >
              删除
            </el-button>
          </div>
        </el-menu-item>
      </el-menu>
    </el-scrollbar>
  </el-aside>
</template>

<style scoped>
.plan-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}
</style> 