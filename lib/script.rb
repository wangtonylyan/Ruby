
ARGV.each do |file|
  content = File.open(file).collect do |line|
    line.chomp.downcase
  end
  content.reject do |line|
    line.include?('#')
  end
  content.each do |line|
    puts line
  end
end
