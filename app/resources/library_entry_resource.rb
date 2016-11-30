require 'unlimited_paginator'

class LibraryEntryResource < BaseResource
  attributes :status, :progress, :reconsuming, :reconsume_count, :notes,
    :private, :rating, :updated_at

  filters :user_id, :media_id, :media_type, :status

  filter :status, apply: ->(records, values, _options) {
    statuses = LibraryEntry.statuses.values_at(*values).compact
    statuses = values if statuses.empty?
    records.where(status: statuses)
  }

  has_one :user
  has_one :review
  has_one :media, polymorphic: true
  has_one :unit, polymorphic: true, eager_load_on_include: false

  paginator :unlimited
end
