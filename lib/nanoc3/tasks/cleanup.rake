# encoding: utf-8

desc 'Remove deprecated output files'
task :cleanup do
  # Load site
  site = Nanoc3::Site.new('.')
  if site.nil?
    $stderr.puts 'The current working directory does not seem to be a ' +
                 'valid/complete nanoc site directory; aborting.'
    exit 1
  end

  site.compiler.load

  have = site.items.map { |i| i.reps }.flatten.map { |r| r.raw_path }.find_all { |p| p }
  have += site.compiler.asset_registry.assets
  have = have.sort.uniq
  files = Dir[site.config[:output_dir] + '/**/*'].select { |i| File.file?(i) }

  files = files - have


  files.each do |f|
    puts "Removing " + f
    FileUtils.rm_f f
  end

  dirs = Dir[site.config[:output_dir] + '/**/*'].select { |i| File.directory?(i) }.sort_by{ |d| -d.length }
  dirs.each do |d|
    entries = Dir.entries(d).find_all { |e| e != '.' && e != '..' }
    next unless entries.empty?
    puts "Removing empty direcory " + d
    Dir.rmdir d
  end
end
