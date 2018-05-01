require 'pry'

class Dog
  attr_accessor :name, :breed, :id

  def initialize(name: nil, breed: nil, id: nil)
    @name = name
    @breed = breed
    @id =id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
      SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    new_dog = Dog.new
    new_dog.id = row[0]
    new_dog.name = row[1]
    new_dog.breed = row[2]
    new_dog
  end

  def self.find_by_name(dog_name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?;
    SQL

    DB[:conn].execute(sql, dog_name).map do |row|
      self.new_from_db(row)
    end.first

  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql,id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)

    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(name: dog_data[1], breed: dog_data[2], id: dog_data[0])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)

      dog_array = DB[:conn].execute("SELECT * FROM dogs ORDER BY id DESC LIMIT 1")[0]

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

      dog = Dog.new
      dog.id = dog_array[0]
      dog.name = dog_array[1]
      dog.breed = dog_array[2]
      dog
    end

  end

  def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
  end

end
