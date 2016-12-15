class Problem < ApplicationRecord
  class << self
    def solve_equation trigonometric_equation
      @solution = nil
      @new_variable = [["1", "0"]]
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
            new_variable = new_trigonometric_equation[:new_variable]
            if new_trigonometric_equation[:new_variable].include? "{"
              new_variable = eval(new_trigonometric_equation[:new_variable])
            end
            @new_variable.push Calculate.recover_old_element @new_variable.last, new_variable
            new_variable = Trigonometry.convert_normal_type new_variable
            if new_trigonometric_equation[:new_equation].kind_of? Hash
              array_steps.push({ message: "Đặt x = #{ new_variable }", equation: new_trigonometric_equation[:new_equation] })
            else
              array_steps.push({ message: "Đặt x = #{ new_variable }", equation: new_trigonometric_equation[:new_equation] + " = 0" })
            end
          end
          if Problem.matching_problem_types new_trigonometric_equation[:new_equation]
            problem_types = Problem.matching_problem_types new_trigonometric_equation[:new_equation]
            solve_equation = Problem.solve_problem(problem_types[:problem], problem_types[:coefficients])
            solve_equation.each do |step|
              array_steps.push step
            end
            @solution = { array_steps: array_steps, problem_type: problem_types }
            return @solution
          else
            children = Rule.generate_children new_trigonometric_equation[:new_equation]
            if children.empty?
              return false
              if set_new_variable
                array_steps.pop()
                @new_variable.pop()
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
                  @new_variable.pop()
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
                    @new_variable.pop()
                  end
                  return false
                end
              end
            end
          end
        end
      end
      solve_trigonometric_equation trigonometric_equation, [], 0
      if @new_variable.last != ["1", "0"]
        equation = Array.new()
        @solution[:array_steps].last[:equation].each do |result|
          equation.push Calculate.calculate_final_result @new_variable.last, result
        end
        @solution[:array_steps].push ({ message: "Mà ta đã đặt ẩn phụ cho x,  khôi phục kết quả cuối cùng ta được: ", equation: equation })
      end
      return @solution
    end

    def matching_problem_types trigonometric_equation
      arr_element_contain_variable = Calculate.get_element_contain_variable trigonometric_equation
      if trigonometric_equation.kind_of? Hash
        if trigonometric_equation[:method] == "*"
          return ({ problem: "bt0", coefficients: trigonometric_equation })
        end
      end
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
          unless self.is_constant element
            return false
          end
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
      result = ["0", "0", "0", "0"]
      trigonometric_equation[:array_elements].each do |element|
        if element.kind_of? Hash
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
              unless self.is_constant element
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
        end
      end
      result[0] = self.sum_coefficient array_coefficient_1
      result[1] = self.sum_coefficient array_coefficient_2
      result[2] = self.sum_coefficient array_coefficient_3
      result[3] = self.get_coefficient_constant trigonometric_equation
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
          if self.check_only_element(element, need_check_element)
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

    def check_only_element trigonometric_equation, need_check_element
      if trigonometric_equation.kind_of? Hash
        if trigonometric_equation[:array_elements].include? need_check_element
          trigonometric_equation[:array_elements].each do |element|
            if (element != need_check_element) && (!self.is_constant element)
              return false
            end
          end
          return true
        else
          return false
        end
      else
        if trigonometric_equation == need_check_element
          return true
        else
          return false
        end
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

    def solve_problem type, coefficients
      if type == "bt0"
        Problem.solve_problem_bt0 coefficients
      else
        parameters = Array.new
        coefficients.each do |coefficient|
          parameters.push coefficient.to_f
        end

        case type
        when "bt11"
          Problem.solve_problem_bt11 parameters
        when "bt12"
          Problem.solve_problem_bt12 parameters
        when "bt13"
          Problem.solve_problem_bt13 parameters
        when "bt14"
          Problem.solve_problem_bt14 parameters
        when "bt21"
          Problem.solve_problem_bt21 parameters
        when "bt22"
          Problem.solve_problem_bt22 parameters
        when "bt23"
          Problem.solve_problem_bt23 parameters
        when "bt24"
          Problem.solve_problem_bt24 parameters
        when "bt31"
          Problem.solve_problem_bt31 parameters
        when "bt41"
          Problem.solve_problem_bt41 parameters
        when "bt51"
          Problem.solve_problem_bt51 parameters
        when "bt52"
          Problem.solve_problem_bt52 parameters
        end
      end
    end

    def have_variable element
      if element.kind_of? Hash
        return Calculate.have_variable_in_hash element
      else
        return Calculate.have_variable? element
      end
    end

    #bt0: a * b = 0
    def solve_problem_bt0 trigonometric_equation
      result = Array.new
      trigonometric_equation[:array_elements].each do |element|
        if self.have_variable element
          result.push({ message: "Xét phương trình", equation: Trigonometry.decode_equation(element) })
          child_result = self.solve_equation element
          child_result[:array_steps].each do |step|
            result.push step
          end
        end
      end
      if result.empty?
        result.push({ message: "Phương trình vô nghiệm", equation: [] })
      end
      return result
    end

    # bt11: a*sin(x) + b = 0
    def solve_problem_bt11 parameters
      result = Array.new
      a = parameters[0]
      b = parameters[1]
      m = (-1)*b/a
      if (m > 1) || (m < -1)
        message = { message: "Phương trình vô nghiệm", equation: [] }
      else
        equation = Math.asin(m) * 180 / Math::PI
        if (equation == 90)
          message = { message: "Phương trình có nghiệm", equation: [equation.floor.to_s + " + k*360"] }
        else
          message = { message: "Phương trình có nghiệm", equation: [equation.floor.to_s + " + k*360", (180-equation.floor).to_s + " + k*360"] }
        end
      end
      result.push(message)
      return result
    end

    # bt12: a*cos(x) + b = 0
    def solve_problem_bt12 parameters
      result = Array.new
      a = parameters[0]
      b = parameters[1]
      m = (-1)*b/a
      if (m > 1) || (m < -1)
        message = { message: "Phương trình vô nghiệm", equation: [] }
      else
        equation = Math.acos(m) * 180 / Math::PI
        if (equation == 0 || equation == 180)
          message = { message: "Phương trình có nghiệm", equation: [equation.floor.to_s + " + k*360"] }
        else
          message = { message: "Phương trình có nghiệm", equation: [equation.floor.to_s + " + k*360", (-1 *equation.floor).to_s + " + k*360"] }
        end
      end
      result.push(message)
      return result
    end

    # bt13: a*tan(x) + b = 0
    def solve_problem_bt13 parameters
      result = Array.new
      a = parameters[0]
      b = parameters[1]
      m = (-1)*b/a
      result.push({ message: "Điều kiện:", equation: "x != 90 + k*180" })
      equation = Math.atan(m) * 180 / Math::PI
      result.push({ message: "Phương trình có nghiệm", equation: [equation.floor.to_s + " + k*180"] })
      return result
    end

    # bt14: a*cotan(x) + b = 0
    def solve_problem_bt14 parameters
      result = Array.new
      a = parameters[0]
      b = parameters[1]
      m = (-1)*b/a
      result.push({ message: "Điều kiện:", equation: "x != k*180" })
      equation =  Math.atan(1/m) * 180 / Math::PI
      result.push({ message: "Phương trình có nghiệm", equation: [equation.floor.to_s + " + k*180"] })
      return result
    end

    # a*t^2 + b*t + c = 0
    def solve_equation_level_2 parameters
      result = Array.new
      a = parameters[0]
      b = parameters[1]
      c = parameters[2]
      if a == 0
        if b == 0
          if c == 0
            result.push({ message: "Phương trình vô số nghiệm", equation: [] })
          else
            result.push({ message: "Phương trình vô nghiệm", equation: [] })
          end
        else
          result.push({ message: "Phương trình có 1 nghiệm", equation: [- c / b] })
        end
      else
        delta = b ** 2 - 4*a*c
        if delta > 0
          x1 = -(b + Math.sqrt(delta)) / (2*a)
          x2 = -(b - Math.sqrt(delta)) / (2*a)
          message = { message: "Phương trình có 2 nghiệm", equation: [x1, x2] }
        elsif delta == 0
          x = -b/(2*a)
          message = { message: "Phương trình có 1 nghiệm", equation: [x] }
        else
          message = { message: "Phương trình vô nghiệm", equation: [] }
        end
        result.push(message)
      end
      return result
    end

    # bt21: a * sin(x) ^ 2 + b * sin(x) + c = 0
    def solve_problem_bt21 parameters
      result = Array.new
      a = parameters[0]
      b = parameters[1]
      c = parameters[2]
      new_problem = a.to_s + "*t^[2] + " + b.to_s + "*t + " + c.to_s + "= 0"
      result.push({ message: "Đặt sin(x) = t ta có: ", equation: new_problem })
      array_equation = Problem.solve_equation_level_2 parameters
      step2 = { message: "Giải phương trình trên ta có: ", equation: array_equation[0][:equation] }
      result.push(step2)
      if array_equation[0][:equation].length != 0
        arr_x = Array.new
        array_equation[0][:equation].each do |equation|
          step3 = { message: "Trả về biến cũ ta có: ", equation: "sin(x) = " + equation.to_s }
          result.push(step3)
          step4 = Problem.solve_problem_bt11 [1, -equation]
          step4[step4.length-1][:equation].each do |x|
            arr_x.push(x)
          end
          step4.each do |step|
            result.push(step)
          end
        end
        result.push({ message: "Phương trình ban đầu có nghiệm ", equation: arr_x })
      else
        result.push({ message: "Phương trình ban đầu vô nghiệm ", equation: [] })
      end
      return result
    end

    # bt22: a * cos(x) ^ 2 + b * cos(x) + c = 0
    def solve_problem_bt22 parameters
      result = Array.new
      a = parameters[0]
      b = parameters[1]
      c = parameters[2]
      new_problem = a.to_s + "*t^[2] + " + b.to_s + "*t + " + c.to_s + "= 0"
      result.push({ message: "Đặt cos(x) = t ta có", equation: new_problem })
      array_equation = Problem.solve_equation_level_2 parameters
      step2 = { message: "Giải phương trình trên ta có: ", equation: array_equation[0][:equation] }
      result.push(step2)
      if array_equation[0][:equation].length != 0
        arr_x = Array.new
        array_equation[0][:equation].each do |equation|
          step3 = { message: "Trả về biến cũ ta có: ", equation: "cos(x) = " + equation.to_s }
          result.push(step3)
          step4 = Problem.solve_problem_bt12 [1, -equation]
          step4[step4.length-1][:equation].each do |x|
            arr_x.push(x)
          end
          step4.each do |step|
            result.push(step)
          end
        end
        result.push({ message: "Phương trình ban đầu có nghiệm ", equation: arr_x })
      else
        result.push({ message: "Phương trình ban đầu vô nghiệm ", equation: [] })
      end
      return result
    end

    # bt23: a * tan(x) ^ 2 + b * tan(x) + c = 0
    def solve_problem_bt23 parameters
      result = Array.new
      a = parameters[0]
      b = parameters[1]
      c = parameters[2]
      new_problem = a.to_s + "*t^[2] + " + b.to_s + "*t + " + c.to_s + "= 0"
      result.push({ message: "Đặt tan(x) = t ta có", equation: new_problem })
      array_equation = Problem.solve_equation_level_2 parameters
      step2 = { message: "Giải phương trình trên ta có: ", equation: array_equation[0][:equation] }
      result.push(step2)
      if array_equation[0][:equation].length != 0
        arr_x = Array.new
        array_equation[0][:equation].each do |equation|
          step3 = { message: "Trả về biến cũ ta có: ", equation: "tan(x) = " + equation.to_s }
          result.push(step3)
          step4 = Problem.solve_problem_bt13 [1, -equation]
          step4[step4.length-1][:equation].each do |x|
            arr_x.push(x)
          end
          step4.each do |step|
            result.push(step)
          end
        end
        result.push({ message: "Phương trình ban đầu có nghiệm ", equation: arr_x })
      else
        result.push({ message: "Phương trình ban đầu vô nghiệm ", equation: [] })
      end
      return result
    end

    # bt24: a * cotan(x) ^ 2 + b * cotan(x) + c = 0
    def solve_problem_bt24 parameters
      result = Array.new
      a = parameters[0]
      b = parameters[1]
      c = parameters[2]
      new_problem = a.to_s + "*t^[2] + " + b.to_s + "*t + " + c.to_s + "= 0"
      result.push({ message: "Đặt cotan(x) = t ta có", equation: new_problem })
      array_equation = Problem.solve_equation_level_2 parameters
      step2 = { message: "Giải phương trình trên ta có: ", equation: array_equation[0][:equation] }
      result.push(step2)
      if array_equation[0][:equation].length != 0
        arr_x = Array.new
        array_equation[0][:equation].each do |equation|
          step3 = { message: "Trả về biến cũ ta có: ", equation: "cotan(x) = " + equation.to_s }
          result.push(step3)
          step4 = Problem.solve_problem_bt14 [1, -equation]
          step4[step4.length-1][:equation].each do |x|
            arr_x.push(x)
          end
          step4.each do |step|
            result.push(step)
          end
        end
        result.push({ message: "Phương trình ban đầu có nghiệm ", equation: arr_x })
      else
        result.push({ message: "Phương trình ban đầu vô nghiệm ", equation: [] })
      end
      return result
    end

    #bt31: a*sin(x) + b*cos(x) + c = 0
    def solve_problem_bt31 parameters
      result = Array.new
      a = parameters[0]
      b = parameters[1]
      c = parameters[2]
      arr_x = Array.new
      if a * Math.sqrt(1 - Math.cos(Math::PI) ** 2) + b * Math.cos(Math::PI) + c != 0
        step1 = {
          message: "Với cos(x/2) = 0 <=> x = 180 + k*360, ta có: ",
          equation: "Phương trình vô nghiệm"
        }
      else
        step1 = {
          message: "Với cos(x/2) = 0 <=> x = 180 + k*360, ta có: ",
          equation: "Phương trình thỏa mãn"
        }
        arr_x.push("180 + k*360")
      end
      result.push(step1)
      result.push({
        message: "Với cos(x/2) != 0 <=> x != 180 + k*360, Đặt t = tan(x/2), suy ra: \n" +
          "sin(x) = 2*t/(1 + t^2), cos(x) = (1 - t^2)/(1 + t^2). \n Khi đó phương trình ban đầu có dạng: ",
        equation: a.to_s + "*2*t/(1 + t^2) + " + b.to_s + "*(1 - t^2)/(1 + t^2)" + c.to_s + " = 0"
      })
      first_element = -1 * c + b
      second_element = - 2 * a
      third_element = -1 * c - b
      result.push({
        message: "Tương đương",
        equation: first_element.to_s + "* t^2 + " + second_element.to_s + "*t + " + third_element.to_s + "= 0"
      })
      array_equation = Problem.solve_equation_level_2 [first_element, second_element, third_element]
      step2 = { message: "Giải phương trình trên ta có: ", equation: array_equation[0][:equation] }
      result.push(step2)
      if array_equation[0][:equation].length != 0

        array_equation[0][:equation].each do |equation|
          step3 = { message: "Trả về biến cũ ta có: ", equation: "tan(x/2) = " + equation.to_s }
          result.push(step3)
          step4 = Problem.solve_problem_bt13 [1, -equation]
          x = step4[1][:equation][0].split(" + ")[0].to_i * 2
          if x == 180
            result.push({ message: "Loại vì x != 180 + k*360 => Phương trình vô nghiệm", equation: [] })
          else
            arr_x.push(x.to_s + " + k*360")
          end
        end
        step5 = {
          message: "Phương trình có nghiệm",
          equation: arr_x
        }
        result.push(step5)
      else
        result.push({ message: "Phương trình ban đầu vô nghiệm", equation: [] })
      end
      return result
    end

    # bt41: a* sin(x)^2 + b*sin(x)*cos(x) + c * cos(x)^2 + d = 0
    def solve_problem_bt41 parameters
      result = Array.new
      a = parameters[0]
      b = parameters[1]
      c = parameters[2]
      d = parameters[3]
      first_element = b
      second_element = c - a
      third_element = -2 * d - c -a
      result.push({
        message: "Sử dụng sin(x)^2 = (1 - cos(2*x))/2, cos(x)^2 = (1 + cos(2*x))/2, sin2x = 2 * sin(x) * cos(x) ta được: ",
        equation: first_element.to_s + "*sin(2*x) + " + second_element.to_s + "*cos(2*x) = " + third_element.to_s + " (1)"
      })
      result.push({
        message: "Đặt 2*x = t ta có: ",
        equation: first_element.to_s + "*sin(t) + " + second_element.to_s + "*cos(t) = " + third_element.to_s + " (2)"
      })
      array_steps = Problem.solve_problem_bt31 [first_element, second_element, - third_element]
      array_steps.each do |step|
        result.push(step)
      end
      if array_steps[array_steps.length - 1][:equation].length == 0
        result.push({
          message: "Phương trình (1) vô nghiệm",
          equation: []
        })
      else
        arr_x = Array.new
        array_steps[array_steps.length - 1][:equation].each do |equation|
          value = equation.split(" + ")[0].to_i
          result.push({
            message: "Trả về biến cũ phương trình (1) ta có: ",
            equation: "2*x = " + equation.to_s
          })
          arr_x.push((value/2).to_s + "+ k*180")
        end
        result.push({
          message: "Phương trình (1) có nghiệm: ",
          equation: arr_x
        })
      end
      return result
    end

    #bt51: a*(sin(x) + cos(x)) + b* sin(x) * cos(x) + c = 0
    def solve_problem_bt51 parameters
      result = Array.new
      a = parameters[0]
      b = parameters[1]
      c = parameters[2]
      first_element = b
      second_element = 2 * a
      third_element = 2 * c - b
      result.push({
        message: "Đặt sin(x) + cos(x) = t, điều kiện |t| <= sqrt(2) suy ra sin(x)*cos(x) = (t^2 -1)/2.\n " +
          "Khi đó phương trình ban đầu có dạng: ",
        equation: a.to_s + "*t + " + b.to_s + "*(t^2 -1)/2 + " + c.to_s + " = 0"
      })
      result.push({
        message: "Tương đương",
        equation: first_element.to_s + "*t^2 + " + second_element.to_s + "*t + " + third_element.to_s + " = 0"
      })
      array_equation = Problem.solve_equation_level_2 [first_element, second_element, third_element]
      step2 = { message: "Giải phương trình trên ta có: ", equation: array_equation[0][:equation] }
      result.push(step2)
      if array_equation[0][:equation].length != 0
        arr_x = Array.new
        array_equation[0][:equation].each do |equation|
          step3 = { message: "Trả về biến cũ ta có: ", equation: "sin(x) + cos(x) = " + equation.to_s }
          result.push(step3)
          if (equation <= Math.sqrt(2)) && (equation >= (-1)*Math.sqrt(2))
            step = Problem.solve_problem_bt31 [1, 1, (-1)*equation]
            step.each do |child_step|
              result.push(child_step)
            end
            if step[step.length - 1][:equation].length != 0
              step[step.length - 1][:equation].each do |equation|
                value = equation.split(" + ")[0].to_i
                arr_x.push(value.to_s + "+ k*360")
              end
            end
          else
            result.push({
              message: "Loại nghiệm này do không thỏa mãn điều kiện |t| <= sqrt(2)",
              equation: []
            })
          end
        end
        step5 = {
          message: "Vậy Phương trình có nghiệm",
          equation: arr_x
        }
        result.push(step5)
      else
        result.push({ message: "Phương trình ban đầu vô nghiệm", equation: [] })
      end
      return result
    end

    #bt52: a*(sin(x) - cos(x)) + b* sin(x) * cos(x) + c = 0
    def solve_problem_bt52 parameters
      result = Array.new
      a = parameters[0]
      b = parameters[1]
      c = parameters[2]
      result.push({
        message: "Đặt sin(x) - cos(x) = t, điều kiện |t| <= sqrt(2) suy ra sin(x)*cos(x) = (1 - t^2)/2.\n " +
          "Khi đó phương trình ban đầu có dạng: ",
        equation: a.to_s + "*t + " + b.to_s + "*(1 - t^2)/2 + " + c.to_s + " = 0"
      })
      result.push({
        message: "<=>",
        equation: b.to_s + "*t^2 - 2*" + a.to_s + "*t - 2*" + c.to_s + " - " + b.to_s + " = 0"
      })
      array_equation = Problem.solve_equation_level_2 [b, 2*a, 2*c-b]
      step2 = { message: "Giải phương trình trên ta có: ", equation: array_equation[0][:equation] }
      result.push(step2)
      if array_equation[0][:equation].length != 0
        arr_x = Array.new
        array_equation[0][:equation].each do |equation|
          step3 = { message: "Trả về biến cũ ta có: ", equation: "sin(x) - cos(x) = " + equation.to_s }
          result.push(step3)
          if (equation <= Math.sqrt(2)) && (equation >= (-1)*Math.sqrt(2))
            step = Problem.solve_problem_bt31 [1, 1, (-1)*equation]
            result.push(step)
            if step[step.length - 1][:equation].length != 0
              step[step.length - 1][:equation].each do |equation|
                value = equation.split(" + ")[0].to_i
                arr_x.push(value.to_s + "+ k*360")
              end
            end
          else
            result.push({
              message: "Loại nghiệm này do không thỏa mãn điều kiện |t| <= sqrt(2)",
              equation: []
            })
          end
        end
        step5 = {
          message: "Vậy Phương trình có nghiệm",
          equation: arr_x
        }
        result.push(step5)
      else
        result.push({ message: "Phương trình ban đầu vô nghiệm", equation: [] })
      end
      return result
    end
  end
end
