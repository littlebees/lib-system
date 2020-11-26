# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Reader.create.create_user email: "a@a.com", password: "12345678"
Reader.create.create_user email: "b@a.com", password: "12345678"

Librarian.create.create_user email: "l@a.com", password: "12345678"

b = Book.create
4.times { |_| b.copies.create }

