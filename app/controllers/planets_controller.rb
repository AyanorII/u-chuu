class PlanetsController < ApplicationController

  skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :set_planet, only: [:show, :edit, :update, :destroy]

  def index
    if params[:search].present?
      @planets = policy_scope(Planet).where("name ILIKE ? OR description ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    elsif params[:browse].present?
      case params[:browse]
      when "hot"
        @planets = policy_scope(Planet).where("avg_temp > 100")
      when "jungle"
        @planets = policy_scope(Planet).where("description ILIKE ?", "%jungle%")
      when "cold"
        @planets = policy_scope(Planet).where("avg_temp < 0")
      when "dark"
        @planets = policy_scope(Planet).where("revolution_time > 500")
      end
    else
      @planets = policy_scope(Planet)
    end
  end

  def show
    # @reservation = current_user.reservations.new
    # authorize @reservation
    @reservation = Reservation.new
    @reviews_avg = @planet.reviews.any? ? (@planet.reviews.average(:rating)).round(1) : 0
  end

  def new
    # @planet = Planet.new
    # @user = current_user
    @planet = current_user.planets.new
    authorize @planet
  end

  def create
    # @planet = Planet.new(planet_params)
    # @user = current_user
    # @planet.user = @user
    @planet = current_user.planets.new(planet_params)
    authorize @planet
    if @planet.save
      redirect_to owner_planets_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @planet.update(planet_params)
      redirect_to owner_planets_path
    else
      render :edit
    end
  end

  def destroy
    @planet.destroy
    redirect_to planets_path
  end

  private

  def set_planet
    @planet = Planet.find(params[:id])
    authorize @planet
  end

  def planet_params
    params.require(:planet).permit(:user_id, :name, :description, :price_per_night, :maximum_guests, :rotation_time, :revolution_time, :radius, :avg_temp, :location, photos: [])
  end

end
