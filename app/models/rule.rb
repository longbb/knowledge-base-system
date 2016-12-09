class Rule < ApplicationRecord
  class << self
    def generate_children trigonometric_equation
      final_result = Array.new
      (1..12).each do |index|
        rule = "rule" + index.to_s
        rule_result = enforcement_rule rule, trigonometric_equation
        unless rule_result.empty?
          name_of_rule = self.name_of_rule rule
          rule_result.each do |result|
            final_result.push({ message: name_of_rule, equation: result})
          end
        end
      end
      return final_result
    end

    def enforcement_rule rule, trigonometric_equation
      case rule
      when "rule1"
        self.rule1 trigonometric_equation
      when "rule2"
        self.rule2 trigonometric_equation
      when "rule3"
        self.rule3 trigonometric_equation
      when "rule4"
        self.rule4 trigonometric_equation
      when "rule5"
        self.rule5 trigonometric_equation
      when "rule6"
        self.rule6 trigonometric_equation
      when "rule7"
        self.rule7 trigonometric_equation
      when "rule8"
        self.rule8 trigonometric_equation
      when "rule9"
        self.rule9 trigonometric_equation
      when "rule10"
        self.rule10 trigonometric_equation
      when "rule11"
        self.rule11 trigonometric_equation
      when "rule12"
        self.rule12 trigonometric_equation
      end
    end

    #cos(x+y)
    def rule1 trigonometric_equation
      final_result = Array.new
      if trigonometric_equation.kind_of? Hash
        trigonometric_equation[:array_elements].each_index do |index|
          arr_result = self.rule1 trigonometric_equation[:array_elements][index]
            unless arr_result.empty?
            arr_result.each do |result|
              copy_trigonometric_equation = Calculate.copy_hash_element trigonometric_equation
              copy_trigonometric_equation[:array_elements][index] = result
              final_result.push(Trigonometry.refactor_encode_hash copy_trigonometric_equation)
            end
          end
        end
        return final_result
      else
        if trigonometric_equation.include? "cos"
          element_in_parentheses = trigonometric_equation.split("(")[1].split(")")[0]
          if element_in_parentheses.include? ("{")
            element_in_parentheses = eval(element_in_parentheses)
            if element_in_parentheses[:method] == "+" && element_in_parentheses[:array_elements].length == 2
              final_result.push({
                method: "+",
                array_elements: [
                  {
                    method: "*",
                    array_elements: [
                      "cos(#{ element_in_parentheses[:array_elements][0] })",
                      "cos(#{ element_in_parentheses[:array_elements][1] })"
                    ]
                  }, {
                    method: "*",
                    array_elements: [
                      "-1",
                      "sin(#{ element_in_parentheses[:array_elements][0] })",
                      "sin(#{ element_in_parentheses[:array_elements][1] })"
                    ]
                  }
                ]
              })
              return final_result
            else
              return []
            end
          else
            return []
          end
        else
          return []
        end
      end
    end

    #sin(x+y)
    def rule2 trigonometric_equation
      final_result = Array.new
      if trigonometric_equation.kind_of? Hash
        trigonometric_equation[:array_elements].each_index do |index|
          arr_result = self.rule2 trigonometric_equation[:array_elements][index]
            unless arr_result.empty?
            arr_result.each do |result|
              copy_trigonometric_equation = Calculate.copy_hash_element trigonometric_equation
              copy_trigonometric_equation[:array_elements][index] = result
              final_result.push(Trigonometry.refactor_encode_hash copy_trigonometric_equation)
            end
          end
        end
        return final_result
      else
        if trigonometric_equation.include? "sin"
          element_in_parentheses = trigonometric_equation.split("(")[1].split(")")[0]
          if element_in_parentheses.include? ("{")
            element_in_parentheses = eval(element_in_parentheses)
            if element_in_parentheses[:method] == "+" && element_in_parentheses[:array_elements].length == 2
              final_result.push ({
                method: "+",
                array_elements: [
                  {
                    method: "*",
                    array_elements: [
                      "sin(#{ element_in_parentheses[:array_elements][0] })",
                      "cos(#{ element_in_parentheses[:array_elements][1] })"
                    ]
                  }, {
                    method: "*",
                    array_elements: [
                      "cos(#{ element_in_parentheses[:array_elements][0] })",
                      "sin(#{ element_in_parentheses[:array_elements][1] })"
                    ]
                  }
                ]
              })
              return final_result
            else
              return []
            end
          else
            return []
          end
        else
          return []
        end
      end
    end

    #tan(x+y)
    def rule3 trigonometric_equation
      final_result = Array.new
      if trigonometric_equation.kind_of? Hash
        trigonometric_equation[:array_elements].each_index do |index|
          arr_result = self.rule3 trigonometric_equation[:array_elements][index]
            unless arr_result.empty?
            arr_result.each do |result|
              copy_trigonometric_equation = Calculate.copy_hash_element trigonometric_equation
              copy_trigonometric_equation[:array_elements][index] = result
              final_result.push(Trigonometry.refactor_encode_hash copy_trigonometric_equation)
            end
          end
        end
        return final_result
      else
        if trigonometric_equation.include? "tan"
          element_in_parentheses = trigonometric_equation.split("(")[1].split(")")[0]
          if element_in_parentheses.include? ("{")
            element_in_parentheses = eval(element_in_parentheses)
            if element_in_parentheses[:method] == "+" && element_in_parentheses[:array_elements].length == 2
              final_result.push ({
                method: "^",
                array_elements: [
                  {
                    method: "+",
                    array_elements: [
                      "tan(#{ element_in_parentheses[:array_elements][0] })",
                      "tan(#{ element_in_parentheses[:array_elements][1] })"
                    ]
                  }, {
                    method: "*",
                    array_elements: [
                      "-1",
                      {
                        method: "+",
                        array_elements: [
                          "1",
                          {
                            method: "*",
                            array_elements: [
                              "-1",
                              "tan(#{ element_in_parentheses[:array_elements][0] })",
                              "tan(#{ element_in_parentheses[:array_elements][1] })"
                            ]
                          }
                        ]
                      }
                    ]
                  }
                ]
              })
              return final_result
            else
              return []
            end
          else
            return []
          end
        else
          return []
        end
      end
    end

    #sin(2*x)
    def rule4 trigonometric_equation
      final_result = Array.new
      if trigonometric_equation.kind_of? Hash
        trigonometric_equation[:array_elements].each_index do |index|
          arr_result = self.rule4 trigonometric_equation[:array_elements][index]
            unless arr_result.empty?
            arr_result.each do |result|
              copy_trigonometric_equation = Calculate.copy_hash_element trigonometric_equation
              copy_trigonometric_equation[:array_elements][index] = result
              final_result.push(Trigonometry.refactor_encode_hash copy_trigonometric_equation)
            end
          end
        end
        return final_result
      else
        if trigonometric_equation.include? "sin"
          element_in_parentheses = trigonometric_equation.split("(")[1].split(")")[0]
          if element_in_parentheses.include? ("{")
            element_in_parentheses = eval(element_in_parentheses)
            if element_in_parentheses[:method] == "*" && element_in_parentheses[:array_elements].length == 2
              if element_in_parentheses[:array_elements].include? "2"
                element_dup = 0
                element_in_parentheses[:array_elements].each do |child_element|
                  unless child_element == "2"
                    element_dup = child_element
                  end
                end
                final_result.push ({
                  method: "*",
                  array_elements: [
                    "2",
                    "sin(#{ element_dup })",
                    "cos(#{ element_dup })"
                  ]
                })
                return final_result
              else
                return []
              end
            else
              return []
            end
          else
            return []
          end
        else
          return []
        end
      end
    end

    #cos(2*x) = cos(x)^2 - sin(x)^2
    def rule5 trigonometric_equation
      final_result = Array.new
      if trigonometric_equation.kind_of? Hash
        trigonometric_equation[:array_elements].each_index do |index|
          arr_result = self.rule5 trigonometric_equation[:array_elements][index]
            unless arr_result.empty?
            arr_result.each do |result|
              copy_trigonometric_equation = Calculate.copy_hash_element trigonometric_equation
              copy_trigonometric_equation[:array_elements][index] = result
              final_result.push(Trigonometry.refactor_encode_hash copy_trigonometric_equation)
            end
          end
        end
        return final_result
      else
        if trigonometric_equation.include? "cos"
          element_in_parentheses = trigonometric_equation.split("(")[1].split(")")[0]
          if element_in_parentheses.include? ("{")
            element_in_parentheses = eval(element_in_parentheses)
            if element_in_parentheses[:method] == "*" && element_in_parentheses[:array_elements].length == 2
              if element_in_parentheses[:array_elements].include? "2"
                element_dup = 0
                element_in_parentheses[:array_elements].each do |child_element|
                  unless child_element == "2"
                    element_dup = child_element
                  end
                end
                final_result.push ({
                  method: "+",
                  array_elements: [
                    {
                      method: "^",
                      array_elements: [
                        "cos(#{ element_dup })",
                        "2"
                      ]
                    }, {
                      method: "*",
                      array_elements: [
                        "-1",
                        {
                          method: "^",
                          array_elements: [
                            "sin(#{ element_dup })",
                            "2"
                          ]
                        }
                      ]
                    }
                  ]
                })
                return final_result
              else
                return []
              end
            else
              return []
            end
          else
            return []
          end
        else
          return []
        end
      end
    end

    #cos(2*x) = 2*cos(x)^2 - 1
    def rule6 trigonometric_equation
      final_result = Array.new
      if trigonometric_equation.kind_of? Hash
        trigonometric_equation[:array_elements].each_index do |index|
          arr_result = self.rule6 trigonometric_equation[:array_elements][index]
            unless arr_result.empty?
            arr_result.each do |result|
              copy_trigonometric_equation = Calculate.copy_hash_element trigonometric_equation
              copy_trigonometric_equation[:array_elements][index] = result
              final_result.push(Trigonometry.refactor_encode_hash copy_trigonometric_equation)
            end
          end
        end
        return final_result
      else
        if trigonometric_equation.include? "cos"
          element_in_parentheses = trigonometric_equation.split("(")[1].split(")")[0]
          if element_in_parentheses.include? ("{")
            element_in_parentheses = eval(element_in_parentheses)
            if element_in_parentheses[:method] == "*" && element_in_parentheses[:array_elements].length == 2
              if element_in_parentheses[:array_elements].include? "2"
                element_dup = 0
                element_in_parentheses[:array_elements].each do |child_element|
                  unless child_element == "2"
                    element_dup = child_element
                  end
                end
                final_result.push ({
                  method: "+",
                  array_elements: [
                    {
                      method: "*",
                      array_elements: [
                        "2",
                        {
                          method: "^",
                          array_elements: [
                            "cos(#{ element_dup })",
                            "2"
                          ]
                        }
                      ]
                    },
                    "-1"
                  ]
                })
                return final_result
              else
                return []
              end
            else
              return []
            end
          else
            return []
          end
        else
          return []
        end
      end
    end

    #cos(2*x) = 1 - 2*sin(x)^2
    def rule7 trigonometric_equation
      final_result = Array.new
      if trigonometric_equation.kind_of? Hash
        trigonometric_equation[:array_elements].each_index do |index|
          arr_result = self.rule7 trigonometric_equation[:array_elements][index]
            unless arr_result.empty?
            arr_result.each do |result|
              copy_trigonometric_equation = Calculate.copy_hash_element trigonometric_equation
              copy_trigonometric_equation[:array_elements][index] = result
              final_result.push(Trigonometry.refactor_encode_hash copy_trigonometric_equation)
            end
          end
        end
        return final_result
      else
        if trigonometric_equation.include? "cos"
          element_in_parentheses = trigonometric_equation.split("(")[1].split(")")[0]
          if element_in_parentheses.include? ("{")
            element_in_parentheses = eval(element_in_parentheses)
            if element_in_parentheses[:method] == "*" && element_in_parentheses[:array_elements].length == 2
              if element_in_parentheses[:array_elements].include? "2"
                element_dup = 0
                element_in_parentheses[:array_elements].each do |child_element|
                  unless child_element == "2"
                    element_dup = child_element
                  end
                end
                final_result.push ({
                  method: "+",
                  array_elements: [
                    "1",
                    {
                      method: "*",
                      array_elements: [
                        "-1",
                        "2",
                        {
                          method: "^",
                          array_elements: [
                            "sin(#{ element_dup })",
                            "2"
                          ]
                        }
                      ]
                    }
                  ]
                })
                return final_result
              else
                return []
              end
            else
              return []
            end
          else
            return []
          end
        else
          return []
        end
      end
    end

    #sin(x)^2
    def rule8 trigonometric_equation
      final_result = Array.new
      if trigonometric_equation.kind_of? Hash
        if trigonometric_equation[:method] == "^"
          if trigonometric_equation[:array_elements][1] == "2"
            if trigonometric_equation[:array_elements][0].include? "sin"
              element_in_parentheses = trigonometric_equation[:array_elements][0].split("(")[1].split(")")[0]
              if element_in_parentheses.include? "{"
                element_in_parentheses = eval(element_in_parentheses)
              end
              double_element_in_parentheses = { method: "*", array_elements: ["2", element_in_parentheses] }
              double_element_in_parentheses = Trigonometry.refactor_encode_hash double_element_in_parentheses
              final_result.push ({
                method: "*",
                array_elements: [
                  "0.5",
                  {
                    method: "+",
                    array_elements: [
                      "1",
                      {
                        method: "*",
                        array_elements: [
                          "-1",
                          "cos(#{ double_element_in_parentheses })"
                        ]
                      }
                    ]
                  }
                ]
              })
            else
              return []
            end
          else
            return []
          end
        else
          trigonometric_equation[:array_elements].each_index do |index|
            arr_result = self.rule8 trigonometric_equation[:array_elements][index]
              unless arr_result.empty?
              arr_result.each do |result|
                copy_trigonometric_equation = Calculate.copy_hash_element trigonometric_equation
                copy_trigonometric_equation[:array_elements][index] = result
                final_result.push(Trigonometry.refactor_encode_hash copy_trigonometric_equation)
              end
            end
          end
          return final_result
        end
      else
        return []
      end
    end

    #cos(x)^2
    def rule9 trigonometric_equation
      final_result = Array.new
      if trigonometric_equation.kind_of? Hash
        if trigonometric_equation[:method] == "^"
          if trigonometric_equation[:array_elements][1] == "2"
            if trigonometric_equation[:array_elements][0].include? "cos"
              element_in_parentheses = trigonometric_equation[:array_elements][0].split("(")[1].split(")")[0]
              if element_in_parentheses.include? "{"
                element_in_parentheses = eval(element_in_parentheses)
              end
              double_element_in_parentheses = { method: "*", array_elements: ["2", element_in_parentheses] }
              double_element_in_parentheses = Trigonometry.refactor_encode_hash double_element_in_parentheses
              final_result.push ({
                method: "*",
                array_elements: [
                  "0.5",
                  {
                    method: "+",
                    array_elements: [
                      "cos(#{ double_element_in_parentheses })",
                      "1"
                    ]
                  }
                ]
              })
            else
              return []
            end
          else
            return []
          end
        else
          trigonometric_equation[:array_elements].each_index do |index|
            arr_result = self.rule9 trigonometric_equation[:array_elements][index]
              unless arr_result.empty?
              arr_result.each do |result|
                copy_trigonometric_equation = Calculate.copy_hash_element trigonometric_equation
                copy_trigonometric_equation[:array_elements][index] = result
                final_result.push(Trigonometry.refactor_encode_hash copy_trigonometric_equation)
              end
            end
          end
          return final_result
        end
      else
        return []
      end
    end

    #sin(x)*cos(x)
    def rule10 trigonometric_equation
      final_result = Array.new
      if trigonometric_equation.kind_of? Hash
        if trigonometric_equation[:method] == "*"
          if trigonometric_equation[:array_elements].include?("sin(x)") && trigonometric_equation[:array_elements].include?("cos(x)")
            arr_index_sin = Array.new
            arr_index_cos = Array.new
            trigonometric_equation[:array_elements].each_index do |index|
              if trigonometric_equation[:array_elements][index] == "sin(x)"
                arr_index_sin.push index
              elsif trigonometric_equation[:array_elements][index] == "cos(x)"
                arr_index_cos.push index
              end
            end
            copy_trigonometric_equation = Calculate.copy_hash_element trigonometric_equation
            if arr_index_cos.length == arr_index_sin.length
              copy_trigonometric_equation[:array_elements].delete("sin(x)")
              copy_trigonometric_equation[:array_elements].delete("cos(x)")
              if arr_index_sin.length == 1
                copy_trigonometric_equation[:array_elements].push (
                  { method: "*", array_elements: ["0.5", Trigonometry.handle_string("sin(2*x)=0")] })
                final_result.push (Trigonometry.refactor_encode_hash copy_trigonometric_equation)
              else
                copy_trigonometric_equation[:array_elements].push (
                  { method: "^", array_elements: [{ method: "*", array_elements: ["0.5", Trigonometry.handle_string("sin(2*x)=0")] }, arr_index_sin.length.to_s] })
                final_result.push (Trigonometry.refactor_encode_hash copy_trigonometric_equation)
              end
            else
              min_length = [arr_index_sin.length, arr_index_cos.length].min
              copy_trigonometric_equation[:array_elements].delete("sin(x)")
              copy_trigonometric_equation[:array_elements].delete("cos(x)")
              if min_length == arr_index_sin.length
                (arr_index_cos.length - min_length).times do
                  copy_trigonometric_equation[:array_elements].push "cos(x)"
                end
              else
                (arr_index_sin.length - min_length).times do
                  copy_trigonometric_equation[:array_elements].push "sin(x)"
                end
              end
              if min_length == 1
                copy_trigonometric_equation[:array_elements].push (
                  { method: "*", array_elements: ["0.5", Trigonometry.handle_string("sin(2*x)=0")] })
                final_result.push (Trigonometry.refactor_encode_hash copy_trigonometric_equation)
              else
                copy_trigonometric_equation[:array_elements].push (
                  { method: "^", array_elements: [{ method: "*", array_elements: ["0.5", Trigonometry.handle_string("sin(2*x)=0")] }, min_length.to_s] })
                final_result.push (Trigonometry.refactor_encode_hash copy_trigonometric_equation)
              end
            end
            return final_result
          else
            return []
          end
        else
          trigonometric_equation[:array_elements].each_index do |index|
            arr_result = self.rule10 trigonometric_equation[:array_elements][index]
              unless arr_result.empty?
              arr_result.each do |result|
                copy_trigonometric_equation = Calculate.copy_hash_element trigonometric_equation
                copy_trigonometric_equation[:array_elements][index] = result
                final_result.push(Trigonometry.refactor_encode_hash copy_trigonometric_equation)
              end
            end
          end
          return final_result
        end
      else
        return []
      end
    end

    #sin(x)^2 = 1 - cos(x)^2
    def rule11 trigonometric_equation
      final_result = Array.new
      if trigonometric_equation.kind_of? Hash
        if trigonometric_equation[:method] == "^"
          if trigonometric_equation[:array_elements][1] == "2"
            if trigonometric_equation[:array_elements][0].include? "sin"
              element_in_parentheses = trigonometric_equation[:array_elements][0].split("(")[1].split(")")[0]
              if element_in_parentheses.include? "{"
                element_in_parentheses = eval(element_in_parentheses)
              end
              final_result.push ({
                method: "+",
                array_elements: [
                  "1",
                  {
                    method: "*",
                    array_elements: [
                      "-1",
                      {
                        method: "^",
                        array_elements: [
                          "cos(#{ element_in_parentheses })",
                          "2"
                        ]
                      }
                    ]
                  }
                ]
              })
            else
              return []
            end
          else
            return []
          end
        else
          trigonometric_equation[:array_elements].each_index do |index|
            arr_result = self.rule11 trigonometric_equation[:array_elements][index]
              unless arr_result.empty?
              arr_result.each do |result|
                copy_trigonometric_equation = Calculate.copy_hash_element trigonometric_equation
                copy_trigonometric_equation[:array_elements][index] = result
                final_result.push(Trigonometry.refactor_encode_hash copy_trigonometric_equation)
              end
            end
          end
          return final_result
        end
      else
        return []
      end
    end

    #cos(x)^2 = 1 - sin(x)^2
    def rule12 trigonometric_equation
      final_result = Array.new
      if trigonometric_equation.kind_of? Hash
        if trigonometric_equation[:method] == "^"
          if trigonometric_equation[:array_elements][1] == "2"
            if trigonometric_equation[:array_elements][0].include? "cos"
              element_in_parentheses = trigonometric_equation[:array_elements][0].split("(")[1].split(")")[0]
              if element_in_parentheses.include? "{"
                element_in_parentheses = eval(element_in_parentheses)
              end
              final_result.push ({
                method: "+",
                array_elements: [
                  "1",
                  {
                    method: "*",
                    array_elements: [
                      "-1",
                      {
                        method: "^",
                        array_elements: [
                          "sin(#{ element_in_parentheses })",
                          "2"
                        ]
                      }
                    ]
                  }
                ]
              })
            else
              return []
            end
          else
            return []
          end
        else
          trigonometric_equation[:array_elements].each_index do |index|
            arr_result = self.rule12 trigonometric_equation[:array_elements][index]
              unless arr_result.empty?
              arr_result.each do |result|
                copy_trigonometric_equation = Calculate.copy_hash_element trigonometric_equation
                copy_trigonometric_equation[:array_elements][index] = result
                final_result.push(Trigonometry.refactor_encode_hash copy_trigonometric_equation)
              end
            end
          end
          return final_result
        end
      else
        return []
      end
    end

    def name_of_rule rule
      case rule
      when "rule1"
        return "Sử dụng cos(x+y) = cos(x)*cos(y) - sin(x)*sin(y)"
      when "rule2"
        return "Sử dụng sin(x+y) = sin(x)*cos(y) + cos(x)*sin(y)"
      when "rule3"
        return "Sử dụng tan(x+y) = [tan(x)+ tan(y)] / [1 - tan(x)*tan(y)]"
      when "rule4"
        return "Sử dụng sin(2*x) = 2 * sin(x) * cos(x)"
      when "rule5"
        return "Sử dụng cos(2*x) = cos(x)^2 - sin(x)^2"
      when "rule6"
        return "Sử dụng cos(2*x) = 2*cos(x)^2 - 1"
      when "rule7"
        return "Sử dụng cos(2*x) = 1 - 2*sin(x)^2"
      when "rule8"
        return "Sử dụng sin(x)^2 = [1 - cos(2*x)] / 2"
      when "rule9"
        return "Sử dụng cos(x)^2 = [1 + cos(2*x)] / 2"
      when "rule10"
        return "Sử dụng sin(x)*cos(x) =  0.5 * sin(2*x)"
      when "rule11"
        return "Sử dụng sin(x)^2 = 1 - cos(x)^2"
      when "rule12"
        return "Sử dụng cos(x)^2 = 1 - sin(x)^2"
      end
    end
  end
end
