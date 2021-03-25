module Temp
  module SyncCommentsToHcbCodes
    class Nightly
      def run
        Comment.where(commentable_type: "CanonicalTransaction").find_each(batch_size: 100) do |comment|
          next unless comment.commentable

          hcb_code = HcbCode.where(hcb_code: comment.commentable.hcb_code).first
          next unless hcb_code
          next if hcb_code.comments.present? # skip if already has a comment set

          create_comment!(comment: comment, hcb_code: hcb_code)
        end

        Comment.where(commentable_type: "AchTransfer").find_each(batch_size: 100) do |comment|
          next unless comment.commentable

          hcb_code = HcbCode.where(hcb_code: comment.commentable.hcb_code).first
          next unless hcb_code
          next if hcb_code.comments.present? # skip if already has a comment set

          create_comment!(comment: comment, hcb_code: hcb_code)
        end

        Comment.where(commentable_type: "Invoice").find_each(batch_size: 100) do |comment|
          next unless comment.commentable

          hcb_code = HcbCode.where(hcb_code: comment.commentable.hcb_code).first
          next unless hcb_code
          next if hcb_code.comments.present? # skip if already has a comment set

          create_comment!(comment: comment, hcb_code: hcb_code)
        end
      end

      private

      def create_comment!(comment:, hcb_code:)
        attrs = {
          user_id: comment.user_id,
          created_at: comment.created_at,
          commentable_type: 'HcbCode',
          commentable_id: hcb_code.id,
          content: comment.content,
          admin_only: comment.admin_only,
          file: (comment.file.present? ? comment.file.blob : nil)
        }
        Comment.create!(attrs)
      end
    end
  end
end
