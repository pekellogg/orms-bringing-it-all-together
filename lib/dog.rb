class Dog

    attr_accessor :name, :breed
    attr_reader :id
    
    def initialize(id: nil, name:, breed:)
        @id, @name, @breed = id, name, breed
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
            DROP TABLE IF EXISTS dogs
        SQL
        DB[:conn].execute(sql)
    end

    def select
        sql = "SELECT * FROM dogs WHERE id = ? AND name = ? AND breed = ? LIMIT 1"
        DB[:conn].execute(sql, self.id, self.name, self.breed)[0]
    end

    def save
        if self.id
            self.update
        else
            sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            array = self.select
            pup = Dog.new(id: array[0], name: array[1], breed: array[2])
        end
    end

    def update
		sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
		DB[:conn].execute(sql, self.name, self.breed, self.id)
        array = self.select
        pup = Dog.new(id: array[0], name: array[1], breed: array[2])
	end

    def self.create(name:, breed:)
        pup = self.new(name: name, breed: breed)
        pup.save
    end

    def self.new_from_db(row)
        pup = self.new(name: row[1], breed: row[2])
        pup.save
    end

    def self.find_by_id(id_placeholder)
        sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"
        pup_attrs = DB[:conn].execute(sql, id_placeholder)[0]
        self.new(id: pup_attrs[0], name: pup_attrs[1], breed: pup_attrs[2])
    end

    def self.find_or_create_by(name:, breed:)
        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1"
        puppy = DB[:conn].execute(sql, name, breed)[0]
        if puppy
            pup = Dog.new(id: puppy[0], name: puppy[1], breed: puppy[2])
        else
            pup = self.create(name: name, breed: breed)
        end
        pup
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
        pup_attrs = DB[:conn].execute(sql, name)[0]
        self.new(id: pup_attrs[0], name: pup_attrs[1], breed: pup_attrs[2])
    end

end
