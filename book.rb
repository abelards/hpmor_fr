class HPMOR
  BOOKS = [
    ["HJPEV & les Méthodes de la Rationalité" , (1..21).to_a - [11]], # 310p
    ["HJPEV & les Jeux du Professeur"         , (22..37).to_a],       # 249p
    ["HJPEV & les Ombres de la Mort"          , (38..63).to_a],       # 327p
    ["HJG & l'Appel du Phénix"                , (65..85).to_a],       # 313p
    ["HJPEV & le Dernier Ennemi"              , (86..99).to_a],       # 182p
    ["HJPEV & la Pierre Philosophale"         , (100..122).to_a],     # 245p
    ["HPMOR - Omake"                          , [11,64]]              # 22p
   ]

  SUBST = {
    'HPMOR' => "Harry Potter & the Methods of Rationality",
    'HJPEV' => "Harry James Potter-Evans-Verres",
    'HJG'   => "Hermione Jean Granger"
  }

  attr_reader :debug, :test

  def initialize(debug=false, test=nil)
    @debug = debug
    @test = test
  end

  def mkdirs
    ((1..BOOKS.size).to_a.map{|x| "book-#{n}"} + ['htm', 'md']).map{|x| Dir.mkdir(x) }
  end

  def fetch
    Fetcher.new.run(BOOKS.size)
  end

  def make(n = @test)
    if n
      info = BOOKS[n - 1]
      Book.new(info.first, info.last, n, @debug).make
    else
      BOOKS.each_with_index{|info, i|
        Book.new(info.first, info.last, i + 1).make
      }
    end
  end
  
end

class Book
  require 'fileutils'
  attr_reader :number, :title, :chapters, :debug

  # Cover & TOC provided by wkhtmltopdf
  OPENING = [:thanks, :blank, :opening]
  CLOSING = [:blank, :closing]

  PAGESIZE = 'A5' # let's experiment more later

  WKOPTS = [#'--book', # not OK with some of these
    # '--zoom 1.10' # '--viewport-size 1' # '--header-line',
    "--page-size #{PAGESIZE} --outline",
    '--print-media-type', ' --disable-smart-shrinking',
    '--footer-center "[page]" --footer-spacing 2',
    '--header-center "[section]" --header-spacing 2',
    '--toc --toc-header-text "Table des Matières"',
  ].join(" ")

  def initialize(title, chapters, n=0, debug=false)
    @title, @chapters, @number, @d, @debug = title, chapters, n, "book-#{n}", debug
    HPMOR::SUBST.map{|k,v| @title.gsub!(Regexp.new(k), v) }
    @book = File.join(@d, 'Book.txt')
    @md = File.join(@d, 'book.md')
  end

  def page(p, fname="#{p}.md")
    return p if p.is_a?(String)
    File.open(File.join(@d, fname), 'w') {|x| x.puts self.send(p) }
    File.join(@d, fname)
  end

  def make
    book = OPENING.map{|p| page(p)}
    book << '<div class="book">' # helps for CSS styling
    book += ([0] + @chapters).map {|i| n = '%03i' % i
      File.join('md', "hpmor_fr_#{n}.md")
    }
    book << '</div>'
    book += CLOSING.map{|p| page(p)}
    File.open(@book, 'w') {|f| f.puts book }
    puts [@title, book] # logger

    File.open(@md, 'w') {|md|
      md.puts (['styles.html'] + book).map{|f|
        File.exists?(f) ? IO.readlines(f) : f
      }
    }

    cmd = @debug ?
      "gimli -debug -f #{@md} -w '--cover ./#{@d}/cover.html #{WKOPTS}' >> debug.htm" :
      "gimli -f #{@md} -w '--cover ./#{@d}/cover.html #{WKOPTS}'"
    puts cmd
    `#{cmd}`

    FileUtils.mv('book.pdf', "HPMOR_FR_#{@number}.pdf")
  end

  def cover
    # image et fond noir ?
    title = @title.split(/(&)/).join('<br />')
    File.open(File.join(@d, "cover.html"), 'w') {|f|
      a = IO.readlines('cover.html').join("\n")
      f.puts a.gsub('TITLE', title).gsub('NUMBER', @number.to_s).gsub('LOGO',
        File.expand_path('hpmor_logo.png'))
    }
    %Q[<h1> #{HPMOR::SUBST['HPMOR']}</h1>
    <h2>Livre #{@number}</h2>
    <h2>#{@title}</h2>]
  end

  def blank
    '<br class="page_break" />'
  end

  def thanks
    File.read('thanks.md')
  end

  def opening
    # TODO: filigrane
    self.cover.gsub(/<h2>/, '<p class="book-title">').gsub(/<\/h2>/, '</p>')
  end

  # deprecated
  def toc
    %Q[\# Table of Contents
      {:toc}]
  end

  def closing
    # 4e de couverture
    # fond noir
    %Q[<br class="page_break" />
    <img src="#{File.expand_path('hpmor_logo.png')}" style="opacity: 0.8" />
    <p class="book-title">Livre #{@number}</p>
    <p class="book-title">#{@title}</p>]
  end

end


class Fetcher
  def fetch(i)
    # less problems as soon as that's on GitHub
    n = '%03i' % i
    # please scrape responsibly `https://www.fanfiction.net/s/6910226/#{i}` to `htm/hpmor_fr_#{n}.htm`
  end

  def logo
    # please scrape responsibly `http://hpmor.com/hpmor_logo.png` to `hpmor_logo.png`
  end

  def extract(i)
    n = '%03i' % i
    txt = File.read("htm/hpmor_fr_#{n}.htm")

    title = /<title>Harry Potter et les Méthodes de la Rationalité Chapter (\d*): (.*), a harry potter fanfic | FanFiction<\/title>/
    body = /<div class='storytext xcontrast_txt nocopy' id='storytext'>(.*)<\/div>.?<\/div><div style='height:5px'>/m

    txt =~ title
    titre = Regexp.last_match.to_a.last

    txt =~ body
    texte = Regexp.last_match.to_a.last

    File.open(File.join("md", "hpmor_fr_#{n}.md"), 'a') {|f|
      f.puts "\# #{i}. #{titre}"
      f.puts texte
    }
  end

  def run
    logo
    (1..122).map{|i| fetch(i); extract(i) }
  end
end
