def index_name(statement)
  statement.split(':name => ')[1].strip.gsub(/"/, '')
end

def index_name_increment(indexes, index_name)
  original_index_name = index_name.dup
  number = 1
  while true
    index_name = "#{original_index_name}_#{number.to_s}"
    if indexes.include?(index_name)
      number += 1
    else
      break
    end
  end

  index_name
end

indexes = []

ARGF.each_line.grep(/add_index/) do |index_statement|
  # Skip unique indexes because the lanyrd converter preserves them
  next if index_statement.include?(':unique => true')

  current_index = index_name(index_statement)
  if indexes.include?(current_index)
    old_index = current_index.dup
    current_index = index_name_increment(indexes, current_index)

    index_statement.sub!(":name => \"#{old_index}\"", ":name => \"#{current_index}\"")
  end

  indexes.push(current_index)
  puts <<EOS
begin
  ActiveRecord::Base.connection.#{index_statement.strip}
  puts 'Created index ' + %q{#{current_index}}
rescue ArgumentError => e
  puts e
end

EOS
end
