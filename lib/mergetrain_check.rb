require "mergetrain_check/version"

module MergetrainCheck
  class Error < StandardError; end
  
  class Command
    def run(argv)
      options = {}
      printers = Array.new
      OptionParser.new do |opts|
        opts.banner = "Usage: mergetrain_check [options]\n"
        opts.on("-f", "--filters FILTERS", Array, "File extension filters") do |filters|
          options[:filters] = filters
        end
        opts.on("-x", "--duplicates-hex", "Prints duplicate files by MD5 hexdigest") do |dh|
          printers << "dh"
        end
        opts.on("-d", "--duplicates-name", "Prints duplicate files by file name") do |dh|
          printers << "dn"
        end
        opts.on("-s", "--singles-hex", "Prints non-duplicate files by MD5 hexdigest") do |dh|
          printers << "sh"
        end
        opts.on("-n", "--singles-name", "Prints non-duplicate files by file name") do |dh|
          printers << "sn"
        end
      end.parse!
    end
  end

end
