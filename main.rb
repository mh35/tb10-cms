#!/usr/bin/env ruby
#coding: utf-8

require 'csv'
require 'erb'
require 'fileutils'

class TemplateOutput
  def initialize(template='default.html.erb')
    tmpl_file = File.join('src/templates', template)
    File.open(tmpl_file, 'r') do |file|
      @template = ERB.new(file.read, trim_mode: '-')
    end
    @template.filename = tmpl_file
  end
  def output(input, output, title)
    @title = title
    File.open(input, 'r') do |file|
      @content = file.read
    end
    File.open(output, 'w') do |file|
      file.write @template.result(binding)
    end
  end
end

FileUtils.cp_r('src/assets', 'dst/assets')
FileUtils.rm('dst/.keep')
CSV.open('src/pages/pages.csv', 'r', headers: true) do |csv|
  csv.each do |row|
    dname = File.dirname(row['output'])
    fname = File.basename(row['output'])
    if dname == '.'
      out_dname = 'dst'
    else
      out_dname = File.join('dst', dname)
      FileUtils.mkdir_p(out_dname) unless File.exists?(
        out_dname)
    end
    out_fname = File.join(out_dname, fname)
    in_fname = File.join('src/pages', row['source'])
    title = row['title']
    out = TemplateOutput.new
    out.output(in_fname, out_fname, title)
  end
end
