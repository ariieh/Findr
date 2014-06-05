class UsersController < ApplicationController
  def new
  end
  
  def create
    @user = User.new(user_params)
    
    if @user.save
      sign_in @user
      redirect_to @user
    else
      flash.now[:error] = @user.errors.full_messages
      render :new
    end
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  private
  
  def user_params
    params.require(:user).permit(:username, :password)
  end
end