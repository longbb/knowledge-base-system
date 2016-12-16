class TrigonometriesController < ApplicationController
  before_action :user_must_logged_in, only: [:show, :new, :create]
  def show
    if params[:trigonometry_equation].present?
      trigonometric_equation = Trigonometry.handle_string params[:trigonometry_equation]
      @solution = Problem.solve_equation trigonometric_equation
    end
  end

  def new
    @trigonometry_equation = params[:trigonometry_equation]
    @solution = params[:solution]
  end

  def create
    if params[:trigonometry_equation].present?
      history = History.new(
        trynogometry_string: params[:trigonometry_equation],
        user_id: current_user.id
      )
      if history.save
        redirect_to trigonometry_path(id: "trigonometry",
          trigonometry_equation: params[:trigonometry_equation])
      else
        render "new"
        flash[:danger] = "Something error"
      end
    else
      render "new"
      flash[:danger] = "Equation can not be blank"
    end
  end
end
