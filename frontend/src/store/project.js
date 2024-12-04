import { defineStore } from 'pinia'
import projectApi from '../api/project'

export const useProjectStore = defineStore('project', {
  state: () => ({
    projects: [],
    loading: false,
    error: null
  }),

  getters: {
    subscribedProjects: (state) => {
      return state.projects.filter(p => p.is_subscribed)
    }
  },

  actions: {
    async fetchProjects() {
      this.loading = true
      try {
        const response = await projectApi.getAllProjects()
        this.projects = response.data.data
        this.error = null
      } catch (error) {
        this.error = error.message
      } finally {
        this.loading = false
      }
    },

    async createProject(projectName) {
      try {
        await projectApi.createProject(projectName)
        await this.fetchProjects()
        return true
      } catch (error) {
        this.error = error.message
        return false
      }
    },

    async updateSubscription(projectName, isSubscribed) {
      try {
        await projectApi.updateSubscription(projectName, isSubscribed)
        await this.fetchProjects()
        return true
      } catch (error) {
        this.error = error.message
        return false
      }
    }
  }
}) 