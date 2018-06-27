class GSuitesController < ApplicationController
  before_action :set_g_suite, only: [:show, :edit, :update, :destroy]

  # GET /g_suites
  def index
    @g_suites = GSuite.all
    authorize @g_suites
  end

  # GET /g_suites/1
  def show
    authorize @g_suite
  end

  # GET /g_suites/new
  def new
    @g_suite = GSuite.new
  end

  # GET /g_suites/1/edit
  def edit
  end

  # POST /g_suites
  def create
    @g_suite = GSuite.new(g_suite_params)

    authorize @g_suite

    if @g_suite.save
      flash[:success] = 'G Suite was successfully created.'
      redirect_to event_g_suite_path(@g_suite.id, event_id: @g_suite.event.id)
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

    @g_suite.deleted_at = Time.now
    flash[:success] = 'G Suite was successfully destroyed.'
    redirect_to g_suites_url
  end

  def status
    @event = Event.find(params[:event_id])
    @status = @event.g_suite_status
    @g_suite = @event.g_suite
    @g_suite_application = @event.g_suite_application
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_g_suite
      @g_suite = GSuite.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def g_suite_params
      params.require(:g_suite).permit(:g_suite_application_id, :domain, :event_id, :verification_key, :deleted_at)
    end
end
