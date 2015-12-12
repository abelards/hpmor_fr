require './book.rb'

case ARGV.first
when 'init', '-i'
  # FIRST RUN
  h = HPMOR.new
  h.mkdirs
  h.fetch
when 'test', '-t'
  n = ARGV[1].to_i
  n = 7 if n == 0
  HPMOR.new(:debug, n).make
when 'help', '-h'
  puts %q[Usage: call the script with a command
  hpmorfr.rb CMD
  # Command  flag  # you can use either the full command or a flag
    help     -h    # displays this help
    init     -i    # makes directories and fetches the source
    test     -t    # only renders the seventh book
    test N   -t N  # only renders book number N (between 1 and 7)
    (no command)   # makes the seven books if you already have the source
]

else
  HPMOR.new.make
end
