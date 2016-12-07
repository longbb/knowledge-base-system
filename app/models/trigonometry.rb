class Trigonometry < ApplicationRecord
  class << self
    def handle_string trigonometry_string
      equation_arr = trigonometry_string.split("=")
      if equation_arr[1] == "0"
        equal_0_string = equation_arr[0]
      else
        equal_0_string = equation_arr[0] + opposite(equation_arr[1])
      end
      array_trigonometries = self.parse_trigonometry equal_0_string
      result = self.encode_trigonometry_string array_trigonometries
      result = self.refactor_encode_hash result
      result = self.encode_in_trigonometry result
    end

    def opposite string
      is_in_parenthesis = Array.new
      arr_string = string.split("")

      opposite_arr_string = arr_string.map do |character|
        result = character
        if is_in_parenthesis.empty?
          if (character == "-")
            result = "+"
          elsif (character == "+")
            result = "-"
          end
        end
        if character == "["
          is_in_parenthesis.push "["
        end
        if character == "("
          is_in_parenthesis.push "("
        end
        if character == "]"
          is_in_parenthesis.pop
        end
        if character == ")"
          is_in_parenthesis.pop
        end
        result
      end

      unless opposite_arr_string[0] == "+" || opposite_arr_string[0] == "-"
        opposite_arr_string.unshift(" - ")
      end

      opposite_arr_string.join("")
    end

    def parse_trigonometry trigonometry_string
      array_terms = Array.new
      number_parenthesis = 0
      array_in_parenthesis = Array.new
      array_elements = trigonometry_string.split(" ")
      is_negative = false
      is_in_parenthesis = false
      array_elements.each do |element|
        unless element == "+"
          case element
          when "-"
            is_negative = true
          when "["
            number_parenthesis += 1
            if is_negative
              array_in_parenthesis[number_parenthesis - 1] = ["-1"]
            else
              array_in_parenthesis[number_parenthesis - 1] = ["1"]
            end
            is_negative = false
          when "]"
            number_parenthesis -= 1
            if number_parenthesis == 0
              array_terms.push array_in_parenthesis[0]
              array_in_parenthesis = []
            else
              array_in_parenthesis[number_parenthesis - 1].push(
                array_in_parenthesis[number_parenthesis])
              array_in_parenthesis[number_parenthesis] = []
            end
          else
            constituent = element
            if is_negative
              constituent = { method: "*", array_elements: ["-1", self.parse_element(element)] }
              is_negative = false
            end
            if number_parenthesis != 0
              array_in_parenthesis[number_parenthesis - 1].push constituent
            else
              array_terms.push constituent
            end
          end
        end
      end
      array_terms
    end

    def parse_element element
      if element.index("*") != nil || element.index("/") != nil
        hash = {
          method: "*",
          array_elements: Array.new
        }
        last_operation_position = 0
        array_facients = Array.new
        array_characters = element.split("")
        is_in_trigonometry = false
        array_characters.each_index do |index|
          if array_characters[index] == "("
            is_in_trigonometry = true
          elsif array_characters[index] == ")"
            is_in_trigonometry = false
            if index == (element.length - 1)
              array_facients.push element.byteslice(last_operation_position,
                index + 1 - last_operation_position)
            end
          elsif ["*", "^", "/"].include? array_characters[index]
            unless is_in_trigonometry
              unless index == 0
                array_facients.push element.byteslice(last_operation_position,
                index - last_operation_position)
              end
              last_operation_position = index + 1
              array_facients.push array_characters[index]
            end
          elsif index == (element.length - 1)
            array_facients.push element.byteslice(last_operation_position,
              index + 1 - last_operation_position)
          end
        end
        is_div = false
        array_facients.each_index do |index|
          if index == 0 || index == array_facients.length - 1
            if is_div
              new_hash = {
                method: "^",
                array_elements: [array_facients[index], -1]
              }
              hash[:array_elements].push new_hash
              is_div = false
            else
              hash[:array_elements].push array_facients[index]
            end
          elsif array_facients[index] == "/"
            is_div = true
          else
            unless array_facients[index] == "*"
              if is_div
                new_hash = {
                  method: "^",
                  array_elements: [array_facients[index], -1]
                }
                hash[:array_elements].push new_hash
                is_div = false
              else
                hash[:array_elements].push array_facients[index]
              end
            end
          end
        end
        return hash
      elsif element.index("^") != nil
        hash  = {
          method: "^",
          array_elements: Array.new
        }
        if element.index("^") == 0
          hash[:array_elements] = ["^", element.byteslice(1, element.length - 1)]
        else
          hash[:array_elements] = [element.byteslice(0, element.length - 1), "^"]
        end
        return hash
      else
        return element
      end
    end

    def encode_trigonometry_string trigonometry_array
      if trigonometry_array.length > 1
        hash = {
          method: "+",
          array_elements: Array.new
        }
        trigonometry_array.each do |trigonometry_string|
          if trigonometry_string.kind_of?(Array)
            array_in_parenthesis = Trigonometry.encode_trigonometry_string trigonometry_string
            array_in_parenthesis[:array_elements].push "Parenthesis"
            hash[:array_elements].push array_in_parenthesis
          elsif trigonometry_string.kind_of? Hash
            hash[:array_elements].push trigonometry_string
          elsif ["*", "/", "^"].include? trigonometry_string
            hash[:array_elements].push trigonometry_string
          else
            hash[:array_elements].push Trigonometry.parse_element(trigonometry_string)
          end
        end
        hash[:array_elements].each_index do |index|
          if hash[:array_elements][index].kind_of? Hash
            if hash[:array_elements][index][:array_elements].last == "Parenthesis"
              hash[:array_elements][index][:array_elements].pop
              new_hash = hash[:array_elements][index]
              if new_hash[:array_elements].first == "1"
                new_hash[:array_elements].shift
              else
                if new_hash[:method] != "*"
                  new_hash[:array_elements].shift
                end
                new_hash =  ({
                  method: "*",
                  array_elements: ["-1", new_hash]
                })
              end
              hash[:array_elements][index] = new_hash
            end
          end
        end

        hash[:array_elements].each_index do |index|
          if hash[:array_elements][index].kind_of? Hash
            unless index == hash[:array_elements].length - 1
              case hash[:array_elements][index][:array_elements].last
              when "*"
                hash[:array_elements][index][:array_elements].pop
                hash[:array_elements][index][:array_elements].push hash[:array_elements][index + 1]
                hash[:array_elements].delete_at(index + 1)
              when "/"
                hash[:array_elements][index][:array_elements].pop
                if hash[:array_elements][index + 1].kind_of? Hash
                  if hash[:array_elements][index + 1][:method] == "*"
                    hash[:array_elements][index][:array_elements].push ({
                      method: "^",
                      array_elements: [hash[:array_elements][index + 1][:array_elements][0], "-1"]
                    })
                    hash[:array_elements][index + 1][:array_elements].shift
                    unless hash[:array_elements][index + 1][:array_elements].empty?
                      hash[:array_elements][index + 1][:array_elements].each do |element|
                        hash[:array_elements][index][:array_elements].push element
                      end
                    end
                  else
                    hash[:array_elements][index][:array_elements].push ({
                      method: "^",
                      array_elements: [hash[:array_elements][index + 1], "-1"]
                    })
                  end
                else
                  hash[:array_elements][index][:array_elements].push ({
                    method: "^",
                    array_elements: [hash[:array_elements][index + 1], "-1"]
                  })
                end
                hash[:array_elements].delete_at(index + 1)
              when "^"
                if hash[:array_elements][index][:method] == "*"
                  hash[:array_elements][index][:array_elements].pop
                  basis = hash[:array_elements][index][:array_elements].pop
                  hash[:array_elements][index][:array_elements].push ({
                    method: "^",
                    array_elements: [basis, hash[:array_elements][index + 1]]
                  })
                else
                  hash[:array_elements][index][:array_elements].pop
                  hash[:array_elements][index][:array_elements].push hash[:array_elements][index + 1]
                end
                hash[:array_elements].delete_at(index + 1)
              end
            end
          else
            case hash[:array_elements][index]
            when "*"
              if hash[:array_elements][index - 1].kind_of? Hash
                if hash[:array_elements][index - 1][:method] == "*"
                  hash[:array_elements][index - 1][:array_elements].push hash[:array_elements][index + 1]
                else
                  hash[:array_elements][index - 1] = {
                    method: "*",
                    array_elements: [hash[:array_elements][index - 1], hash[:array_elements][index + 1]]
                  }
                end
              else
                hash[:array_elements][index - 1] = {
                  method: "*",
                  array_elements: [hash[:array_elements][index - 1], hash[:array_elements][index + 1]]
                }
              end
              hash[:array_elements].delete_at(index + 1)
              hash[:array_elements].delete_at(index)
            when "/"
              if hash[:array_elements][index - 1].kind_of? Hash
                if hash[:array_elements][index - 1][:method] == "*"
                  hash[:array_elements][index - 1][:array_elements].push ({
                    method: "^",
                    array_elements: [hash[:array_elements][index + 1], "-1"]
                  })
                else
                  hash[:array_elements][index - 1] = ({
                    method: "*",
                    array_elements: [hash[:array_elements][index - 1], {
                      method: "^",
                      array_elements: [hash[:array_elements][index + 1], "-1"]
                    }]
                  })
                end
              else
                hash[:array_elements][index - 1] = ({
                  method: "*",
                  array_elements: [hash[:array_elements][index - 1], {
                    method: "^",
                    array_elements: [hash[:array_elements][index + 1], "-1"]
                  }]
                })
              end
              hash[:array_elements].delete_at(index + 1)
              hash[:array_elements].delete_at(index)
            when "^"
              if hash[:array_elements][index - 1].kind_of? Hash
                if hash[:array_elements][index - 1][:method] == "*"
                  basis = hash[:array_elements][index - 1][:array_elements].pop
                  hash[:array_elements][index - 1][:array_elements].push ({
                    method: "^",
                    array_elements: [basis, hash[:array_elements][index + 1]]
                  })
                else
                  hash[:array_elements][index - 1] = ({
                    method: "^",
                    array_elements: [hash[:array_elements][index - 1], hash[:array_elements][index + 1]]
                  })
                end
              else
                hash[:array_elements][index - 1] = {
                  method: "^",
                  array_elements: [hash[:array_elements][index - 1], hash[:array_elements][index + 1]]
                }
              end
              hash[:array_elements].delete_at(index + 1)
              hash[:array_elements].delete_at(index)
            end
          end
        end

        hash[:array_elements].each_index do |index|
          if hash[:array_elements][index].kind_of? Hash
            unless index == 0
              case hash[:array_elements][index][:array_elements].first
              when "*"
                hash[:array_elements][index][:array_elements].shift
                if hash[:array_elements][index - 1].kind_of Hash
                  if hash[:array_elements][index - 1][:method] = "*"
                    hash[:array_elements][index - 1][:array_elements] += hash[:array_elements][index][array_elements]
                  else
                    hash[:array_elements][index][:array_elements].unshirf hash[:array_elements][index - 1]
                    hash[:array_elements][index - 1] = hash[:array_elements][index]
                  end
                else
                  hash[:array_elements][index][:array_elements].unshirf hash[:array_elements][index - 1]
                  hash[:array_elements][index - 1] = hash[:array_elements][index]
                end
                hash[:array_elements].delete_at(index)
              when "/"
                hash[:array_elements][index][:array_elements].shift
                if hash[:array_elements][index - 1].kind_of? Hash
                  if hash[:array_elements][index - 1][:method] == "*"
                    if hash[:array_elements][index][:method] == "*"
                      hash[:array_elements][index - 1][:array_elements].push ({
                        method: "^",
                        array_elements: [hash[:array_elements][index][:array_elements][0], "-1"]
                      })
                      hash[:array_elements][index][:array_elements].shift
                      unless hash[:array_elements][index][:array_elements].empty?
                        hash[:array_elements][index][:array_elements].each do |element|
                          hash[:array_elements][index - 1][:array_elements].push element
                        end
                      end
                    else
                      hash[:array_elements][index - 1][:array_elements].push ({
                        method: "^",
                        array_elements: [hash[:array_elements][index], "-1"]
                      })
                    end
                  else
                    hash[:array_elements][index - 1] = {
                      method: "*",
                      array_elements: [hash[:array_elements][index - 1]]
                    }
                    if hash[:array_elements][index][:method] == "*"
                      hash[:array_elements][index - 1][:array_elements].push ({
                        method: "^",
                        array_elements: [hash[:array_elements][index][:array_elements][0], "-1"]
                      })
                      hash[:array_elements][index][:array_elements].shift
                      unless hash[:array_elements][index][:array_elements].empty?
                        hash[:array_elements][index][:array_elements].each do |element|
                          hash[:array_elements][index - 1][:array_elements].push element
                        end
                      end
                    else
                      hash[:array_elements][index - 1][:array_elements].push ({
                        method: "^",
                        array_elements: [hash[:array_elements][index], "-1"]
                      })
                    end
                  end
                else
                 hash[:array_elements][index - 1] = {
                    method: "*",
                    array_elements: [hash[:array_elements][index - 1]]
                  }
                  if hash[:array_elements][index][:method] == "*"
                    hash[:array_elements][index - 1][:array_elements].push ({
                      method: "^",
                      array_elements: [hash[:array_elements][index][:array_elements][0], "-1"]
                    })
                    hash[:array_elements][index][:array_elements].shift
                    unless hash[:array_elements][index][:array_elements].empty?
                      hash[:array_elements][index][:array_elements].each do |element|
                        hash[:array_elements][index - 1][:array_elements].push element
                      end
                    end
                  else
                    hash[:array_elements][index - 1][:array_elements].push ({
                      method: "^",
                      array_elements: [hash[:array_elements][index], "-1"]
                    })
                  end
                end
                hash[:array_elements].delete_at(index)
              end
            end
          end
        end
        if hash[:array_elements].length == 1
          hash = hash[:array_elements].first
        end
        return hash
      else
        result = Trigonometry.parse_element(trigonometry_array[0])
      end
    end

    def refactor_encode_hash encode_hash
      if encode_hash.kind_of? Hash
        if encode_hash[:array_elements].length == 1
          return encode_hash[:array_elements][0]
        else
          new_array_elements = Array.new
          encode_hash[:array_elements].each do |element|
            new_element = Trigonometry.refactor_encode_hash element
            if new_element.kind_of? Hash
              if new_element[:method] == encode_hash[:method]
                new_element[:array_elements].each do |element_in_new|
                  new_array_elements.push element_in_new
                end
              else
                new_array_elements.push new_element
              end
            else
              new_array_elements.push new_element
            end
          end
          encode_hash[:array_elements] = new_array_elements
          return encode_hash
        end
      else
        return encode_hash
      end
    end

    def encode_in_trigonometry encode_hash
      if encode_hash.kind_of? Hash
        new_array_elements = Array.new
        encode_hash[:array_elements].each do |element|
          if element.kind_of? Hash
            new_array_elements.push self.encode_in_trigonometry element
          else
            new_array_elements.push self.encode_in_parentheses element
          end
        end
        encode_hash[:array_elements] = new_array_elements
        return encode_hash
      else
        return self.encode_in_parentheses encode_hash
      end
    end

    def encode_in_parentheses element
      if self.check_need_encode element
        split_element = element.split("(")
        in_parentheses = split_element[1].split(")")[0]
        in_parentheses = in_parentheses.split("+").join(" + ")
        in_parentheses = in_parentheses.split("-").join(" - ")
        in_parentheses = self.parse_trigonometry in_parentheses
        in_parentheses = self.encode_trigonometry_string in_parentheses
        in_parentheses = self.refactor_encode_hash in_parentheses
        in_parentheses = in_parentheses.to_s
        split_element[1] = in_parentheses + ")"
        return split_element.join("(")
      end
      return element
    end

    def check_need_encode trigonometry_string
      if trigonometry_string.include? "x"
        if trigonometry_string.include? "+"
          return true
        elsif trigonometry_string.include? "-"
          return true
        elsif trigonometry_string.include? "*"
          return true
        elsif trigonometry_string.include? "/"
          return true
        else
          return false
        end
      else
        return false
      end
    end
  end
end
