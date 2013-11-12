class Array
  def sum(start = 0)
    inject(start, &:+)
  end

  def sum_verbose(sum = 0)
    reduce do |sum, n|
      puts "I'm reducing  #{sum} with #{n} !!"
      sum + n
    end
  end
end
