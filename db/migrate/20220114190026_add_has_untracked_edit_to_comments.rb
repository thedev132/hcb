# frozen_string_literal: true

# max@hackclub.com: we're adding papertrail (version history) to comments at the
# same time we're adding this migration, so this is meant to run right before
# the first version history on comments gets saved.

class AddHasUntrackedEditToComments < ActiveRecord::Migration[6.0]
  class Comment < ActiveRecord::Base
  end

  def up
    add_column :comments, :has_untracked_edit, :boolean, null: false, default: false
    Comment.find_each do |comment|
      next if comment.created_at == comment.updated_at

      comment.has_untracked_edit = true
      comment.save!
    end
  end

  def down
    remove_column :comments, :has_untracked_edit
  end

end
