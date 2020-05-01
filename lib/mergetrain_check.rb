require 'mergetrain_check/config'
require 'mergetrain_check/args_parser'
require 'mergetrain_check/checker'
require 'mergetrain_check/formatter'
require 'mergetrain_check/error'

module MergetrainCheck

  class MissingConfigError < CheckerError; end

  class Command
    @host = "www.gitlab.com"
    @project = -1
    @token = -1

    def self.run!(args)
      config = Config.new
      parser = ArgsParser.new
      args = ArgsParser.new.parse(args)
      return if args.nil?
      config.merge! args

      if config.auth_token.nil?
        raise MissingConfigError, "auth_token"
      end

      if config.project_id.nil?
        raise MissingConfigError, "project_id"
      end

      checker = Checker.new(config.gitlab_host, config.auth_token, config.project_id)
      checker.max_completed = config.limit
      traintable = checker.check

      text_length = config.verbose ? 160: 80
      first_name_only = !config.verbose
      formatter = TraintableFormatter.new text_length, first_name_only
      puts formatter.format traintable
      config.save!
    end
  end
 end

