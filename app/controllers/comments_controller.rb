# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :set_comment, only: [:edit, :update]
  before_action :set_commentable, except: [:edit, :update]

  def new
    authorize @commentable
    @comment = @commentable.comments.new
  end

  def create
    @comment = @commentable.comments.build(comment_params)
    @comment.user = current_user

    authorize @comment

    if @comment.save
      flash[:success] = "Note created."
      redirect_to @commentable
    else
      render "new"
    end
  end

  def edit
    @commentable = @comment.commentable
    @event = @commentable.event

    authorize @comment
  end

  def update
    @comment.assign_attributes(comment_params)
    authorize @comment

    if @comment.save
      flash[:success] = "Note successfully updated"
      # @commentable is not guaranteed to have a #show,
      # but all commentables effectively have a #show
      # because that's the only place comments show up as a list.
      redirect_to @comment.commentable
    else
      render "edit"
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content, :file, :admin_only)
  end

  # Given a route "/transactions/25/comments", this method sets @commentable to
  # Transaction with ID 25
  def set_commentable
    resource = params[:comment][:commentable_type] || request.path.split("/")[1]
    id =       params[:comment][:commentable_id]   || request.path.split("/")[2]

    @commentable = resource.singularize.classify.constantize.find(id)
  end

  def set_comment
    @comment = Comment.find(params[:id] || params[:comment_id])
  end
end
