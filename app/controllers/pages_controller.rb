class PagesController < ApplicationController
  def index
    @pages = Pages.all
    respond_to do |format|
      format.json { render :json => @pages}
      format.html {}
    end
  end

  def show
    @page = Pages.find(:id => params[:id])
    respond_to do |format|
      format.json { render :json => @page}
      format.html {}
    end
  end
end
