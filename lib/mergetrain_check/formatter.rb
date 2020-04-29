module MergetrainCheck
  class TraintableFormatter
    def initialize(max_length, firstname_only)
      @max_length = max_length
      @firstname_only = firstname_only
    end

    def format(body)
      values = [['St', 'MR', 'Pipe ID', 'User', 'Title']]
      body.each do |carriage|
        values << [pipeline_status(carriage['status']),
                   carriage['merge_request']['iid'],
                   carriage['pipeline']['id'],
                   @firstname_only ? carriage['user']['name'].split.first : carriage['user']['name'],
                   truncate_string(carriage['merge_request']['title'], @max_length)]
      end
      values.to_table
    end

    private
    def pipeline_status(status)
      return '🚂' if status == 'fresh'
      return '✅' if status == 'merged'
      status
    end

    def truncate_string(string, len)
      return string if string.length <= len
      "#{string[0...len]}..."
    end


  end
end

class Array
  def to_table
    column_sizes = self.reduce([]) do |lengths, row|
      row.each_with_index.map{|iterand, index| [lengths[index] || 0, iterand.to_s.length + count_emojis(iterand.to_s)].max}
    end
    puts head = '-' * (column_sizes.inject(&:+) + (3 * column_sizes.count) + 1)
    self.each_with_index do |row, idx|
      row = row.fill(nil, row.size..(column_sizes.size - 1))
      row = row.each_with_index.map{|v, i| v = v.to_s + ' ' * (column_sizes[i] - v.to_s.length - count_emojis(v.to_s))}
      puts '| ' + row.join(' | ') + ' |'
      if idx == 0
        row = row.each_with_index.map{|v, i| v = '-' * v.to_s.length}
        puts '| ' + row.join(' | ') + ' |'
      end
    end
    puts head
  end

  private

  def count_emojis(string)
    string.scan(/[\u{1F300}-\u{1F5FF}|\u{1F1E6}-\u{1F1FF}|\u{2700}-\u{27BF}|\u{1F900}-\u{1F9FF}|\u{1F600}-\u{1F64F}|\u{1F680}-\u{1F6FF}|\u{2600}-\u{26FF}]/).length
  end

end
