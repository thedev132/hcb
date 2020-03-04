class GSuiteApplicationsController < ApplicationController
  before_action :set_g_suite_application, only: [:show, :edit, :update, :destroy, :accept, :reject]
  before_action :set_event, except: [:index, :accept, :reject]

  # GET /g_suite_applications
  def index
    @g_suite_applications = GSuiteApplication.all.order(created_at: :desc).page params[:page]
    authorize @g_suite_applications
  end

  # GET /g_suite_applications/1
  def show
    authorize @g_suite_application

    @commentable = @g_suite_application
    @comments = @commentable.comments
    @comment = Comment.new
  end

  def accept
    authorize @g_suite_application
    redirect_to new_event_g_suite_path(g_suite_application_id: @g_suite_application.id, event_id: @g_suite_application.event.slug)
  end

  def reject
    @g_suite_application.rejected_at = Time.now
    @g_suite_application.fulfilled_by = current_user

    authorize @g_suite_application

    if @g_suite_application.save
      flash[:success] = 'G Suite application rejected!'
    else
      flash[:error] = @g_suite_application.errors.full_messages.join("\n")
    end
    redirect_to g_suite_applications_path
  end

  # GET /g_suite_applications/new
  def new
    @g_suite_application = GSuiteApplication.new(event: @event)
    authorize @g_suite_application
  end

  # GET /g_suite_applications/1/edit
  def edit
  end

  # POST /g_suite_applications
  def create
    @g_suite_application = GSuiteApplication.new(g_suite_application_params.merge(creator: current_user))

    authorize @g_suite_application

    if @g_suite_application.save
      flash[:success] = 'Your G Suite is being configured'
      redirect_to event_g_suite_overview_path(@g_suite_application.event)
    else
      render :new
    end
  end

  # PATCH/PUT /g_suite_applications/1
  def update
    authorize @g_suite_application

    if @g_suite_application.update(g_suite_application_params)
      flash[:success] = 'G Suite application was successfully updated.'
      redirect_to @g_suite_application
    else
      render :edit
    end
  end

  # DELETE /g_suite_applications/1
  def destroy
    @g_suite_application.canceled_at = Time.now

    authorize @g_suite_application

    @g_suite_application.destroy
    flash[:success] = 'G Suite application was successfully destroyed.'
    redirect_to @event
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_g_suite_application
    @g_suite_application = GSuiteApplication.find(params[:id] || params[:g_suite_application_id])
    @event = @g_suite_application.event
  end

  def set_event
    # TODO: needs security for if event isnt yours
    @event = @g_suite_application&.event || Event.find(params[:id] || params[:event_id])
  end

  # Only allow a trusted parameter "white list" through.
  def g_suite_application_params
    params.require(:g_suite_application).permit(:user_id, :event_id, :fulfilled_by, :domain, :rejected_at, :accepted_at, :canceled_at)
  end
end
