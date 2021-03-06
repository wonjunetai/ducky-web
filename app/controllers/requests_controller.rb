class RequestsController < ApplicationController
  before_action :set_request, only: [:show, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]

  def index
    @requests = Request.all.order("created_at DESC").paginate(:page => params[:page], :per_page => 10)
    if current_user
      Analytics.identify({
        user_id: current_user.id,
        traits: {
          email: current_user.email,
          name: current_user.name
        }
        })
    end
  end

  def show
  end

  def new
    @request = current_user.requests.build
    @chosen_group = Group.find_by(id: params[:to].to_i) if params[:to]
    # if params[:image_search]
    #   @image_results = find_item(params[:image_search])
    # end
  end

  def edit
  end

  def create
    @request = current_user.requests.build(request_params)
    if @request.save
      Analytics.track(
        user_id: current_user.id,
        user_name: current_user.name, 
        event: 'Request Created', 
        properties: {
          description: @request.description,
          location: @request.location
      })
      redirect_to @request, notice: 'Request was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @request.update(request_params)
      Analytics.track(
        user_id: current_user.id,
        user_name: current_user.name, 
        event: 'Request Updated', 
        properties: {
          description: @request.description,
          location: @request.location
      })
      redirect_to @request, notice: 'Request was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    Analytics.track(
        user_id: current_user.id,
        user_name: current_user.name, 
        event: 'Request Removed', 
        properties: {
          description: @request.description,
          location: @request.location
      })
    @request.destroy
    redirect_to requests_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_request
      @request = Request.find(params[:id])
    end

    def correct_user
      @request = current_user.requests.find_by(id: params[:id])
      redirect_to requests_path, notice: "Not authorized to edit this request" if @request.nil?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def request_params
      params.require(:request).permit(:description, :location, :group_id)
    end
end
