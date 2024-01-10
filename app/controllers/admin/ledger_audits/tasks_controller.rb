# frozen_string_literal: true

module Admin
  module LedgerAudits
    class TasksController < AdminController
      def index
        @tasks = Admin::LedgerAudit::Task.flagged
        render layout: "admin"
      end

      def show
        @task = Admin::LedgerAudit::Task.find(params[:id])
        @ledger_audit = @task.admin_ledger_audit
        render layout: "admin"
      end

      def reviewed
        @task = Admin::LedgerAudit::Task.find(params[:task_id])
        @pending = @task.status == "pending"
        @task.update(status: "reviewed", reviewer: current_user)
        redirect_to @task.admin_ledger_audit and return if @pending

        redirect_to admin_ledger_audits_tasks_path
      end

      def flagged
        @task = Admin::LedgerAudit::Task.find(params[:task_id])
        @pending = @task.status == "pending"
        @task.update(status: "flagged", reviewer: current_user)
        redirect_to @task.admin_ledger_audit and return if @pending

        redirect_to admin_ledger_audits_tasks_path
      end

    end
  end
end
