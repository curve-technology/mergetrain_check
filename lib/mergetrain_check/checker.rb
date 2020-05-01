require 'net/http'
require 'json'

module MergetrainCheck
  class Checker
    def max_count
      @max_count
    end

    def max_completed=(value)
      @max_completed = value
    end

    def initialize(host, token, id)
      @host = host
      @token = token
      @id = id
      @max_count = 10
    end

    def check
      Net::HTTP.start(active_uri.host, active_uri.port, :use_ssl => active_uri.scheme == 'https') do |http|
        get_and_parse(http, active_uri) + get_and_parse(http, completed_uri)
      end
    end

    private

    def get_and_parse(http, uri)
      request = Net::HTTP::Get.new uri
      request['PRIVATE-TOKEN'] = @token

      response = http.request request
      JSON.parse response.body
    end

    def completed_uri
      URI("https://#{@host}/api/v4/projects/#{@id}/merge_trains?per_page=#{@max_completed}&scope=complete")
    end

    def active_uri
      URI("https://#{@host}/api/v4/projects/#{@id}/merge_trains?per_page=100&scope=active")
    end
  end
end

