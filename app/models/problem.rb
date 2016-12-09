class Problem < ApplicationRecord
  class << self
    def matching_problem_types trigonometric_equation
      arr_element_contain_variable = Calculate.get_element_contain_variable trigonometric_equation
      if Calculate.condition_to_consider arr_element_contain_variable
        power_of_equation = Calculate.power_of_equation trigonometric_equation
        encode_element = Calculate.check_element_trigonometry arr_element_contain_variable
        if power_of_equation == 1
          if encode_element == "1000"
            coefficients = self.get_coefficient_bt1 trigonometric_equation
            return ({ problem: "bt11", coefficients: coefficients })
          end
          if encode_element == "0100"
            coefficients = self.get_coefficient_bt1 trigonometric_equation
            return ({ problem: "bt12", coefficients: coefficients })
          end
          if encode_element == "0010"
            coefficients = self.get_coefficient_bt1 trigonometric_equation
            return ({ problem: "bt13", coefficients: coefficients })
          end
          if encode_element == "0001"
            coefficients = self.get_coefficient_bt1 trigonometric_equation
            return ({ problem: "bt14", coefficients: coefficients })
          end
          if encode_element == "1100"
            coefficients = self.get_coefficient_bt3 trigonometric_equation
            return ({ problem: "bt31", coefficients: coefficients })
          end
        elsif power_of_equation == 2
          if encode_element == "1000"
            coefficients = self.get_coefficient_bt2 trigonometric_equation, "1000"
            return ({ problem: "bt21", coefficients: coefficients })
          end
          if encode_element == "0100"
            coefficients = self.get_coefficient_bt2 trigonometric_equation, "0100"
            return ({ problem: "bt22", coefficients: coefficients })
          end
          if encode_element == "0010"
            coefficients = self.get_coefficient_bt2 trigonometric_equation, "0010"
            return ({ problem: "bt23", coefficients: coefficients })
          end
          if encode_element == "0001"
            coefficients = self.get_coefficient_bt2 trigonometric_equation, "0001"
            return ({ problem: "bt24", coefficients: coefficients })
          end
          if encode_element == "1100"
            if self.check_bt4 trigonometric_equation
              coefficients = self.get_coefficient_bt4 trigonometric_equation
              return ({ problem: "bt41", coefficients: coefficients })
            end
            if self.check_bt5 trigonometric_equation
              return self.check_bt5 trigonometric_equation
            end
          end
        end
      end
    end

    def get_coefficient_bt1 encode_hash
      trigonometric_equation = Calculate.copy_hash_element encode_hash
      trigonometric_equation = Calculate.mul_to_plus trigonometric_equation
      array_coefficient_1 = Array.new
      array_coefficient_2 = Array.new
      if trigonometric_equation.kind_of? Hash
        result = Array.new
        trigonometric_equation[:array_elements].each do |element|
          if element.kind_of? Hash
            if Calculate.have_variable_in_hash element
              if element[:array_elements].length == 2
                element[:array_elements].each do |child_element|
                  unless Calculate.have_variable? child_element
                    array_coefficient_1.push child_element
                  end
                end
              else
                element[:array_elements].each do |child_element|
                  unless Calculate.have_variable? child_element
                    unless child_element == "-1"
                      array_coefficient_1.push ("-" + child_element)
                    end
                  end
                end
              end
            else
              array_coefficient_2.push ("-" + element[:array_elements][1])
            end
          else
            if Calculate.have_variable? element
              array_coefficient_1.push "1"
            else
              array_coefficient_2.push element
            end
          end
        end
        result[0] = self.sum_coefficient array_coefficient_1
        result[1] = self.sum_coefficient array_coefficient_2
        return result
      else
        return ["1", "0"]
      end
    end

    def get_coefficient_bt2 encode_hash, encode_element
      trigonometric_equation = Calculate.copy_hash_element encode_hash
      trigonometric_equation = Calculate.mul_to_plus trigonometric_equation
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
      array_coefficient_1 = Array.new
      array_coefficient_2 = Array.new
      array_coefficient_3 = Array.new
      if trigonometric_equation.kind_of? Hash
        result = ["0", "0", "0"]
        trigonometric_equation[:array_elements].each do |element|
          if element.kind_of? Hash
            if element == element_level_2
              array_coefficient_1.push "1"
            else
              if element[:array_elements].include? element_level_2
                if element[:array_elements].length == 2
                  element[:array_elements].each do |child_element|
                    unless child_element == element_level_2
                      array_coefficient_1.push child_element
                    end
                  end
                else
                  element[:array_elements].each do |child_element|
                    if (child_element != element_level_2 && child_element != "-1")
                      array_coefficient_1.push("-" + child_element)
                    end
                  end
                end
              elsif element[:array_elements].include? element_level_1
                if element[:array_elements].length == 2
                  element[:array_elements].each do |child_element|
                    unless child_element == element_level_1
                      array_coefficient_2.push child_element
                    end
                  end
                else
                  element[:array_elements].each do |child_element|
                    unless child_element == element_level_1
                      unless child_element == "-1"
                        array_coefficient_2.push("-" + child_element)
                      end
                    end
                  end
                end
              else
                array_coefficient_3.push("-" + element[:array_elements][1])
              end
            end
          else
            if element == element_level_1
              array_coefficient_2.push "1"
            else
              array_coefficient_3.push element
            end
          end
        end
        result[0] = self.sum_coefficient array_coefficient_1
        result[1] = self.sum_coefficient array_coefficient_2
        result[2] = self.sum_coefficient array_coefficient_3
        return result
      end
    end

    def get_coefficient_bt3 encode_hash
      trigonometric_equation = Calculate.copy_hash_element encode_hash
      trigonometric_equation = Calculate.mul_to_plus trigonometric_equation
      array_coefficient_1 = Array.new
      array_coefficient_2 = Array.new
      array_coefficient_3 = Array.new
      result = ["0", "0", "0"]
      trigonometric_equation[:array_elements].each do |element|
        if element.kind_of? Hash
          if element[:array_elements].include? "sin(x)"
            if element[:array_elements].length == 2
              element[:array_elements].each do |child_element|
                unless child_element == "sin(x)"
                  array_coefficient_1.push child_element
                end
              end
            else
              element[:array_elements].each do |child_element|
                if child_element != "sin(x)" && child_element != "-1"
                  array_coefficient_1.push("-" + child_element)
                end
              end
            end
          elsif element[:array_elements].include? "cos(x)"
            if element[:array_elements].length == 2
              element[:array_elements].each do |child_element|
                unless child_element == "cos(x)"
                  array_coefficient_2.push child_element
                end
              end
            else
              element[:array_elements].each do |child_element|
                if child_element != "cos(x)" && child_element != "-1"
                  array_coefficient_2.push("-" + child_element)
                end
              end
            end
          else
            array_coefficient_3.push("-" + element[:array_elements][1])
          end
        else
          if element == "sin(x)"
            array_coefficient_1.push "1"
          elsif element == "cos(x)"
            array_coefficient_2.push "1"
          else
            array_coefficient_3.push element
          end
        end
      end
      result[0] = self.sum_coefficient array_coefficient_1
      result[1] = self.sum_coefficient array_coefficient_2
      result[2] = self.sum_coefficient array_coefficient_3
      return result
    end

    def check_bt4 trigonometric_equation
      trigonometric_equation[:array_elements].each do |element|
        unless Calculate.power_of_equation(element) == 2
          return false
        end
      end
      return true
    end

    def get_coefficient_bt4 encode_hash
      trigonometric_equation = Calculate.copy_hash_element encode_hash
      trigonometric_equation = Calculate.mul_to_plus trigonometric_equation
      sin_level_2 = { method: "^", array_elements: ["sin(x)", "2"] }
      cos_level_2 = { method: "^", array_elements: ["cos(x)", "2"] }
      array_coefficient_1 = Array.new
      array_coefficient_2 = Array.new
      array_coefficient_3 = Array.new
      result = ["0", "0", "0"]
      trigonometric_equation[:array_elements].each do |element|
        if element[:method] == "^"
          if element == sin_level_2
            array_coefficient_1.push "1"
          elsif element == cos_level_2
            array_coefficient_3.push "1"
          end
        else
          if element[:array_elements].include? sin_level_2
            if element[:array_elements].length == 2
              element[:array_elements].each do |child_element|
                unless child_element == sin_level_2
                  array_coefficient_1.push child_element
                end
              end
            else
              element[:array_elements].each do |child_element|
                if child_element != sin_level_2 && child_element != "-1"
                  array_coefficient_1.push("-" + child_element)
                end
              end
            end
          elsif element[:array_elements].include? cos_level_2
            if element[:array_elements].length == 2
              element[:array_elements].each do |child_element|
                unless child_element == cos_level_2
                  array_coefficient_3.push child_element
                end
              end
            else
              element[:array_elements].each do |child_element|
                if child_element != cos_level_2 && child_element != "-1"
                  array_coefficient_3.push("-" + child_element)
                end
              end
            end
          else
            if element[:array_elements].length == 2
              array_coefficient_2.push "1"
            elsif element[:array_elements].length == 3
              element[:array_elements].each do |child_element|
                if child_element != "sin(x)" && child_element != "cos(x)"
                  array_coefficient_2.push child_element
                end
              end
            else
              element[:array_elements].each do |child_element|
                unless ["sin(x)", "cos(x)", "-1"].include? child_element
                  array_coefficient_2.push("-" + child_element)
                end
              end
            end
          end
        end
      end
      result[0] = self.sum_coefficient array_coefficient_1
      result[1] = self.sum_coefficient array_coefficient_2
      result[2] = self.sum_coefficient array_coefficient_3
      return result
    end

    def check_bt5 encode_hash
      trigonometric_equation = Calculate.copy_hash_element encode_hash
      trigonometric_equation = Calculate.mul_to_plus trigonometric_equation
      coefficient_sin = self.check_have_element(trigonometric_equation, "sin(x)")
      coefficient_cos = self.check_have_element(trigonometric_equation, "cos(x)")
      coefficient_sin_level_2 = self.check_have_element(trigonometric_equation, { method: "^", array_elements: ["sin(x)", "2"] })
      coefficient_cos_level_2 = self.check_have_element(trigonometric_equation, { method: "^", array_elements: ["cos(x)", "2"] })
      coefficient_sin_mul_cos = self.check_have_sin_mul_cos trigonometric_equation
      coefficient_constant = self.get_coefficient_constant trigonometric_equation
      if coefficient_sin_level_2 || coefficient_cos_level_2
        return false
      else
        if coefficient_sin && coefficient_cos && coefficient_sin_mul_cos
          if coefficient_sin == coefficient_cos
            return ({ problem: "bt51", coefficients: [coefficient_sin, coefficient_sin_mul_cos, coefficient_constant] })
          elsif coefficient_sin.to_f == -(coefficient_cos.to_f)
            return ({ problem: "bt51", coefficients: [coefficient_sin, coefficient_sin_mul_cos, coefficient_constant] })
          else
            return false
          end
        else
          return false
        end
      end
    end

    def check_have_element trigonometric_equation, need_check_element
      array_coefficient_need_check = Array.new
      trigonometric_equation[:array_elements].each do |element|
        if element.kind_of? Hash
          if element == need_check_element
            array_coefficient_need_check.push "1"
          else
            if element[:array_elements].include? need_check_element
              if element[:array_elements].length == 2
                element[:array_elements].each do |child_element|
                  unless child_element == need_check_element
                    array_coefficient_need_check.push child_element
                  end
                end
              else
                element[:array_elements].each do |child_element|
                  if (child_element != need_check_element) && (child_element != "-1")
                    array_coefficient_need_check.push("-" + child_element)
                  end
                end
              end
            end
          end
        else
          if element == need_check_element
            array_coefficient_need_check.push "1"
          end
        end
      end
      if array_coefficient_need_check.empty?
        return false
      else
        return self.sum_coefficient array_coefficient_need_check
      end
    end

    def get_coefficient_constant trigonometric_equation
      array_coefficient_constant = Array.new
      trigonometric_equation[:array_elements].each do |element|
        constant = self.is_constant element
        if constant
          array_coefficient_constant.push constant
        end
      end
      return self.sum_coefficient array_coefficient_constant
    end

    def check_have_sin_mul_cos trigonometric_equation
      array_coefficient_need_check = Array.new
      trigonometric_equation[:array_elements].each do |element|
        if element == ({ method: "*", array_elements: ["sin(x)", "cos(x)"] })
          array_coefficient_need_check.push"1"
        else
          if element.kind_of? Hash
            if element[:method] == "*"
              if element[:array_elements].include?("sin(x)") && element[:array_elements].include?("cos(x)")
                if element[:array_elements].length == 3
                  element[:array_elements].each do |child_element|
                    if (child_element != "sin(x)") && (child_element != "cos(x)")
                      if self.is_constant child_element
                        array_coefficient_need_check.push child_element
                      end
                    end
                  end
                else
                  if (element[:array_elements].length == 4) && (element[:array_elements].include? "-1")
                    element[:array_elements].each do |child_element|
                      if (child_element != "sin(x)") && (child_element != "cos(x)") && (child_element != "-1")
                        if self.is_constant child_element
                          array_coefficient_need_check.push("-" + child_element)
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
      if array_coefficient_need_check.empty?
        return false
      else
        return self.sum_coefficient array_coefficient_need_check
      end
    end

    def is_constant element
      if element.kind_of? Hash
        if element[:array_elements][0] == "-1"
          if !(element[:array_elements][1].kind_of? Hash)
            if !(Calculate.have_variable? element[:array_elements][1])
              return "-" + element[:array_elements][1]
            end
          end
        end
      else
        if !(Calculate.have_variable? element)
          return element
        end
      end
      return false
    end

    def sum_coefficient array_coefficient
      if array_coefficient.empty?
        return "0"
      else
        if array_coefficient.length == 1
          return array_coefficient[0]
        else
          return eval(array_coefficient.join("+")).to_s
        end
      end
    end
  end
end
