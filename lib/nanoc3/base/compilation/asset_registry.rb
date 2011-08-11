# encoding: utf-8

module Nanoc3

  class AssetRegistry < ::Nanoc3::Store

    def initialize(reps)
      super('tmp/assets', 1)
      @reps = reps
      @assets = { }
    end

    def assets
      @assets.values.flatten.sort.uniq
    end

    def register(rep, filename)
      (@assets[rep.reference] ||= []) << filename
    end

    def forget_assets_for(rep)
      @assets.delete(rep.reference)
    end

    def rep_outdated(rep)
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
