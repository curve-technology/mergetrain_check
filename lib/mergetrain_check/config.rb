require 'yaml'
require 'fileutils'

module MergetrainCheck
  DEFAULT_CONFIG_FILE = File.expand_path('~/.mergetraincheck')

  class FileNotFoundError < StandardError
    def initialize(description)
      super(description)
    end
  end

  class Config
    def gitlab_host
      @config[:host] || "www.gitlab.com"
    end

    def gitlab_host=(value)
      @config[:host] = value
    end

    def auth_token
      @config[:token]
    end

    def auth_token=(value)
      @config[:token] = value
    end

    def project_id
      @config[:project_id]
    end

    def project_id=(value)
      @config[:project_id] = value
    end

    def merge!(config_hash)
      @config.merge! config_hash
    end

    def initialize(file = DEFAULT_CONFIG_FILE)
      if File.exist?(file)
        @config = YAML.load(File.read(file))
        @config = {} if @config.nil?
      else
        @config = {}
      end
    end

    def save!(file = DEFAULT_CONFIG_FILE)
      File.open(file, 'w') { |f| f.write(@config.to_yaml) }
    end
  end
end

