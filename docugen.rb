#!/usr/bin/env ruby -w

require "jcode"

require "common.rb"
require "regexes.rb"
require "bbdoc.rb"
require "bbtype.rb"
require "sourcepage.rb"

# testing
page = BBSourcePage.new("test.bmx")
page.process()
