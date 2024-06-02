import gleam/int
import gleam/list
import gleam/string

@external(erlang, "file_management", "read_lines")
pub fn read_lines(file_name: String) -> List(String)

pub fn indentation_size(lines: List(String)) -> Int {
  list.map(lines, count_indent)
  |> list.filter(fn(indent) { indent > 0 })
  |> get_min_list
}

pub fn remove_empty_lines(lines: List(String)) -> List(String) {
  list.filter(lines, fn(line) { string.trim(line) != "" })
}

pub fn split_by_level(
  lines: List(String),
  level: Int,
  indent_size: Int,
) -> List(List(String)) {
  split_by_level_(lines, level, indent_size, [], [])
}

fn split_by_level_(
  lines: List(String),
  level: Int,
  indent_size: Int,
  lvl_list: List(String),
  ans: List(List(String)),
) -> List(List(String)) {
  case lines {
    [] -> list.append(ans, [lvl_list])
    [a, ..tail] -> {
      case get_line_level(a, indent_size) > level {
        True -> {
          split_by_level_(
            tail,
            level,
            indent_size,
            list.append(lvl_list, [a]),
            ans,
          )
        }
        False -> {
          case lvl_list {
            [] -> split_by_level_(tail, level, indent_size, [a], ans)
            _ ->
              split_by_level_(
                tail,
                level,
                indent_size,
                [a],
                list.append(ans, [lvl_list]),
              )
          }
        }
      }
    }
  }
}

fn get_line_level(line: String, indent_size: Int) -> Int {
  let indent = count_indent(line)

  case indent {
    0 -> 0
    _ -> indent / indent_size
  }
}

fn count_indent(line: String) -> Int {
  string.length(line) - string.length(string.trim_left(line))
}

fn get_min_list(lst: List(Int)) -> Int {
  case lst {
    [] -> 0
    [a] -> a
    [a, ..tail] -> int.min(a, get_min_list(tail))
  }
}
