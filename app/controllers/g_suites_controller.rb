class GSuitesController < ApplicationController
  before_action :set_g_suite, only: [:show, :edit, :update, :destroy]

  # GET /g_suites
  def index
    @g_suites = GSuite.all.order(created_at: :desc)
    authorize @g_suites
  end

  # GET /g_suites/1
  def show
    authorize @g_suite

    @commentable = @g_suite
    @comments = @commentable.comments
    @comment = Comment.new
  end

  # GET /g_suites/new
  def new
    @g_suite_application = GSuiteApplication.find(params[:g_suite_application_id])
    @g_suite = GSuite.new(
      application: @g_suite_application,
      event: @g_suite_application.event,
      domain: @g_suite_application.domain
    )
    @g_suite_application.g_suite = @g_suite

    authorize @g_suite
  end

  # GET /g_suites/1/edit
  def edit
    authorize @g_suite
  end

  # POST /g_suites
  def create
    authorize GSuite

    @g_suite_application = GSuiteApplication.find(g_suite_params[:g_suite_application_id])

    attrs = {
      current_user: current_user,
      g_suite_application: @g_suite_application,

      event_id: g_suite_params[:event_id],
      domain: g_suite_params[:domain],
      verification_key: g_suite_params[:verification_key],
      dkim_key: g_suite_params[:dkim_key]
    }

    @g_suite = GSuiteService::CreateDeprecated.new(attrs).run

    if @g_suite.persisted?
      flash[:success] = "G Suite application accepted for #{@g_suite.event.name}. Domain: #{@g_suite.domain}"
      redirect_to @g_suite
    else
      render :new
    end
  end

  # PATCH/PUT /g_suites/1
  def update
    authorize @g_suite

    if @g_suite.update(g_suite_params)
      flash[:success] = 'G Suite was successfully updated.'
      redirect_to @g_suite
    else
      render :edit
    end
  end

  # DELETE /g_suites/1
  def destroy
    authorize @g_suite

    if @g_suite.update(deleted_at: Time.now)
      flash[:success] = 'G Suite was successfully destroyed.'
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
    params.require(:g_suite).permit(:g_suite_application_id, :domain, :event_id, :verification_key, :dkim_key, :deleted_at)
  end
end
