require 'date'

module MergetrainCheck
  class TraintableFormatter
    def initialize(max_length, firstname_only)
      @max_length = max_length
      @firstname_only = firstname_only
    end

    def format(body)
      values = [['St', 'Waiting', 'Running', 'MR', 'Pipe ID', 'User', 'Title']]
      values << spacer = nil

      previous_state = body.first['status']
      body.each do |carriage|
        begin_time = date_from_string carriage['created_at']
        pipeline_begin_time = date_from_string carriage['pipeline']['created_at']
        end_time = carriage['merged_at'].nil? ? DateTime.now : date_from_string(carriage['merged_at'])

        is_finished_section = previous_state != carriage['status']
        previous_state = carriage['status']
        values << spacer if is_finished_section

        values << [pipeline_status(carriage['status']),
                   pretty_date_difference(begin_time, pipeline_begin_time),
                   pretty_date_difference(pipeline_begin_time, end_time),
                   carriage['merge_request']['iid'],
                   carriage['pipeline']['id'],
                   @firstname_only ? carriage['user']['name'].split.first : carriage['user']['name'],
                   truncate_string(carriage['merge_request']['title'], @max_length)]
      end

      header = ''
      if has_train_finished? body
        header = "\n  ✋ 🚉 The train is at the station: There are currently no running merge trains!\n\n"
      end
       header + values.to_table
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

    def date_from_string(datestring)
      DateTime.parse(datestring, '%Q')
    end

    def pretty_date_difference(from, to)
      (to.to_time - from.to_time).duration
    end

    def has_train_finished?(data)
      data.first['status'] != 'fresh'
    end
  end
end

class Array
  def to_table
    output = ''
    column_sizes = self.reduce([]) do |lengths, row|
      if row.nil?
        lengths
      else
        row.each_with_index.map{|iterand, index| [lengths[index] || 0, iterand.to_s.length + count_emojis(iterand.to_s)].max}
      end
    end
    output += head = '-' * (column_sizes.inject(&:+) + (3 * column_sizes.count) + 1) + "\n"
    self.each_with_index do |row, idx|
      if row.nil?
        row = column_sizes.map { |l| '-' * l }
        output += '| ' + row.join(' | ') + ' |' + "\n"
      else
        row = row.fill(nil, row.size..(column_sizes.size - 1))
        row = row.each_with_index.map{|v, i| v = v.to_s + ' ' * (column_sizes[i] - v.to_s.length - count_emojis(v.to_s))}
        output += '| ' + row.join(' | ') + ' |' + "\n"
      end
    end
    output += head
  end

  private

  def count_emojis(string)
    string.scan(/[\u{1F300}-\u{1F5FF}|\u{1F1E6}-\u{1F1FF}|\u{2700}-\u{27BF}|\u{1F900}-\u{1F9FF}|\u{1F600}-\u{1F64F}|\u{1F680}-\u{1F6FF}|\u{2600}-\u{26FF}]/).length
  end
end

class Numeric
   def duration
     rest, secs = self.divmod( 60 )  # self is the time difference t2 - t1
     rest, mins = rest.divmod( 60 )
     days, hours = rest.divmod( 24 )

     result = []
     result << "#{days}D " if days > 0
     result << "#{hours}h" if hours > 0
     result << "#{mins}m" if mins > 0
     result << "#{secs.to_i}s" if secs.to_i > 0
     return result.join(' ')
    end
end
