# Recursively scan a directory (default: .) for *.mp3 files.  Create a Track
# object for each new artist-album combination discovered.

namespace :websinger do

  desc 'Discover new tracks to add to the music library.'
  task :scan, :path, :verbose, :error_file, :needs => [:environment] do |t, args|
    require 'find'
    
    root = args.path || '.'
    verbose = args.verbose || false
    error_file = args.error_file || 'scan-errors.log'
    discovered_count = 0
    error_count = 0
    
    puts "Adding tracks from: #{root}"
    puts "Verbose: #{verbose}"
    puts "Reporting problems to: #{error_file}"
    
    File.open(error_file, 'a') do |efile|
      Find.find(root) do |path|
        begin
          next unless path =~ /\.mp3$/
        rescue ArgumentError => e
          message = "Not added: #{path}\t#{e}"
          efile.puts message
          puts message if verbose
        end
        
        t = Track.read_from path
        if t.save
          message = "Discovered: #{path}"
          discovered_count += 1
        else
          message = "Not added: #{path}"
          
          efile.puts message
          efile.puts " #{t.errors.full_messages.join ', '}"
          
          error_count += 1
        end
        
        puts message if verbose
      end
    end
    
    puts "Complete.  Found:"
    puts "  #{discovered_count} new tracks" if discovered_count > 0
    puts "  #{error_count} problems" if error_count > 0
  end

end
