class ItemsController < ApplicationController

  before_action :authenticate_user!, only: [:buy_confirmation, :edit, :destroy]

  def index
    @items = Item.includes(:images).order('created_at DESC').limit(3)
    @item_brands = Item.includes(:images).order('brand_id DESC').limit(3)
  end

  def new
    @item = Item.new
    @item.images.new
    flash[:notice] = ""
  end

  def create
    @item = Item.new(item_params)
    if @item.save
      redirect_to root_path
    else
      @item = Item.new
      @item.images.new
      flash[:notice] = "画像は一枚以上入れて下さい"
      render :new
    end
  end

  def edit
    @item = Item.find(params[:id])
    if current_user.id == @item.user_id
      flash[:notice] = ""
      render :edit
    else
      flash[:notice] = "権限がありません"
      redirect_to item_path(@item)
    end
  end

  def update
    @item = Item.find(params[:id])
    if @item.update(item_params)
      redirect_to root_path
    else
      flash[:notice] = "変更に失敗しました"
      render :edit
    end
  end

  def show
    @item = Item.find(params[:id])
    @same_user_items = Item.where(user_id: @item.user_id).order(created_at: "DESC").limit(3)
    @same_category_items = Item.where(category_id: @item.category_id).order(created_at: "DESC").limit(3)
  end

  def destroy
    item = Item.find(params[:id])
    if current_user.id == item.user_id && item.destroy
      redirect_to root_path
    else
      redirect_to item_path(item)
    end
  end

  def buy_confirmation
  end

  private

  def item_params
    params.require(:item).permit(:name, :price, :description, :category_id, :size_id, :status_id, :shipping_cost_id, :shipping_method_id, :prefecture_id, :shipping_date_id, :brand_id, :buyer_id, images_attributes: [:image, :_destroy, :id]).merge(user_id: current_user.id)
  end

  def set_brand
    @brand = Brand.select("name","id")
  end
end
