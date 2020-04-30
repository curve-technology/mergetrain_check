require 'optionparser'

module MergetrainCheck
  class ArgsParser
    def parse(args)
      options = {}
      parser = OptionParser.new do |opts|
        opts.banner = "Usage: mergetrain_check [options] [PROJECT-ID]\n" +
          "       PROJECT-ID: The project ID to fetch the merge train list from. If none specified, it will try to use the last one used.\n\n"
        opts.on("-t", "--token GITLAB-PERSONAL-TOKEN", "Gitlab API token (go to https://[gitlab_host]/profile/personal_access_tokens) to generate one.") do |t|
          options[:token] = t
        end
        opts.on("-n", "--host GITLAB-HOSTNAME", "Specify the Gitlab installation host (in case it's not gitlab.com)") do |host|
          options[:host] = host
        end
        opts.on("-v", "--verbose", "Verbose output (larger table)") do |verbose|
          options[:verbose] = verbose
        end
        opts.on("-h", "--help", "Prints this help") do
          puts opts
          return nil
        end
      end
      parser.parse!(args)
      options[:project_id] = args[0] if args.length > 0
      options

    end

  end
end

