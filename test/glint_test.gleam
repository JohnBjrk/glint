import gleam/result
import gleeunit
import gleeunit/should
import glint.{CommandInput}
import snag

pub fn main() {
  gleeunit.main()
}

pub fn path_clean_test() {
  glint.new()
  |> glint.add_command(["", " ", " cmd", "subcmd\t"], fn(_) { Nil }, [])
  |> glint.execute(["cmd", "subcmd"])
  |> should.be_ok()
}

pub fn root_command_test() {
  // expecting no args
  glint.new()
  |> glint.add_command(
    at: [],
    do: fn(in: CommandInput) { should.equal(in.args, []) },
    with: [],
  )
  |> glint.execute([])
  |> should.be_ok()

  // expecting some args
  let args = ["arg1", "arg2"]
  let is_args = fn(in: CommandInput) { should.equal(in.args, args) }

  glint.new()
  |> glint.add_command(at: [], do: is_args, with: [])
  |> glint.execute(args)
  |> should.be_ok()
}

pub fn command_routing_test() {
  let args = ["arg1", "arg2"]
  let is_args = fn(in: CommandInput) { should.equal(in.args, args) }

  let has_subcommand =
    glint.new()
    |> glint.add_command(["subcommand"], is_args, [])

  // execute subommand with args
  has_subcommand
  |> glint.execute(["subcommand", ..args])
  |> should.be_ok()

  // no root command set, will return error
  has_subcommand
  |> glint.execute([])
  |> should.be_error()
}

pub fn nested_commands_test() {
  let args = ["arg1", "arg2"]
  let is_args = fn(in: CommandInput) { should.equal(in.args, args) }

  let cmd =
    glint.new()
    |> glint.add_command(["subcommand"], is_args, [])
    |> glint.add_command(["subcommand", "subsubcommand"], is_args, [])

  // call subcommand with args
  cmd
  |> glint.execute(["subcommand", ..args])
  |> should.be_ok()

  // call subcommand subsubcommand with args
  cmd
  |> glint.execute(["subcommand", "subsubcommand", ..args])
  |> should.be_ok()
}

pub fn runner_test() {
  let cmd =
    glint.new()
    |> glint.add_command(at: [], do: fn(_) { Ok("success") }, with: [])
    |> glint.add_command(
      at: ["subcommand"],
      do: fn(_) { snag.error("failed") },
      with: [],
    )

  // command returns its own successful result
  cmd
  |> glint.execute([])
  |> result.flatten
  |> should.equal(Ok("success"))

  // command returns its own error result
  cmd
  |> glint.execute(["subcommand"])
  |> result.flatten
  |> should.be_error()
}
