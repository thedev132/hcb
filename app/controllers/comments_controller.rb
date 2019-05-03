class CommentsController < ApplicationController
  before_action :set_commentable

  def new
    authorize @commentable
    @comment = @commentable.comments.new
  end

  def create
    @comment = @commentable.comments.build(comment_params)
    @comment.user = current_user

    authorize @comment

    if @comment.save
      flash[:success] = 'Note created.'
      redirect_to @commentable
    else
      render :new
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content, :file, :admin_only)
  end

  # Given a route "/transactions/25/comments", this method sets @commentable to
  # Transaction with ID 25
  def set_commentable
    resource, id = request.path.split('/')[1,2]
    @commentable = resource.singularize.classify.constantize.find(id)
  end
end
