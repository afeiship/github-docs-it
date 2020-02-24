#!/usr/bin/env ruby

require "thor"
require "fileutils"

TOKEN = ENV["GITHUB_API_TOKEN"]

class DocApp
  def initialize(name)
    @uri = URI("https://api.github.com/repos/afeiship/#{name}/pages")
    @http = Net::HTTP.new(@uri.host, @uri.port)
    @http.use_ssl = true

    @header = {
      'Accept': "application/vnd.github.switcheroo-preview+json",
      'Authorization': "token #{TOKEN}",
      'Content-Type': "application/vnd.api+json",
    }

    @data = {
      "source": {
        "branch": "master",
        "path": "/docs",
      },
    }
  end

  def del
    @req = Net::HTTP::Delete.new(@uri.path, @header)
    @http.request(@req)
  end

  def create
    @req = Net::HTTP::Post.new(@uri.path, @header)
    @req.body = @data.to_json
    @http.request(@req)
  end

  def docit
    del
    create
    puts "Has set master/docs to gh-pages!"
  end
end

module ThorCli
  class GithubDocsIt < Thor
    desc "docit NAME", "Set github docs dir for pages."

    def docit(name)
      app = DocApp.new(name)
      app.docit
    end

    def self.exit_on_failure?
      false
    end
  end
end

ThorCli::GithubDocsIt.start(ARGV)

# ruby src/index.rb hello boilerplate-book-notes
