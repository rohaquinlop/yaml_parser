import argv
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import utils

pub type Number {
  SomeInt(Int)
  SomeFloat(Float)
}

pub type Yaml {
  ScalarString(String)
  ScalarNumber(Number)
  ScalarList(List(Yaml))
  Mapping(name: String, value: Yaml)
  Comment(String)
}

pub fn main() {
  case argv.load().arguments {
    [file_name] -> parse(file_name)
    _ -> io.println("Is mandatory to pass an argument <yaml file>")
  }
}

pub fn parse(file_name: String) {
  let lines = utils.read_lines(file_name) |> utils.remove_empty_lines
  let indent_size = utils.indentation_size(lines)

  utils.split_by_level(lines, 0, indent_size)
  |> list.map(fn(lst: List(String)) {
    // io.println("New group")
    print_lines(lst, indent_size)
  })
  // print_lines(lines, indent_size)

  Nil
}

fn print_lines(lines: List(String), indent_size: Int) -> Nil {
  case lines {
    [] -> Nil
    [a, ..tail] -> {
      //io.println(a)
      io.debug(generate_yaml(a))
      print_lines(tail, indent_size)
    }
  }
}

fn generate_yaml(line: String) -> Yaml {
  let pure_line = string.trim(line)

  case string.starts_with(pure_line, "-") {
    True -> generate_yaml(string.drop_left(pure_line, 1))
    False -> {
      // Check if its a Mapping
      case string.split_once(pure_line, ":") {
        Ok(#(name, value)) -> {
          Mapping(name, generate_yaml(value))
        }
        Error(_) -> {
          // Check if its a float
          let trimmed_line = string.trim(pure_line)
          case float.parse(trimmed_line) {
            Ok(number) -> ScalarNumber(SomeFloat(number))
            Error(_) -> {
              // Check if its an integer
              case int.parse(trimmed_line) {
                Ok(number) -> ScalarNumber(SomeInt(number))
                Error(_) -> ScalarString(pure_line)
              }
            }
          }
        }
      }
    }
  }
}
