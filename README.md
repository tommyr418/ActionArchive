# Action Archive - Object Relational Mapping for Ruby

Action Archive is a light-weight ORM for the Ruby programming language that allows for simple querying of databases through easy to use methods defined on a master class. When the master class is subclassed, it provides all of the functionality through class inheritance and meta-programming. Action Archive heavily depends on naming conventions that that will take much of the work away from a user as long as he or she adheres to the rules.

## Installation

Download/Clone the repository via direct download or command line:
        git clone https://github.com/tommyr418/ActionArchive.git

Run `pry -r './test.rb'` to access a console where you can interact with the database. House, Human, and Cat ActiveArchive are available for testing.

## Features

+ As a user, I can easily map classes and attributes to tables and columns by creating a model that inherits from the master class: Action Archive

        class Cat < ActionArchive
        end


+ As a user, I can make associations between objects through simple methods like belongs_to and has_many

        class Cat < ActionArchive
          belongs_to :human, foreign_key: :owner_id
        end

+ As a user, I can quickly extract full tables using the all method

        Cat.all

+ As a user, I can quickly find by id by using the find method

        Cat.find(1)

+ As a user, I can specify specific pieces of data through the where method and providing specific conditions

        Cat.where(name: "Breakfast")
