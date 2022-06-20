# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module SDK
    module Metrics
      module State
        class MetricStream
          attr_reader :name, :description, :unit, :instrument_kind, :resource, :instrumentation_library, :data_points

          def initialize(
            name,
            description,
            unit,
            instrument_kind,
            resource,
            instrumentation_library
          )
            @name = name
            @description = description
            @unit = unit
            @instrument_kind = instrument_kind
            @resource = resource
            @instrumentation_library = instrumentation_library

            @data_points = {}
            @mutex = Mutex.new
          end

          def update(measurement)
            @mutex.synchronize do
              if @data_points[measurement.attributes]
                @data_points[measurement.attributes] = @data_points[measurement.attributes] + measurement.value
              else
                @data_points[measurement.attributes] = measurement.value
              end
            end
          end

          def to_s
            instrument_info = String.new
            instrument_info << "name=#{@name}"
            instrument_info << " description=#{@description}" if @description
            instrument_info << " unit=#{@unit}" if @unit
            @data_points.map do |attributes, value|
              metric_stream_string = String.new
              metric_stream_string << instrument_info
              metric_stream_string << " attributes=#{attributes}" if attributes
              metric_stream_string << " #{value}"
              metric_stream_string
            end.join("\n")
          end
        end
      end
    end
  end
end
