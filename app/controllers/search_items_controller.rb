class SearchItemsController < ApplicationController
  before_action :check_if_signed_in
  
  def index
  end
  
  def new
  end
  
  def create
    address_results = SearchItem.full_address(search_params[:address])
    
    if !address_results
      flash.now[:errors] = ["Hmm, invalid address. Try again!"]
      render :new
    else
      @address = address_results[:address]
      @zip = address_results[:zip]
      @searches = (SearchItem.where(origin: @address) || [])
    
      if @searches.length == 0
        searches = SearchItem.wifi_locations(@address, @zip)

        searches.each do |search|
          search_item = SearchItem.new()
          search_item.name = search.shift
          search_item.address = search.shift
          search_item.origin = @address
          search_item.distance = search.pop
          search_item.search_type = "wifi"
          search.each do |el|
            search_item.url = el if el.match(/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix)
            search_item.phone_number = el if el.match(/^(?:(?:\+?1\s*(?:[.-]\s*)?)?(?:\(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\s*\)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*(?:[.-]\s*)?)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})(?:\s*(?:#|x\.?|ext\.?|extension)\s*(\d+))?$/)
          end
          search_item.user_id = current_user.id
          search_item.save!
          @searches.push(search_item)
        end
      end
    
      render :index, :locals => { :searches => @searches }
    end
  end
  
  private
  
  def search_params
    params.require(:search).permit(:address, :type)
  end
  
  def check_if_signed_in
    unless signed_in?
      flash[:errors] = ["You need to sign in!"]
      redirect_to new_session_url
    end
  end
end
