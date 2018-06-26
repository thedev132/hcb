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
      redirect_to @g_suite, notice: 'G suite was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /g_suites/1
  def update
    authorize @g_suite

    if @g_suite.update(g_suite_params)
      redirect_to @g_suite, notice: 'G suite was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /g_suites/1
  def destroy
    authorize @g_suite

    @g_suite.deleted_at = Time.now
    redirect_to g_suites_url, notice: 'G suite was successfully destroyed.'
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
