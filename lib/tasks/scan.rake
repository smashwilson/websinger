# Recursively scan a directory (default: .) for *.mp3 files.  Create a Track
# object for each new artist-album combination discovered.

namespace :websinger do

  desc 'Discover new tracks to add to the music library.'
  task :scan, [:path, :verbose, :error_file] => [:environment] do |t, args|
    require 'find'

    root = args.path || '.'
    verbose = args.verbose || false
    error_file = args.error_file || 'scan-errors.log'

    discovered_count = 0
    updated_count = 0
    error_count = 0

    puts "Adding tracks from: #{root}"
    puts "Verbose: #{verbose}"
    puts "Reporting problems to: #{error_file}"

    File.open(error_file, 'a') do |efile|
      Find.find(root) do |path|
        unless path.valid_encoding?
          error_count += 1
          message = "Not added: #{path}"
          
          efile.puts message
          efile.puts " Invalid path encoding."
          next
        end

        next unless path =~ /\.mp3$/

        # Update the existing record corresponding to this path, if one is present.
        t = Track.find_or_initialize_by_path(path)
        action = t.persisted? ? 'Updated' : 'Discovered'
        
        t.update_from_path path
        if t.save
          message = "#{action}: #{path}"

          discovered_count += 1 if action == 'Discovered'
          updated_count += 1 if action == 'Updated'
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
    puts "  #{updated_count} updated tracks" if updated_count > 0
    puts "  #{error_count} problems" if error_count > 0
  end

end
