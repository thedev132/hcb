class DocumentsController < ApplicationController
  def new
    @document = Document.new(event_id: params[:event_id])
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
    @document = Document.find(params[:id])
    authorize @document
  end

  def edit
    @document = Document.find(params[:id])
    authorize @document
  end

  def update
    @document = Document.find(params[:id])
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
    @document = Document.find(params[:id])
    authorize @document

    @document.destroy!

    redirect_to @document.event
  end

  def download
    @document = Document.find(params[:document_id])
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
end
