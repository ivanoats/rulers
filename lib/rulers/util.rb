module Rulers
  def self.to_underscore(string)
    my_string = string.gsub(/::/, File::SEPARATOR).
      gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
      gsub(/([a-z\d])([A-Z])/, '\1_\2').
      tr("-", "_").downcase
    puts my_string
    my_string
  end
end
