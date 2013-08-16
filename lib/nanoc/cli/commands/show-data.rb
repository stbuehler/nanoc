# encoding: utf-8

usage       'show-data'
aliases     :debug
summary     'show data in this site'
description <<-EOS
Show information about all items, item representations and layouts in the
current site, along with dependency information.
EOS

module Nanoc::CLI::Commands

  class ShowData < ::Nanoc::CLI::CommandRunner

    def run
      # Make sure we are in a nanoc site directory
      print "Loading site data... "
      self.require_site
      puts "done"
      puts

      # Get data
      items   = self.site.items
      reps    = items.map { |i| i.reps }.flatten
      layouts = self.site.layouts

      # Get dependency tracker
      compiler = self.site.compiler
      compiler.load
      dependency_tracker = compiler.dependency_tracker

      assets = compiler.asset_registry.asset_mappings
      assets_reverse = {}
      assets.each do |rep,fnames|
        fnames.each do |fname|
          (assets_reverse[fname] ||= []) << rep
        end
      end

      # Print item dependencies
      puts '=== Item dependencies ======================================================='
      puts
      items.sort_by { |i| i.identifier }.each do |item|
        puts "item #{item.identifier} depends on:"
        predecessors = dependency_tracker.objects_causing_outdatedness_of(item).sort_by { |i| i ? i.identifier : '' }
        predecessors.each do |pred|
          if pred
            puts "  [ #{format '%6s', pred.type} ] #{pred.identifier}"
          else
            puts "  ( removed item )"
          end
        end
        puts "  (nothing)" if predecessors.empty?
        puts
      end

      # Print representation paths
      puts '=== Representation paths ===================================================='
      puts
      items.sort_by { |i| i.identifier }.each do |item|
        item.reps.sort_by { |r| r.name.to_s }.each do |rep|
          puts "item #{item.identifier}, rep #{rep.name}:"
          if rep.raw_paths.empty?
            puts "  (not written)"
          end
          length = rep.raw_paths.keys.map { |s| s.to_s.length }.max
          rep.raw_paths.each do |snapshot_name, raw_path|
            puts "  [ %-#{length}s ] %s" % [ snapshot_name, raw_path ]
          end
        end
        puts
      end

      # Print representation outdatedness
      puts '=== Representation outdatedness ============================================='
      puts
      items.sort_by { |i| i.identifier }.each do |item|
        item.reps.sort_by { |r| r.name.to_s }.each do |rep|
          puts "item #{item.identifier}, rep #{rep.name}:"
          outdatedness_reason = compiler.outdatedness_checker.outdatedness_reason_for(rep)
          if outdatedness_reason
            puts "  is outdated: #{outdatedness_reason.message}"
          else
            puts "  is not outdated"
          end
        end
        puts
      end

      # Print layout dependencies
      puts '=== Layout dependencies ====================================================='
      puts
      layouts.sort_by { |l| l.identifier }.each do |layout|
        puts "layout #{layout.identifier} depends on:"
        predecessors = dependency_tracker.objects_causing_outdatedness_of(layout).sort_by { |i| i ? i.identifier : '' }
        predecessors.each do |pred|
          if pred
            puts "  [ #{format '%6s', pred.type} ] #{pred.identifier}"
          else
            puts "  ( removed item )"
          end
        end
        puts "  (nothing)" if predecessors.empty?
        puts
      end

      # Print layouts
      puts '=== Layouts'
      puts
      layouts.sort_by { |l| l.identifier }.each do |layout|
        puts "layout #{layout.identifier}:"
        outdatedness_reason = compiler.outdatedness_checker.outdatedness_reason_for(layout)
        if outdatedness_reason
          puts "  is outdated: #{outdatedness_reason.message}"
        else
          puts "  is not outdated"
        end
        puts
      end

      # Print assets
      puts '=== Assets'
      puts
      assets_reverse.keys.sort.each do |asset|
        puts "asset #{asset}:"
        assets_reverse[asset].each do |rep|
          puts "  used by item #{rep[1]}, rep #{rep[2].to_s}"
        end
        puts
      end
    end

  end

end

runner Nanoc::CLI::Commands::ShowData
