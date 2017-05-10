# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
def create_code_lash_data(question)
  RoundData.create! game_type: GameType::CodeLash.game_type,
                    data: { question: question }
end

def create_fib_onacci_data(question, answer)
  RoundData.create! game_type: GameType::FibOnacci.game_type,
                    data: { question: question, answer: answer }
end

create_code_lash_data "What the J stands for in JRuby"
create_code_lash_data "The One True Language"
create_code_lash_data "How to make Ruby faster than Java"
create_code_lash_data "The original name for Ruby on Rails"
create_code_lash_data "The next big feature for Rails"
create_code_lash_data "TODO 1"
create_code_lash_data "TODO 2"
create_code_lash_data "TODO 3"
create_code_lash_data "TODO 4"
create_code_lash_data "TODO 5"
create_code_lash_data "TODO 6"
create_code_lash_data "TODO 7"
create_code_lash_data "TODO 8"
create_code_lash_data "TODO 9"
create_code_lash_data "TODO 10"
create_code_lash_data "TODO 11"
create_code_lash_data "TODO 12"
create_code_lash_data "TODO 13"
create_code_lash_data "TODO 14"
create_code_lash_data "TODO 15"

create_fib_onacci_data "EXAMPLE 1",  "ANSWER 1"
create_fib_onacci_data "EXAMPLE 2",  "ANSWER 2"
create_fib_onacci_data "EXAMPLE 3",  "ANSWER 3"
create_fib_onacci_data "EXAMPLE 4",  "ANSWER 4"
create_fib_onacci_data "EXAMPLE 5",  "ANSWER 5"
create_fib_onacci_data "EXAMPLE 6",  "ANSWER 6"
create_fib_onacci_data "EXAMPLE 7",  "ANSWER 7"
create_fib_onacci_data "EXAMPLE 8",  "ANSWER 8"
create_fib_onacci_data "EXAMPLE 9",  "ANSWER 9"
create_fib_onacci_data "EXAMPLE 10", "ANSWER 10"
create_fib_onacci_data "EXAMPLE 11", "ANSWER 11"
create_fib_onacci_data "EXAMPLE 12", "ANSWER 12"
create_fib_onacci_data "EXAMPLE 13", "ANSWER 13"
create_fib_onacci_data "EXAMPLE 14", "ANSWER 14"
create_fib_onacci_data "EXAMPLE 15", "ANSWER 15"
create_fib_onacci_data "EXAMPLE 16", "ANSWER 16"
create_fib_onacci_data "EXAMPLE 17", "ANSWER 17"
create_fib_onacci_data "EXAMPLE 18", "ANSWER 18"
create_fib_onacci_data "EXAMPLE 19", "ANSWER 19"
create_fib_onacci_data "EXAMPLE 20", "ANSWER 20"
