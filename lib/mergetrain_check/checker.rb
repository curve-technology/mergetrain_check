require 'net/http'
require 'json'

module MergetrainCheck
  class Checker
    def initialize(host, token, id)
      @host = host
      @token = token
      @id = id
      @uri =  URI("https://#{host}/api/v4/projects/#{id}/merge_trains")
    end

    def check
      Net::HTTP.start(@uri.host, @uri.port, :use_ssl => @uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new @uri
      request['PRIVATE-TOKEN'] = @token

      response = http.request request
      JSON.parse response.body
      end
    end
  end
end
