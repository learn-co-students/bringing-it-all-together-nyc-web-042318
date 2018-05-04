require 'pry'
# Implements basic behavior of a basic dog
class Dog

  @@dogs = []

  attr_accessor :id, :name, :breed

  def initialize(id: nil, name: "Chico", breed: "mutt")
    @id = id
    @name = name
    @breed = breed

    @@dogs << self
  end

  def self.drop_table
    DB[:conn].execute('DROP TABLE IF EXISTS dogs')
  end

  def self.create_table
    self.drop_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      breed TEXT NOT NULL);
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed) VALUES (?, ?);
    SQL
    DB[:conn].execute(sql, @name, @breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    Dog.new(id: @id, name: @name, breed: @breed)
  end

  def self.create(attributes)
    @name = attributes[:name]
    @breed = attributes[:breed]
    Dog.new(name: @name, breed: @breed).save
  end

  def self.find_by_id(num)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?;
    SQL
    dogArray = DB[:conn].execute(sql, num).flatten
    attributes = {}
    attributes[:id] = dogArray[0]
    attributes[:name] = dogArray[1]
    attributes[:breed] = dogArray[2]
    Dog.new(attributes)
  end

  def self.find_or_create_by(attributes)
    @@dogs.each do |dogHash|
      if dogHash.name == attributes[:name] && dogHash.breed == attributes[:breed]
        return dogHash
      end
    Dog.create(attributes)
    end
  end

  def self.new_from_db(row)
    attributes = {}
    attributes[:id] = row[0]
    attributes[:name] = row[1]
    attributes[:breed] = row[2]
    Dog.create(attributes)
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?;
    SQL
    dogArray = DB[:conn].execute(sql, name).flatten
    attributes = {}
    attributes[:id] = dogArray[0]
    attributes[:name] = dogArray[1]
    attributes[:breed] = dogArray[2]
    Dog.new(attributes)
  end

  def update
   sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
   DB[:conn].execute(sql, @name, @breed, @id)
  end

end

