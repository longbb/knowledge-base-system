class Calculate < ApplicationRecord
  class << self
    def power_of_equation equation
      if equation.kind_of? Hash
        if equation[:method] == "^"
          if Calculate.have_variable? equation[:array_elements][1]
            return 999
          else
            return self.power_of_equation(equation[:array_elements][0]) *
              equation[:array_elements][1].to_i
          end
        else
          arr_pow = Array.new
          equation[:array_elements].each do |element|
            arr_pow.push self.power_of_equation element
          end
          if equation[:method] == "+"
            return arr_pow.max
          else
            return arr_pow.sum
          end
        end
      else
        if Calculate.have_variable? equation
          return 1
        else
          return 0
        end
      end
    end

    def have_variable? element
      if element.include? "x"
        return true
      else
        return false
      end
    end

    def get_element_contain_variable encode_trigonometry
      arr_element_contain_variable = Array.new
      if encode_trigonometry.kind_of? Hash
        encode_trigonometry[:array_elements].each do |element|
          arr_element = get_element_contain_variable element
          arr_element.each do |variable_element|
            arr_element_contain_variable.push variable_element
          end
        end
      else
        if Calculate.have_variable? encode_trigonometry
          arr_element_contain_variable.push encode_trigonometry
        end
      end
      return arr_element_contain_variable
    end

    def check_element_trigonometry arr_element_contain_variable
      encode = "0000"
      if arr_element_contain_variable.include? "sin(x)"
        encode[0] = "1"
      end
      if arr_element_contain_variable.include? "cos(x)"
        encode[1] = "1"
      end
      if arr_element_contain_variable.include? "tan(x)"
        encode[2] = "1"
      end
      if arr_element_contain_variable.include? "cotan(x)"
        encode[3] = "1"
      end
      return encode
    end

    def condition_to_consider arr_element_contain_variable
      arr_element_contain_variable.each do |element|
        if element.include? ("(")
          if element.split("(")[1].split(")")[0] != "x"
            return false
          end
        else
          return false
        end
      end
      return true
    end

    def set_new_variable trigonometric_equation
      arr_element_contain_variable = self.get_element_contain_variable trigonometric_equation
      array_elements_in_parenthesis = Array.new
      arr_coefficient = Array.new
      arr_element_contain_variable.each do |element|
        element = element.split("(")[1].split(")")[0]
        array_elements_in_parenthesis.push element
        if element.include? ("{")
          arr_coefficient.push self.analys_simple_equation (eval(element))
        else
          arr_coefficient.push self.analys_simple_equation element
        end
      end
      min_element = arr_coefficient[0]
      min_index = 0
      arr_coefficient.each_index do |index|
        unless index == 0
          if self.min_element(arr_coefficient[index - 1], arr_coefficient[index]) == arr_coefficient[index]
            min_element = arr_coefficient[index]
            min_index = index
          end
        end
      end

      new_variable = array_elements_in_parenthesis[min_index]
      if new_variable == "x"
        return ({ new_variable: "x", new_equation: trigonometric_equation })
      else
        return ({
          new_variable: new_variable,
          new_equation: self.calculate_new_equation(trigonometric_equation, new_variable)
        })
      end
    end

    # a*x + b => ["a", "b"]
    def analys_simple_equation simple_equation
      if simple_equation.kind_of? Hash
        if simple_equation[:method] == "+"
          result = []
          simple_equation[:array_elements].each do |element|
            if element.kind_of? Hash
              if self.have_variable_in_hash element
                if element[:array_elements].length == 2
                  element[:array_elements].each do |child_element|
                    unless self.have_variable? child_element
                      result[0] = child_element
                    end
                  end
                else
                  element[:array_elements].each do |child_element|
                    unless self.have_variable? child_element
                      unless child_element == "-1"
                        result[0] = "-" + child_element
                      end
                    end
                  end
                end
              else
                element[:array_elements].each do |child_element|
                  unless child_element == "-1"
                    result[1] = "-" + child_element
                  end
                end
              end
            else
              if self.have_variable? element
                result[0] = "1"
              else
                result[1] = element
              end
            end
          end
          return result
        elsif simple_equation[:method] == "*"
          if simple_equation[:array_elements].length == 2
            simple_equation[:array_elements].each do |element|
              unless self.have_variable? element
                return [element,  "0"]
              end
            end
          else
            simple_equation[:array_elements].each do |element|
              unless self.have_variable? element
                unless element == "-1"
                  return ["-" + element,  "0"]
                end
              end
            end
          end
        end
      else
        if self.have_variable? simple_equation
          return ["1", "0"]
        else
          return ["0", simple_equation]
        end
      end
    end

    #["a", "b"] => a*x + b
    def recover_simple_equation arr_coefficient
      if arr_coefficient[0].to_f == 0
        return arr_coefficient[1]
      else
        if arr_coefficient[1].to_f == 0
          if arr_coefficient[0].to_f == 1
            return "x"
          else
            if arr_coefficient[0].to_f < 0
              return ({ method: "*", array_elements: ["-1", arr_coefficient[0].split("-")[1], "x"] })
            else
              return ({ method: "*", array_elements: [arr_coefficient[0], "x"] })
            end
          end
        else
          if arr_coefficient[1].to_f > 0
            if arr_coefficient[0].to_f == 1
              return ({ method: "+", array_elements: ["x", arr_coefficient[1]] })
            else
              if arr_coefficient[0].to_f > 0
                return ({
                  method: "+",
                  array_elements: [
                    {
                      method: "*",
                      array_elements: [arr_coefficient[0], "x"]
                    },
                    arr_coefficient[1]
                  ]
                })
              else
                return ({
                  method: "+",
                  array_elements: [
                    {
                      method: "*",
                      array_elements: ["-1", arr_coefficient[0].split("-")[1], "x"]
                    },
                    arr_coefficient[1]
                  ]
                })
              end
            end
          else
            if arr_coefficient[0].to_f == 1
              return ({ method: "+", array_elements: [
                "x",
                { method: "*", array_elements: ["-1", arr_coefficient[1].split("-")[1]] }] })
            else
              if arr_coefficient[0].to_f > 0
                return ({
                  method: "+",
                  array_elements: [
                    {
                      method: "*",
                      array_elements: [arr_coefficient[0], "x"]
                    },
                    { method: "*", array_elements: ["-1", arr_coefficient[1].split("-")[1]] }
                  ]
                })
              else
                return ({
                  method: "+",
                  array_elements: [
                    {
                      method: "*",
                      array_elements: ["-1", arr_coefficient[0].split("-")[1], "x"]
                    },
                    { method: "*", array_elements: ["-1", arr_coefficient[1].split("-")[1]] }
                  ]
                })
              end
            end
          end
        end
      end
    end

    def recover_old_element old_element, new_element
      new_element = self.analys_simple_equation new_element
      old_element = [old_element[0].to_f, old_element[1].to_f]
      new_element = [new_element[0].to_f, new_element[1].to_f]
      first_element = old_element[0] / new_element[0]
      second_element =  - (old_element[0] * new_element[1] / new_element[0]) + old_element[1]
      result = [first_element.to_s, second_element.to_s]
      return result
    end

    def calculate_final_result array_variable, result
      array_variable = [array_variable[0].to_f, array_variable[1].to_f]
      if result.include? "k"
        first_element = result.split(" + ")[0].to_f
        second_element = result.split(" + ")[1].split("k*")[1].to_f
        final_result_first = array_variable[0] * first_element + array_variable[1]
        final_result_second = array_variable[0] * second_element
        final_result = final_result_first.to_s + " + k*" + final_result_second.to_s
        return final_result
      else
        result = result.to_f
        final_result = array_variable[0] * result + array_variable[1]
        return final_result.to_s
      end
    end

    def min_element element1, element2
      if element1[0].to_f < element2[0].to_f
        return element1
      elsif element1[0].to_f > element2[0].to_f
        return element2
      elsif element1[1].to_f < element2[1].to_f
        return element1
      else
        return element2
      end
    end

    def calculate_new_equation trigonometric_equation, new_variable
      if new_variable.include?("{")
        new_variable = eval(new_variable)
      end
      coefficient = self.analys_simple_equation new_variable
      x = [eval("1/#{ coefficient[0].to_f }"), eval("-#{ coefficient[1] }/#{ coefficient[0].to_f }")]

      if trigonometric_equation.kind_of? Hash
        copy_trigonometric_equation = self.copy_hash_element trigonometric_equation
        copy_trigonometric_equation[:array_elements].each_index do |index|
          if copy_trigonometric_equation[:array_elements][index].kind_of? Hash
            new_element = self.calculate_new_equation copy_trigonometric_equation[:array_elements][index], new_variable
            copy_trigonometric_equation[:array_elements][index] = new_element
          else
            if Calculate.have_variable? copy_trigonometric_equation[:array_elements][index]
              element_in_parenthesis = copy_trigonometric_equation[:array_elements][index].split("(")[1].split(")")[0]
              if element_in_parenthesis.include?("{")
                element_in_parenthesis = eval(element_in_parenthesis)
              end
              element_coefficient = self.analys_simple_equation element_in_parenthesis
              new_element_coefficient = [
                (x[0] * element_coefficient[0].to_f).to_s,
                (x[1] * element_coefficient[0].to_f + element_coefficient[1].to_f).to_s
              ]
              new_element = (self.recover_simple_equation new_element_coefficient).to_s
              copy_trigonometric_equation[:array_elements][index] = copy_trigonometric_equation[:array_elements][index].split("(")[0] + "(" + new_element + ")"
            end
          end
        end
        return copy_trigonometric_equation
      else
        if Calculate.have_variable? trigonometric_equation
          return trigonometric_equation.split("(")[0] + "(x)"
        end
      end
    end

    def have_variable_in_hash hash
      have_variable = false
      hash[:array_elements].each do |element|
        if element.include? "x"
          have_variable = true
          break
        end
      end
      return have_variable
    end

    def copy_hash_element hash_element
      if hash_element.kind_of? Hash
        copy_hash_element = {
          method: hash_element[:method],
          array_elements: Array.new
        }
        hash_element[:array_elements].each do |element|
          if element.kind_of? Hash
            copy_hash_element[:array_elements].push(self.copy_hash_element element)
          else
            copy_hash_element[:array_elements].push(element)
          end
        end
        return copy_hash_element
      else
        return hash_element
      end
    end

    def mul_to_plus trigonometric_equation
      if trigonometric_equation.kind_of? Hash
        if trigonometric_equation[:method] == "*"
          array_index_plus = Array.new
          trigonometric_equation[:array_elements].each_index do |index|
            if trigonometric_equation[:array_elements][index].kind_of? Hash
              if trigonometric_equation[:array_elements][index][:method] == "+"
                array_index_plus.push index
              end
            end
          end
          if array_index_plus.length == 1
            plus_element = trigonometric_equation[:array_elements].delete_at array_index_plus[0]

            new_trigonometric_equation = {
              method: "+",
              array_elements: Array.new
            }

            plus_element[:array_elements].each do |element|
              new_element = {
                method: "*",
                array_elements: Array.new
              }
              trigonometric_equation[:array_elements].each do |trigonometric_equation_element|
                new_element[:array_elements].push trigonometric_equation_element
              end
              new_element[:array_elements].push element
              new_trigonometric_equation[:array_elements].push new_element
            end
            return Trigonometry.refactor_encode_hash new_trigonometric_equation
          else
            return trigonometric_equation
          end
        else
          trigonometric_equation[:array_elements].each_index do |index|
            trigonometric_equation[:array_elements][index] = self.mul_to_plus trigonometric_equation[:array_elements][index]
          end
          return Trigonometry.refactor_encode_hash trigonometric_equation
        end
      else
        return trigonometric_equation
      end
    end
  end
end
