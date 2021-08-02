require "pry"

class Dog
  attr_accessor :name, :breed, :id

  def initialize(hash)
    hash.each do |key, value|
      instance_variable_set("@#{key}", value) unless value.nil? { instance_variable_set("@#{key}", nil) }
    end
  end

  #Instance Methods

  def save
    if self.id
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
      self
    end
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  #Class Methods

  def self.create_table
    sql = <<-SQL
        CREATE TABLE dogs (
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

  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
  end

  def self.new_from_db(row)
    Dog.new({ id: row[0], name: row[1], breed: row[2] })
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE id == ?
    LIMIT 1
    SQL
    row = DB[:conn].execute(sql, id).flatten
    Dog.new({ id: row[0], name: row[1], breed: row[2] })
  end

  def self.find_or_create_by(hash)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ? AND breed = ?
    SQL
    results = DB[:conn].execute(sql, hash[:name], hash[:breed]).flatten
    if !results.empty?
      dog = Dog.find_by_id(results[0])
    else
      dog = Dog.create(hash)
    end
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name == ?
    LIMIT 1
    SQL
    row = DB[:conn].execute(sql, name).flatten
    Dog.new({ id: row[0], name: row[1], breed: row[2] })
  end

end
