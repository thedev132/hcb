class SponsorsController < ApplicationController
  before_action :signed_in_admin, only: [ :index ]
  before_action :signed_in_user, except: [ :index ]
  before_action :set_sponsor, only: [:show, :edit, :update, :destroy]

  # GET /sponsors
  def index
    @sponsors = Sponsor.all
  end

  # GET /sponsors/1
  def show
  end

  # GET /sponsors/new
  def new
    @sponsor = Sponsor.new
  end

  # GET /sponsors/1/edit
  def edit
  end

  # POST /sponsors
  def create
    @sponsor = Sponsor.new(sponsor_params)

    if @sponsor.save
      flash[:success] = 'Sponsor was successfully created.'
      redirect_to @sponsor
    else
      render :new
    end
  end

  # PATCH/PUT /sponsors/1
  def update
    if @sponsor.update(sponsor_params)
      flash[:success] = 'Sponsor was successfully updated.'
      redirect_to @sponsor
    else
      render :edit
    end
  end

  # DELETE /sponsors/1
  def destroy
    @sponsor.destroy
    flash[:success] = 'Sponsor was successfully destroyed.'
    redirect_to sponsors_url
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_sponsor
    @sponsor = Sponsor.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def sponsor_params
    params.require(:sponsor).permit(
      :event_id,
      :name,
      :contact_email,
      :address_line1,
      :address_line2,
      :address_city,
      :address_state,
      :address_postal_code
    )
  end
end
