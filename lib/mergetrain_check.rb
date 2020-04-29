require 'mergetrain_check/config'
require 'mergetrain_check/args_parser'
require 'mergetrain_check/checker'
require 'mergetrain_check/formatter'

module MergetrainCheck
  class MissingConfigError < StandardError
    def initialize(description)
      super(description)
    end
  end

  class Command
    @host = "www.gitlab.com"
    @project = -1
    @token = -1

    def self.run!(args)
      config = Config.new
      parser = ArgsParser.new
      args = ArgsParser.new.parse(args)
      config.merge! args

      if config.auth_token.nil?
        raise MissingConfigError, "auth_token"
      end

      if config.project_id.nil?
        raise MissingConfigError, "project_id"
      end

      checker = Checker.new(config.gitlab_host, config.auth_token, config.project_id)
      traintable = checker.check

      formatter = TraintableFormatter.new 80, true
      puts formatter.format traintable
      config.save!
    end
  end
 end

