class GSuitesController < ApplicationController
  before_action :set_g_suite, only: [:show, :edit, :update, :destroy]

  # GET /g_suites
  def index
    @g_suites = GSuite.all.includes(:event).order(created_at: :desc)
    authorize @g_suites
  end

  # GET /g_suites/1
  def show
    authorize @g_suite

    @commentable = @g_suite
    @comments = @commentable.comments
    @comment = Comment.new
  end

  # GET /g_suites/1/edit
  def edit
    authorize @g_suite
  end

  # PATCH/PUT /g_suites/1
  def update
    authorize GSuite

    attrs = {
      g_suite_id: @g_suite.id,
      domain: g_suite_params[:domain],
      verification_key: g_suite_params[:verification_key],
      dkim_key: g_suite_params[:dkim_key],
    }
    @g_suite = GSuiteService::Update.new(attrs).run

    if @g_suite.persisted?
      flash[:success] = 'Google Workspace changes saved.'
      redirect_to @g_suite
    else
      render :edit
    end
  rescue => e
    redirect_to edit_event_g_suite_path(@g_suite, event_id: @g_suite.event.slug), flash: { error: e.message }
  end

  # DELETE /g_suites/1
  def destroy
    authorize @g_suite

    if @g_suite.update(deleted_at: Time.now)
      flash[:success] = 'Google Workspace was successfully destroyed.'
      redirect_to g_suites_url
    else
      render :index
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_g_suite
    @g_suite = GSuite.find(params[:id])
    @event = @g_suite.event
  end

  # Only allow a trusted parameter "white list" through.
  def g_suite_params
    params.require(:g_suite).permit(:event_id, :domain, :verification_key, :dkim_key, :deleted_at)
  end
end
