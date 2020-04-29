require 'yaml'
require 'fileutils'
require 'keychain'

module MergetrainCheck
  class AuthTokenStorage
    KEYCHAIN_SERVICE_NAME = 'mergetrain_check'
    def initialize(host)
      @host = host
      @kitem = Keychain.generic_passwords.where(service: KEYCHAIN_SERVICE_NAME).all.detect { |k| k.account == host }
      @kitem = Keychain.generic_passwords.create(service: KEYCHAIN_SERVICE_NAME, password: 'secret', account: host) if @kitem.nil?
    end

    def password
      return @kitem.password
    end

    def password=(value)
      @kitem.password = value
    end

    def save!
      @kitem.save!
    end
  end

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
      @tokenStorage = AuthTokenStorage.new(value)
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
      @tokenStorage = AuthTokenStorage.new(gitlab_host)
      @tokenStorage.password = @config[:token]
    end

    def initialize(file = DEFAULT_CONFIG_FILE)
      if File.exist?(file)
        @config = YAML.load(File.read(file))
        @config = {} if @config.nil?
      else
        @config = {}
      end
      @tokenStorage = AuthTokenStorage.new(gitlab_host)
      @config[:token] = @tokenStorage.password
    end

    def save!(file = DEFAULT_CONFIG_FILE)
      File.open(file, 'w') { |f| f.write(@config.to_yaml) }
      @tokenStorage.save!
    end
  end
end

