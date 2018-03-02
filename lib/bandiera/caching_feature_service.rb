# frozen_string_literal: true

require 'lru_redux'

module Bandiera
  class CachingFeatureService < SimpleDelegator
    DEFAULT_CACHE_SIZE = 100
    DEFAULT_CACHE_TTL  = 10

    attr_reader :cache

    def initialize(delegate, cache_size: DEFAULT_CACHE_SIZE, cache_ttl: DEFAULT_CACHE_TTL)
      @cache = LruRedux::TTL::ThreadSafeCache.new(cache_size || DEFAULT_CACHE_SIZE, cache_ttl || DEFAULT_CACHE_TTL)

      super(delegate)
    end

    def find_group(name)
      cache.getset(:"find_group:#{name}") { super }
    end

    def fetch_groups
      cache.getset(:fetch_groups) { super }
    end

    def fetch_group_features(group)
      cache.getset(:"fetch_group_features:#{group}") { super }
    end

    def fetch_feature(group, feature_name)
      cache.getset(:"fetch_feature:#{group}:#{feature_name}") { super }
    end

    def add_group(audit_context, group)
      cache.delete(:"find_group:#{group}")
      cache.delete(:fetch_groups)

      super
    end

    def add_feature(audit_context, data)
      cache.delete(:"fetch_feature:#{data[:group]}:#{data[:name]}")
      cache.delete(:"fetch_group_features:#{data[:group]}")

      super
    end

    def add_features(audit_context, features)
      features.each do |data|
        cache.delete(:"fetch_feature:#{data[:group]}:#{data[:name]}")
        cache.delete(:"fetch_group_features:#{data[:group]}")
      end

      super
    end

    def remove_feature(audit_context, group, feature_name)
      cache.delete(:"fetch_feature:#{group}:#{feature_name}")
      cache.delete(:"fetch_group_features:#{group}")

      super
    end

    def update_feature(audit_context, group, feature_name, feature_data)
      cache.delete(:"fetch_feature:#{group}:#{feature_name}")
      cache.delete(:"fetch_group_features:#{group}")

      super
    end
  end
end
