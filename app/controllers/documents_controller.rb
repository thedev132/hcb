class DocumentsController < ApplicationController
  before_action :set_event, only: [:index, :new]
  before_action :set_document, except: [:index, :new, :create]

  def index
    @documents = @event.documents
    authorize @documents
  end

  def new
    @document = Document.new(event: @event)
    authorize @document
  end

  def create
    @document = Document.new(document_params)
    @document.user = current_user
    authorize @document

    if @document.save
      flash[:success] = 'Document successfully added'
      redirect_to @document
    else
      render :new
    end
  end

  def show
    authorize @document
  end

  def edit
    authorize @document
  end

  def update
    @document.assign_attributes(document_params)
    authorize @document

    if @document.save
      flash[:success] = 'Document successfully updated'
      redirect_to @document
    else
      render :edit
    end
  end

  def destroy
    authorize @document

    @document.destroy!

    redirect_to @document.event
  end

  def download
    authorize @document

    redirect_to url_for(@document.file)

    DocumentDownload.from_request(
      request,
      document: @document,
      user: current_user
    ).save!
  end

  private

  def document_params
    params.require(:document).permit(:event_id, :name, :file)
  end

  def set_document
    @document = Document.find(params[:id] || params[:document_id])
    @event = @document.event
  end

  def set_event
    @event = Event.find(params[:id] || params[:event_id])
  end
end
