# app/controllers/items_controller.rb
class ItemsController < ApplicationController
  allow_unauthenticated_access only: %i[index show search]
  before_action :set_item, only: %i[show edit update destroy]
  before_action :authorize_owner!, only: %i[edit update destroy]

  def index
    @items = Item.available
                 .includes(:user, images_attachments: :blob)
                 .order(created_at: :desc)
                 .page(params[:page])
  end

  def search
    @items = Item.available.includes(:user, images_attachments: :blob)

    @items = @items.search_by_name(params[:query]) if params[:query].present?
    @items = @items.by_category(params[:category])  if params[:category].present?

    if current_user&.coordinates? && params[:radius].present?
      radius = params[:radius].to_f
      radius = [radius, 10].min # Cap at 10km
      @items = @items.nearby(current_user.location, radius)
    elsif params[:lat].present? && params[:lng].present?
      radius = (params[:radius] || 5).to_f
      @items = @items.within_radius_of(params[:lat].to_f, params[:lng].to_f, radius)
    end

    @items = @items.order(created_at: :desc).page(params[:page])

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    @loan = Loan.new
  end

  def new
    @item = current_user.items.build
  end

  def create
    @item = current_user.items.build(item_params)

    if @item.save
      redirect_to @item, notice: "Item listed successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @item.update(item_params)
      redirect_to @item, notice: "Item updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy
    redirect_to items_path, notice: "Item removed.", status: :see_other
  end

  private

  def set_item
    @item = Item.find(params[:id])
  end

  def authorize_owner!
    redirect_to items_path, alert: "Not authorized." unless @item.user_id == current_user&.id
  end

  def item_params
    params.require(:item).permit(:name, :description, :category, :condition, :available, images: [])
  end
end
