# frozen_string_literal: true

module ExperimentJob
  class EventFrontedBalance < ApplicationJob
    def perform(event_id:, start_date: nil, end_date: nil)
      @event_id = event_id
      @start_date = start_date
      @end_date = end_date

      # After merging into production, we'll need to enable this experiment
      # using the production Rails Console:
      # ```ruby
      # LabTech.enable "event_fronted_balance_10_31_2022"
      # ````
      LabTech.science "event_fronted_balance_10_31_2022" do |exp|
        exp.context event_id: event.id

        exp.use { control }
        exp.try("bulk") { candidate_bulk }
        exp.try("sql") { candidate_sql }
      end
    end

    def control
      # It is important that `queue_experiment = false` to prevent an infinite loop
      event.fronted_incoming_balance_v2_cents(start_date: @start_date, end_date: @end_date, queue_experiment: false)
    end

    def candidate_bulk
      pts = event.canonical_pending_transactions.incoming.fronted.not_declined

      pts = pts.where("date >= ?", @start_date) if @start_date
      pts = pts.where("date <= ?", @end_date) if @end_date

      pt_sum_by_hcb_code = pts.group(:hcb_code).sum(:amount_cents)
      hcb_codes = pt_sum_by_hcb_code.keys

      ct_sum_by_hcb_code = event.canonical_transactions.where(hcb_code: hcb_codes)
                                .group(:hcb_code).sum(:amount_cents)

      pt_sum_by_hcb_code.reduce 0 do |sum, (hcb_code, pt_sum)|
        sum + [pt_sum - (ct_sum_by_hcb_code[hcb_code] || 0), 0].max
      end
    end

    def candidate_sql
      date_sql = ""
      date_sql += "AND date >= '#{@start_date.utc.to_s(:db)}'" if @start_date
      date_sql += "AND date <= '#{@end_date.utc.to_s(:db)}'" if @end_date

      sql = <<~SQL
        SELECT SUM(GREATEST((COALESCE(cpt_amount_cents, 0) - COALESCE(ct_amount_cents, 0)), 0)) as amount_cents
        FROM
        (
            SELECT SUM(amount_cents) as cpt_amount_cents, hcb_code
            FROM "canonical_pending_transactions" cpt
            JOIN "canonical_pending_event_mappings" cpem ON cpem.canonical_pending_transaction_id = cpt.id
            WHERE cpem.event_id = #{@event_id} AND cpt.amount_cents > 0
              AND cpt.fronted = true #{date_sql}
              AND cpt.id NOT IN (
                  SELECT cpdm.canonical_pending_transaction_id
                  FROM "canonical_pending_declined_mappings" cpdm
              )
            GROUP BY hcb_code
        ) cpts
        FULL JOIN
        (
            SELECT SUM(amount_cents) as ct_amount_cents, hcb_code
            FROM "canonical_transactions" ct
            JOIN "canonical_event_mappings" cem ON cem.canonical_transaction_id = ct.id
            WHERE cem.event_id = #{@event_id}
            GROUP BY hcb_code
        ) cts
        ON cpts.hcb_code = cts.hcb_code
        WHERE cpts.cpt_amount_cents > 0
      SQL

      ActiveRecord::Base.connection.execute(sql).first["amount_cents"].to_i
    end

    private

    def event
      @event ||= Event.find(@event_id)
    end

  end
end
