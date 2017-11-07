# Action Archive - Object Relational Mapping for Ruby

Action Archive is a light-weight ORM for the Ruby programming language, inspired by Active Record, that allows for simple querying of databases through easy to use methods defined on a master class. When the master class is subclassed, it provides all of the functionality through class inheritance and meta-programming. Action Archive heavily depends on naming conventions that that will take much of the work away from a user as long as he or she adheres to the rules.

## Features

+ Automatic mapping between classes and attributes to tables and columns

        class Cat < ActionArchive
        end


+ Associations can be made between objects through simple methods

        class Cat < ActionArchive
          belongs_to :human, foreign_key: :owner_id
        end

+ Quickly extract full tables

        Cat.all

+ Specify specific pieces of data

        Cat.where(name: "Breakfast")
