class TrigonometriesController < ApplicationController
  def index
    if params[:trigonometry_equation].present?
      trigonometric_equation = Trigonometry.handle_string params[:trigonometry_equation]
      @solution = Problem.solve_equation trigonometric_equation
    end
  end

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
end
