require "sqlite3"
require "rulers/util"

DB = SQLite3::Database.new "test.db"

module Rulers
  module Model
    class SQLite
      def self.table
        Rulers.to_underscore name
      end

      def self.schema
        return @schema if @schema
        @schema = {}
        puts "table is #{table}"
        DB.table_info(table) do |row|
          STDERR.puts "this row is #{row.inspect}"
          @schema[row["name"]] = row["type"]
        end
        @schema
      end

      def initialize(data = nil)
        @hash = data
        # @hash.each do |attr,value|
        #   self.class.send(:define_method, attr) do
        #     value
        #   end
        # end
      end

      def method_missing(column_name)
        STDERR.puts "in search of a method called #{column_name}"
        self.class.send(:define_method, column_name) do
          @hash[column_name.to_s]
        end
        send column_name
      end

      def self.to_sql(val)
        STDERR.puts "To sql val: #{val.inspect}"

        case val
        when Numeric
          val.to_s
        when String
          "'#{val}'"
        else
          raise "Can't change #{val.class} to SQL!"
        end
      end

      def self.create(values)
        STDERR.puts "entering self.create"
        STDERR.puts "values: #{values.inspect}"

        values.delete "id"

        STDERR.puts "schema.keys #{schema.keys.inspect}"
        keys = schema.keys - ["id"]
        STDERR.puts "keys should now not have id: #{keys.inspect}"


        STDERR.puts "keys is a #{keys.class}"

        vals = keys.map do |key|
          STDERR.puts "figuring out the to_sql for #{key}."
          values[key] ? to_sql(values[key]) : "null"
        end
        STDERR.puts "Our vals ends up being: #{vals.inspect}"

        sql = <<SQL
INSERT INTO #{table} (#{keys.join ","})
VALUES (#{vals.join ","});
SQL
        puts "SQL: #{sql}"
        DB.execute sql

        data = Hash[keys.zip vals]
        sql = "SELECT last_insert_rowid();"
        data["id"] = DB.execute(sql)[0][0]
        self.new data
      end

      def self.count
        DB.execute(<<SQL)[0][0]
SELECT COUNT(*) FROM #{table};
SQL
      end

      def self.find(id)
        row = DB.execute <<SQL
SELECT #{schema.keys.join ","} FROM #{table}
WHERE id = #{id};
SQL
        STDERR.puts "row: #{row.inspect}"
        data = Hash[schema.keys.zip row[0]]
        new data
      end

      def [](name)
        @hash[name.to_s]
      end

      def []=(name, value)
        @hash[name.to_s] = value
      end

      def save!
        unless @hash["id"]
          self.class.create
          return true
        end

        fields = @hash.map do |k, v|
          "#{k}=#{self.class.to_sql(v)}"
        end.join ","

        DB.execute <<SQL
UPDATE #{self.class.table}
SET #{fields}
WHERE id = #{@hash["id"]}
SQL
        true
      end

      def save
        save! rescue false
      end
    end
  end
end
