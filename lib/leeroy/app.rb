#!/usr/bin/env rubhh

require 'ap'
require 'gli'

require 'leeroy'
require 'leeroy/task/instantiate'
require 'leeroy/task/terminate'
require 'leeroy/task/stub'

include GLI::App

module Leeroy
  module App

    program_desc 'Automate tasks with Jenkins'

    # global options
    desc 'Use in a pipeline (read state from stdin).'
    switch [:p, :pipe]

    desc "Perform the requested task (pass '--no-op' for testing)."
    switch [:op], :default_value => true

    desc 'Displays the version of leeroy and exits.'
    command :version do |c|
      c.action do |global_options,options,args|
        printf("leeroy %s\n", Leeroy::VERSION)
      end
    end

    desc "Displays leeroy's environment settings."
    command :env do |c|
      c.action do |global_options,options,args|
        ap Leeroy::Env.new
      end
    end

    desc "Instantiates an EC2 instance for imaging."
    command :instantiate do |c|

      valid_phase = ['gold_master','application']
      c.desc "Phase of deploy process for which to deploy (must be one of #{valid_phase.sort})."
      c.flag [:p, :phase], :must_match => valid_phase

      c.action do |global_options,options,args|
        # validate input
        if options[:phase].nil?
          help_now! "You must pass an argument for '--stage'."
        end

        task = Leeroy::Task::Instantiate.new(global_options: global_options, options: options, args: args)
        task.perform
      end
    end

    desc "Terminates an EC2 instance."
    command :terminate do |c|

      c.desc "Instance ID (or IDs as comma-delimited strings) to terminate (reads from state if none provided)."
      c.flag [:i, :instance], :type => Array

      c.action do |global_options,options,args|
        task = Leeroy::Task::Terminate.new(global_options: global_options, options: options, args: args)
        task.perform
      end
    end

    desc "Runs the stub task."
    command :stub do |c|
      c.desc "Amount by which to increment the stub value"
      c.flag [:i, :increment], :default_value => 1
      c.action do |global_options,options,args|
        task = Leeroy::Task::Stub.new(global_options: global_options, options: options, args: args)
        task.perform
      end
    end

    exit run(ARGV)
  end
end
