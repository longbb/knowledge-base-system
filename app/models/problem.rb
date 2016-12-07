class Problem < ApplicationRecord
  class << self
    def matching_problem_types trigonometric_equation
      arr_element_contain_variable = Calculate.get_element_contain_variable trigonometric_equation
      if Calculate.condition_to_consider arr_element_contain_variable
        power_of_equation = Calculate.power_of_equation trigonometric_equation
        encode_element = Calculate.check_element_trigonometry arr_element_contain_variable
        if power_of_equation == 1
          if encode_element == "1000"
            return "bt11"
          end
          if encode_element == "0100"
            return "bt12"
          end
          if encode_element == "0010"
            return "bt13"
          end
          if encode_element == "0001"
            return "bt14"
          end
          if encode_element == "1100"
            return "bt31"
          end
        elsif power_of_equation == 2
          if encode_element == "1000"
            return "bt21"
          end
          if encode_element == "0100"
            return "bt22"
          end
          if encode_element == "0010"
            return "bt23"
          end
          if encode_element == "0001"
            return "bt24"
          end
          if encode_element == "1100"
            if self.check_bt4 trigonometric_equation
              return "bt41"
            end
            if self.check_bt5 trigonometric_equation
              return "bt51"
            end
          end
        end
      end
    end

    def get_coefficient_bt1 trigonometric_equation
      if trigonometric_equation.kind_of? Hash
        result = Array.new
        trigonometric_equation[:array_elements].each do |element|
          if element.kind_of? Hash
            if Calculate.have_variable_in_hash element
              if element[:array_elements].length == 2
                element[:array_elements].each do |child_element|
                  unless Calculate.have_variable? child_element
                    result[0] = child_element
                  end
                end
              else
                element[:array_elements].each do |child_element|
                  unless Calculate.have_variable? child_element
                    unless child_element == "-1"
                      result[0] = "-" + child_element
                    end
                  end
                end
              end
            else
              result[1] = "-" + element[:array_elements][1]
            end
          else
            if Calculate.have_variable? element
              result[0] = "1"
            else
              result[1] = element
            end
          end
        end
        return result
      else
        return ["1", "0"]
      end
    end

    def get_coefficient_bt2 trigonometric_equation, encode_element
      case encode_element
      when "1000"
        element_level_2 = { method: "^", array_elements: ["sin(x)", "2"] }
        element_level_1 = "sin(x)"
      when "0100"
        element_level_2 = { method: "^", array_elements: ["cos(x)", "2"] }
        element_level_1 = "cos(x)"
      when "0010"
        element_level_2 = { method: "^", array_elements: ["tan(x)", "2"] }
        element_level_1 = "tan(x)"
      when "0001"
        element_level_2 = { method: "^", array_elements: ["cotan(x)", "2"] }
        element_level_1 = "cotan(x)"
      end
      if trigonometric_equation.kind_of? Hash
        result = ["0", "0", "0"]
        trigonometric_equation[:array_elements].each do |element|
          if element.kind_of? Hash
            if element == element_level_2
              result[0] = "1"
            else
              if element[:array_elements].include? element_level_2
                if element[:array_elements].length == 2
                  element[:array_elements].each do |child_element|
                    unless child_element == element_level_2
                      result[0] = child_element
                    end
                  end
                else
                  element[:array_elements].each do |child_element|
                    if (child_element != element_level_2 && child_element != "-1")
                      result[0] = "-" + child_element
                    end
                  end
                end
              elsif element[:array_elements].include? element_level_1
                if element[:array_elements].length == 2
                  element[:array_elements].each do |child_element|
                    unless child_element == element_level_1
                      result[1] = child_element
                    end
                  end
                else
                  element[:array_elements].each do |child_element|
                    unless child_element == element_level_1
                      unless child_element == "-1"
                        result[1] = "-" + child_element
                      end
                    end
                  end
                end
              else
                result[2] = "-" + element[:array_elements][1]
              end
            end
          else
            if element == element_level_1
              result[1] = "1"
            else
              result[2] = element
            end
          end
        end
        return result
      end
    end

    def get_coefficient_bt3 trigonometric_equation
      result = ["0", "0", "0"]
      trigonometric_equation[:array_elements].each do |element|
        if element.kind_of? Hash
          if element[:array_elements].include? "sin(x)"
            if element[:array_elements].length == 2
              element[:array_elements].each do |child_element|
                unless child_element == "sin(x)"
                  result[0] = child_element
                end
              end
            else
              element[:array_elements].each do |child_element|
                if child_element != "sin(x)" && child_element != "-1"
                  result[0] = "-" + child_element
                end
              end
            end
          elsif element[:array_elements].include? "cos(x)"
            if element[:array_elements].length == 2
              element[:array_elements].each do |child_element|
                unless child_element == "cos(x)"
                  result[1] = child_element
                end
              end
            else
              element[:array_elements].each do |child_element|
                if child_element != "cos(x)" && child_element != "-1"
                  result[1] = "-" + child_element
                end
              end
            end
          else
            result[2] = "-" + element[:array_elements][1]
          end
        else
          if element == "sin(x)"
            result[0] = "1"
          elsif element == "cos(x)"
            result[1] = "1"
          else
            result[2] = element
          end
        end
      end
      return result
    end

    def check_bt4 trigonometric_equation
      trigonometric_equation[:array_elements].each do |element|
        unless Calculate.power_of_equation(trigonometric_equation) == 2
          return false
        end
      end
      return true
    end

    def get_coefficient_bt4 trigonometric_equation
      sin_level_2 = { method: "^", array_elements: ["sin(x)", "2"] }
      cos_level_2 = { method: "^", array_elements: ["cos(x)", "2"] }
      result = ["0", "0", "0"]
      trigonometric_equation[:array_elements].each do |element|
        if element[:method] == "^"
          if element == sin_level_2
            result[0] = "1"
          elsif element == cos_level_2
            result[2] = "1"
          end
        else
          if element[:array_elements].include? sin_level_2
            if element[:array_elements].length == 2
              element[:array_elements].each do |child_element|
                unless child_element == sin_level_2
                  result[0] = child_element
                end
              end
            else
              element[:array_elements].each do |child_element|
                if child_element != sin_level_2 && child_element != "-1"
                  result[0] = "-" + child_element
                end
              end
            end
          elsif element.include? cos_level_2
            if element[:array_elements].length == 2
              element[:array_elements].each do |child_element|
                unless child_element == cos_level_2
                  result[2] = child_element
                end
              end
            else
              element[:array_elements].each do |child_element|
                if child_element != cos_level_2 && child_element != "-1"
                  result[2] = "-" + child_element
                end
              end
            end
          else
            if element[:array_elements].length == 2
              result[1] = "1"
            elsif element[:array_elements].length == 3
              element[:array_elements].each do |child_element|
                if child_element != "sin(x)" && child_element != "cos(x)"
                  result[1] = child_element
                end
              end
            else
              element[:array_elements].each do |child_element|
                unless ["sin(x)", "cos(x)", "-1"].include? child_element
                  result[1] = "-" + child_element
                end
              end
            end
          end
        end
      end
      return result
    end

    def get_coefficient_bt5 trigonometric_equation
    end
  end
end
