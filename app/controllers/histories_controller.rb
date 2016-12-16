class HistoriesController < ApplicationController
  before_action :user_must_logged_in, only: [:index]

  def index
    @histories = History.order(id: :desc).paginate(page: params[:page], per_page: 10)
  end
end
