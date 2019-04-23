=begin
## Description

A tool for Octopress to generate IDs in header tags and index list aside. It helps you easily build a tutorial page with many chapters.

## Features

*   Support all languages.

## Syntax

    {{ page.indexer_aside }}

    or

    {{ content | indexer }}
    {{ content | indexer_aside }}

## Usage

1.  Download [Indexer for Octopress](/downloads/code/indexer.rb) into `source/plugins`
2.  This plugin should be used in pages with a variable `indexer` being `true`, for example:

         ---
         layout: page
         title: "Getting start with Indexer for Octopress"
         indexer: true
         ---
         ## Chapter 1

         blablabla...

         ### Chapter 1.1

         blablabla...

         ### Chapter 1.2

         blablabla...

         ## Chapter 2

    Note that your page cannot contain any h1 tag (Because h1 has been used for your title).

3.  You will need an aslide to make it work, for example:

    In `source\_includes\custom\asides\indexer.html`

        {% if page.indexer == true %}
          <section>
          <h1>Catalog</h1>
          {{ page.indexer_aside }}
          </section>
        {% else %}
          {% if site.page_asides.size %}
            {% include_array default_asides %}
          {% endif %}
        {% endif %}

4.  Don't forget to edit `_config.yml`:

        page_asides: [custom/asides/indexer.html]

5.  That's it! Headers in your page will be given an unique ID, and `{{ page.indexer_aside }}` will generate a 2 level nested list with anchors to each header.

## Troubleshooting

### Alternative Way

Becasue this plugin uses some hacking way (Override Jekyll methods) for porviding easy usage. You can use `{{ content | indexer }}` or `{{ content | indexer_aside }}`

*   `{{ content | indexer }}`

    If the content contains HTML header tag, this filter will give IDs to each header. That is, you have to edit `source\_layouts\page.html` like:

        - {{ content }}
        + {% if page.indexer %}
        +   {{ content | indexer }}
        + {% else %}
        +   {{ content }}
        + {% endif %}

*   `{{ content | indexer_aside }}`

    If the content contains HTML header tag, this filter will convert it into a list usded for aside. Then in `source\_includes\custom\asides\indexer.html`:

        {% if page.indexer == true %}
          <section>
          <h1>Catalog</h1>
          {{ content | indexer_aside }}
          </section>
        {% else %}
          {% if site.page_asides.size %}
            {% include_array default_asides %}
          {% endif %}
        {% endif %}

### Not Work

Try removing `Page` class in `indexer.rb`, and keep using alternative way.

## Still Not Work

tonytonyjan(at)gmail(dot)com
 
## Licence

Distributed under the [MIT License][MIT].
 
[MIT]: http://www.opensource.org/licenses/mit-license.php
=end

require 'digest'
require 'strscan'

module Jekyll
  class Indexer
    attr_reader :body, :result, :result_list, :level_hash

    def initialize(body)
      @body     = body
      @result   = @body.dup
    end

    def index
      @level_hash = process(body)
      @result_list = gen_list
      return @level_hash
    end

    private

    def process(string, current_level=2, counters=[1])
      s = StringScanner.new(string)

      level_hash = {}

      while !s.eos?
        re = %r{^<\s*h(\d)\s*(?:id="([^"]*?)")?\s*>(.*)<\s*/h\1\s*>$}
        s.match?(re)
        if matched = s.matched
          matched =~ re
          level, idx, title = $1.to_i, $2, $3.strip 

          if level < current_level
            # This is needed. Go figure.
            return level_hash
          elsif level == current_level
            index = counters.join(".")
            idx_raw = title_to_idx(title)
            idx ||= '#' + idx_raw

            raise "Parsing Fail" unless @result.sub!(matched, "<h#{level} id=\"#{idx_raw}\">#{index} #{title}</h#{level}>")

            key = {
              :title => title,
              :id => idx
            }
            # Recurse
            counters << 1
            level_hash[key] = process(s.post_match, current_level + 1, counters)
            counters.pop

            # Increment the current level
            last = counters.pop
            counters << last + 1
          end
        end
        s.getch
      end
      level_hash
    end

    def title_to_idx(title)
      #idx = title=~/[^\u0000-\u007F]/ ? ("id-"+Digest::MD5.hexdigest(title.strip)) : title.strip
      #idx = idx.parameterize.sub(/^\d+/, '')
      puts "BLANK ID: please put an explicit ID for section #{title}, as in h5(#my-id)" if title.strip == ""
      idx = ("id-"+Digest::MD5.hexdigest(title.strip))
      
      idx
    end
    
    def gen_list
      index = "<ol style=\"margin-left: 1.3em;\">"

      # Set index for 2 levels
      level_hash.each do |key, value|
        link = "<a href=\"#{key[:id]}\">#{key[:title]}</a>"

        children = value.keys.map do |k|
          "<li style=\"list-style:inherit;\"><a href=\"#{k[:id]}\">#{k[:title]}</a></li>"
        end

        children_ul = children.empty? ? "" : "<ul style=\"margin-left: 1.3em;\">#{children.join(" ")}</ul>"

        index << "<li style=\"list-style:inherit;\">#{link + children_ul}</li>"
      end
      
      index << "</ol>"
    end
  end

  class Page
    # override
    def initialize(site, base, dir, name)
      @site = site
      @base = base
      @dir  = dir
      @name = name

      self.process(name)
      self.read_yaml(File.join(base, dir), name)
      # tonytonyjan:
      if self.data["indexer"] == true
        i = Indexer.new(converter.convert(self.content))
        i.index
        data["indexer_aside"] = i.result_list
      end
      # :tonytonyjan
    end
    
    # override
    def transform
      self.content = converter.convert(self.content)
      
      # tonytonyjan:
      if self.data["indexer"] == true
        i = Indexer.new(self.content)
        i.index
        self.content = i.result
      end
      self.content
      # :tonytonyjan
    end
  end
  
  module IndexerFilter
    def indexer(input)
      i = Indexer.new(input)
      i.index
      i.result
    end
  end
  
  module IndexerAsideFilter
    def indexer_aside(input)
      i = Indexer.new(input)
      i.index
      i.result_list
    end
  end
end

Liquid::Template.register_filter(Jekyll::IndexerFilter)
Liquid::Template.register_filter(Jekyll::IndexerAsideFilter)
