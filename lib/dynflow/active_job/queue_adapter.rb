module Dynflow
  module ActiveJob
    module QueueAdapters
      # To use Dynflow, set the queue_adapter config to +:dynflow+.
      #
      #   Rails.application.config.active_job.queue_adapter = :dynflow
      class DynflowAdapter
        extend ActiveSupport::Concern

        class << self
          def enqueue(job)
            ::Rails.application.dynflow.world.trigger(JobWrapper, job.serialize)
          end

          def enqueue_at(job, timestamp)
            ::Rails.application.dynflow.world.delay(JobWrapper, { :start_at => Time.at(timestamp) }, job.serialize)
          end
        end
      end

      class JobWrapper < Dynflow::Action
        def plan(attributes)
          input[:job_class] = attributes['job_class']
          input[:job_arguments] = attributes['arguments']
          plan_self
        end

        def run
          input[:job_class].constantize.perform_now(*input[:job_arguments])
        end

        def label
          input[:job_class]
        end
      end
    end
  end
end
