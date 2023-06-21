# frozen_string_literal: true

module TransactionGroupingEngine
  module Transaction
    class All
      def initialize(event_id:, search: nil, tag_id: nil)
        @event_id = event_id
        @search = ActiveRecord::Base.connection.quote_string(search || "")
        @tag_id = tag_id
      end

      def run
        all
      end

      def all
        canonical_transactions_grouped.map do |ctg|
          build(ctg)
        end
      end

      private

      def build(ctg)
        attrs = {
          hcb_code: ctg["hcb_code"],
          date: ctg["date"],
          amount_cents: ctg["amount_cents"],
          raw_canonical_transaction_ids: ctg["canonical_transaction_ids"],
          raw_canonical_pending_transaction_ids: ctg["canonical_pending_transaction_ids"],
          event:,
          subledger: nil,
        }
        CanonicalTransactionGrouped.new(attrs)
      end

      def event
        @event ||= Event.find(@event_id)
      end

      def canonical_event_mappings
        @canonical_event_mappings ||= CanonicalEventMapping.where(event_id: event.id)
      end

      def canonical_transactions
        @canonical_transactions ||= CanonicalTransaction.includes(:receipts).where(id: canonical_event_mappings.pluck(:canonical_transaction_id)).order("date desc, id desc")
      end

      def canonical_transaction_ids
        @canonical_transaction_ids ||= canonical_event_mappings.pluck(:canonical_transaction_id)
      end

      def search_modifier_for(type)
        return "" unless @search.present?

        type = type.to_s

        return "and (#{type}.memo ilike '%#{@search}%' or #{type}.friendly_memo ilike '%#{@search}%' or #{type}.custom_memo ilike '%#{@search}%')" if type == "ct"

        "and (#{type}.memo ilike '%#{@search}%' or #{type}.custom_memo ilike '%#{@search}%')"
      end

      def tag_modifier
        if @tag_id
          <<~SQL
            left join hcb_codes on hcb_codes.hcb_code = q1.hcb_code
            left join hcb_codes_tags on hcb_codes_tags.hcb_code_id = hcb_codes.id
            where hcb_codes_tags.tag_id = #{@tag_id}
          SQL
        end
      end

      def canonical_transactions_grouped
        pt_group_sql = <<~SQL
          select
            array_agg(pt.id) as pt_ids
            ,array[]::bigint[] as ct_ids
            ,coalesce(pt.hcb_code, cast(pt.id as text)) as hcb_code
            ,sum(pt.amount_cents) as amount_cents
            ,sum(pt.amount_cents / 100.0)::float as amount
          from
            canonical_pending_transactions pt
          where
            fronted = true -- only included fronted pending transactions
            and
            pt.id in (
              select
                cpem.canonical_pending_transaction_id
              from
                canonical_pending_event_mappings cpem
              where
                cpem.event_id = #{event.id}
                and cpem.subledger_id is null
                #{search_modifier_for :pt}
              except ( -- hide pending transactions that have either settled or been declined.
                select
                  cpsm.canonical_pending_transaction_id
                from
                  canonical_pending_settled_mappings cpsm
                union
                select
                  cpdm.canonical_pending_transaction_id
                from
                  canonical_pending_declined_mappings cpdm
              )
            )
            and
            not exists ( -- hide pt if there are ct in its hcb code (handles edge case of unsettled PT)
              select *
              from canonical_transactions ct
              inner join canonical_event_mappings cem on cem.canonical_transaction_id = ct.id
              where ct.hcb_code = pt.hcb_code and cem.event_id = #{event.id}
            )
          group by
            coalesce(pt.hcb_code, cast(pt.id as text)) -- handle edge case when hcb_code is null
        SQL

        ct_group_sql = <<~SQL
          select
            array[]::bigint[] as pt_ids
            ,array_agg(ct.id) as ct_ids
            ,coalesce(ct.hcb_code, cast(ct.id as text)) as hcb_code
            ,sum(ct.amount_cents) as amount_cents
            ,sum(ct.amount_cents / 100.0)::float as amount
          from
            canonical_transactions ct
          where
            ct.id in (
              select
                cem.canonical_transaction_id
              from
                canonical_event_mappings cem
              where
                cem.event_id = #{event.id}
                and cem.subledger_id is null
                #{search_modifier_for :ct}
            )
          group by
            coalesce(ct.hcb_code, cast(ct.id as text)) -- handle edge case when hcb_code is null
        SQL

        date_select = <<~SQL
          (
            select date
            from (
              select date
              from (
                select date from canonical_pending_transactions where id = any(q1.pt_ids) order by date asc, id asc limit 1
              ) pt_raw
              union
              select date
              from (
                select date from canonical_transactions where id = any(q1.ct_ids) order by date asc, id asc limit 1
              ) ct_raw
            ) raw
            order by date asc limit 1
          )
        SQL

        canonical_pending_transactions_select = <<~SQL
          (
            select json_agg(raw)
            from (
              select *, (amount_cents / 100.0) as amount from canonical_pending_transactions where id = any(q1.pt_ids) order by date desc, id desc
            ) raw
          )
        SQL

        canonical_pending_transaction_ids_select = <<~SQL
          (
            select array_to_json(array_agg(id))
            from (
              select id from canonical_pending_transactions where id = any(q1.pt_ids) order by date desc, id desc
            ) raw
          )
        SQL

        canonical_transactions_select = <<~SQL
          (
            select json_agg(raw)
            from (
              select *, (amount_cents / 100.0) as amount from canonical_transactions where id = any(q1.ct_ids) order by date desc, id desc
            ) raw
          )
        SQL

        canonical_transaction_ids_select = <<~SQL
          (
            select array_to_json(array_agg(id))
            from (
              select id from canonical_transactions where id = any(q1.ct_ids) order by date desc, id desc
            ) raw
          )
        SQL

        q = <<~SQL
          select
            q1.ct_ids -- ct_ids and pt_ids in this query are mutually exclusive
            ,q1.pt_ids
            ,q1.hcb_code
            ,q1.amount_cents
            ,q1.amount::float
            ,(#{date_select}) as date
            ,(#{canonical_pending_transaction_ids_select}) as canonical_pending_transaction_ids
            ,(#{canonical_pending_transactions_select}) as canonical_pending_transactions
            ,(#{canonical_transaction_ids_select}) as canonical_transaction_ids
            ,(#{canonical_transactions_select}) as canonical_transactions
          from (
            #{event.can_front_balance? ? "#{pt_group_sql}\nunion" : ''}
            #{ct_group_sql}
          ) q1
          #{tag_modifier}
          order by date desc, pt_ids[1] desc, ct_ids[1] desc
        SQL

        ActiveRecord::Base.connection.execute(q)
      end

    end
  end
end
