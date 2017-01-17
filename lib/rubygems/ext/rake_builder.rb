# frozen_string_literal: true
#--
# Copyright 2006 by Chad Fowler, Rich Kilmer, Jim Weirich and others.
# All rights reserved.
# See LICENSE.txt for permissions.
#++

require 'shellwords'

class Gem::Ext::RakeBuilder < Gem::Ext::Builder
  MKRF_CONF_FILENAME = /mkrf_conf/i
  
  def self.build(extension, directory, dest_path, results, args=[], lib_dir=nil)
    if File.basename(extension) =~ MKRF_CONF_FILENAME
      cmd = "#{Gem.ruby} #{File.basename(extension)}".dup
      cmd << " #{args.join(' ')}" unless args.empty?
      run cmd, results
    end

    dest_path = if Gem.win_platform? # TODO: Know for sure this matches CMD only
      # Deal with possible spaces and quotes in the path, e.g. C:/Program Files
      '"' + dest_path.to_s.gsub('"', '""') + '"'
    else
      dest_path.to_s.shellescape
    end

    cmd = "#{rake} RUBYARCHDIR=#{dest_path} RUBYLIBDIR=#{dest_path}" # ENV is frozen

    run cmd, results

    results
  end

  def self.rake
    rake = ENV['rake']

    rake ||= begin
               "#{Gem.ruby} -rubygems #{Gem.bin_path('rake', 'rake')}"
             rescue Gem::Exception
             end

    rake ||= Gem.default_exec_format % 'rake'
    rake
  end
end

