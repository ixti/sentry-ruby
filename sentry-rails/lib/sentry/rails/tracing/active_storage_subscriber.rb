# frozen_string_literal: true

require "sentry/rails/tracing/abstract_subscriber"

module Sentry
  module Rails
    module Tracing
      class ActiveStorageSubscriber < AbstractSubscriber
        EVENT_NAMES = %w[
          service_upload.active_storage
          service_download.active_storage
          service_streaming_download.active_storage
          service_download_chunk.active_storage
          service_delete.active_storage
          service_delete_prefixed.active_storage
          service_exist.active_storage
          service_url.active_storage
          service_mirror.active_storage
          service_update_metadata.active_storage
          preview.active_storage
          analyze.active_storage
        ].freeze

        SPAN_ORIGIN = "auto.file.rails"

        def self.subscribe!
          subscribe_to_event(EVENT_NAMES) do |event_name, duration, payload|
            record_on_current_span(
              op: "file.#{event_name}",
              origin: SPAN_ORIGIN,
              start_timestamp: payload[START_TIMESTAMP_NAME],
              description: payload[:service],
              duration: duration
            ) do |span|
              payload.each do |key, value|
                next if key == START_TIMESTAMP_NAME
                next if key == :key && !Sentry.configuration.send_default_pii

                span.set_data(key, value)
              end
            end
          end
        end
      end
    end
  end
end
