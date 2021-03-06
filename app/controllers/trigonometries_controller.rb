class TrigonometriesController < ApplicationController
  def new
  end

  def create
    trigonometric_equation = Trigonometry.handle_string params[:trigonometry_string]
    @solution = nil
    def solve_trigonometric_equation trigonometric_equation, array_steps, depth
      if @solution.present?
        return
      elsif depth >= 3
        return false
      else
        set_new_variable = false
        new_trigonometric_equation = Calculate.set_new_variable trigonometric_equation
        unless new_trigonometric_equation[:new_variable] == "x"
          set_new_variable = true
          array_steps.push({ message: "Đặt x = #{ new_trigonometric_equation[:new_variable] }", equation: new_trigonometric_equation[:new_equation] })
        end
        if Problem.matching_problem_types new_trigonometric_equation[:new_equation]
          problem_types = Problem.matching_problem_types new_trigonometric_equation[:new_equation]
          @solution = { array_steps: array_steps, problem_type: problem_types }
          return @solution
        else
          children = Rule.generate_children new_trigonometric_equation[:new_equation]
          if children.empty?
            return false
            if set_new_variable
              array_steps.pop()
            end
          else
            array_valid_children = Array.new
            children.each do |child|
              unless array_steps.include? child
                array_valid_children.push(child)
              end
            end
            if array_valid_children.empty?
              if set_new_variable
                array_steps.pop()
              end
              return false
            else
              array_valid_children.each do |child|
                array_steps.push(child)
                result = solve_trigonometric_equation(child[:equation], array_steps, depth + 1)
                if @solution.present?
                  return @solution
                elsif !result
                  array_steps.pop()
                end
              end
              unless @solution.present?
                if set_new_variable
                  array_steps.pop()
                end
                return false
              end
            end
          end
        end
      end
    end
    solve_trigonometric_equation trigonometric_equation, [], 0
    puts @solution
    redirect_to new_trigonometry_path
  end
end
