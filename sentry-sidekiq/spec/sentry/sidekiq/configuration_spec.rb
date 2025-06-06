# frozen_string_literal: true

require "spec_helper"

RSpec.describe Sentry::Sidekiq::Configuration do
  it "adds #delayed_job option to Sentry::Configuration" do
    config = Sentry::Configuration.new

    expect(config.sidekiq).to be_a(described_class)
  end

  it "adds Sidekiq::JobRetry::Skip to the ignore list" do
    config = Sentry::Configuration.new

    expect(config.excluded_exceptions).to include("Sidekiq::JobRetry::Skip")
  end

  it "adds Sidekiq::JobRetry::Handled to the ignore list" do
    config = Sentry::Configuration.new

    expect(config.excluded_exceptions).to include("Sidekiq::JobRetry::Handled")
  end

  describe "#report_after_job_retries" do
    it "has correct default value" do
      expect(subject.report_after_job_retries).to eq(false)
    end
  end

  describe "#report_only_dead_jobs" do
    it "has correct default value" do
      expect(subject.report_only_dead_jobs).to eq(false)
    end
  end

  describe "#propagate_traces" do
    it "has correct default value" do
      expect(subject.propagate_traces).to eq(true)
    end
  end
end
