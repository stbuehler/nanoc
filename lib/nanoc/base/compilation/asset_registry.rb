# encoding: utf-8

module Nanoc

  # Stores which item representations depend on extraneous created files ("assets")
  # Some items (their reprenstations) might want to create assets from content,
  # for example inline latex to png helpers
  #
  # This store only tracks the dependency on filenames, it is the heplers/users
  # job to ensure that if multiple items depend on the same asset it
  # is created in a sane way.
  # A simple way to solve this is to use the hash of the content as filename.
  #
  # @api private
  class AssetRegistry < ::Nanoc::Store

    def initialize(reps)
      super('tmp/assets', 1)
      @reps = reps
      @assets = { }
    end

    # Starts listening for messages (`:compilation_started`) to clean
    # associated assets
    #
    # @return [void]
    def start
      Nanoc::NotificationCenter.on(:compilation_started, self) do |rep|
        # remove link to assets
        @assets.delete(rep.reference)
      end
    end

    # Stop listening for messages.
    #
    # @return [void]
    def stop
      Nanoc::NotificationCenter.remove(:compilation_started, self)
    end

    # @see Nanoc::Store#unload
    def unload
      @assets = { }
    end

    # @return [Array<String>] filenames of all registered assets
    def assets
      @assets.values.flatten.sort.uniq
    end

    # @api private
    def asset_mappings
      @assets
    end

    # Register an asset for an item representation
    #
    # @return [void]
    def register(rep, filename)
      (@assets[rep.reference] ||= []) << filename
    end

    # Remove reference to assets of an item representation
    # If other item representations use the same asset, the
    # asset won't be removed
    #
    # @return [void]
    def forget_assets_for(rep)
      @assets.delete(rep.reference)
    end

    # @return [bool] whether item representation is outdated due to missing asset
    def rep_outdated?(rep)
      @assets[rep.reference].to_a.any? { |fname| !File.exists?(fname) }
    end

  protected

    def data
      @assets
    end

    def data=(new_data)
      @assets = new_data
      refs = @reps.map { |r| r.reference }
      # delete old references
      (@assets.keys - refs).each do |r|
        puts "Rep #{r} was deleted"
        @assets.delete(r)
      end
    end
  end

end
