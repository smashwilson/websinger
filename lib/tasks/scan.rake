# Recursively scan a directory (default: .) for *.mp3 files.  Create a Track
# object for each new artist-album combination discovered.

namespace :websinger do

  desc 'Discover new tracks to add to the music library.'
  task :scan, :path, :verbose, :needs => [:environment] do |t, args|
    require 'find'
    
    root = args.path || '.'
    verbose = args.verbose || false
    discovered_count = 0
    error_count = 0
    
    puts "Adding tracks from: #{root}"
    puts "Verbose: #{verbose}"
    
    Find.find(root) do |path|
      next unless path =~ /\.mp3$/
      
      t = Track.read_from path
      if t.save
        message = "Discovered: #{path}"
        discovered_count += 1
      else
        message = "Not added: #{path}\n\t"
        message += t.errors.full_messages.join(', ')
        error_count += 1
      end
      
      puts message if verbose
    end
    
    puts "Complete.  Found:"
    puts "  #{discovered_count} new tracks" if discovered_count > 0
    puts "  #{error_count} not added" if error_count > 0
  end

end
