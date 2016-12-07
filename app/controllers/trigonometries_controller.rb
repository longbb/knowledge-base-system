class TrigonometriesController < ApplicationController
  def new
  end

  def create
    trigonometric_equation = Trigonometry.handle_string params[:trigonometry_string]
    $solution = nil
    $array_steps = Array.new
    def solve_trigonometric_equation trigonometric_equation
      if $solution.present?
        return
      else
        new_trigonometric_equation = Calculate.set_new_variable trigonometric_equation
        if Problem.matching_problem_types trigonometric_equation
          problem_types = Problem.matching_problem_types trigonometric_equation
          $solution = { array_steps: $array_steps, problem_type: problem_types }
          return $solution
        else
          children = Rule.generate_children trigonometric_equation
          children.each do |child|
            array_steps.push(child)
            solve_trigonometric_equation(child)
            array_steps.pop()
          end
        end
      end
    end
    solve_trigonometric_equation trigonometric_equation
    puts $solution
    redirect_to new_trigonometry_path
  end
end
