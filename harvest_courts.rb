require 'csv'
require 'nokogiri'
require 'open-uri'
require 'optparse'

# read csv file with all delivery area postcodes
# for each postcode, hit tennis australia and retrieve the list of tennis courts for the postcode
# for each tennis court, save the details into a csv file (name, courts, address, phone, website)

class HarvestCourts
  URL = 'http://www.tennis.com.au/?type=Clubs&s='

  def initialize(postcode_file, output_file, debug=false)
    @postcode_file = postcode_file
    @output_file = output_file
    @postcode_list = []
    @clubs = [%w(name courts address phone website latitude longitude)]
    @debug = debug
  end

  def from_tennis_australia
    load_australian_postcodes

    count = 0
    @postcode_list.each do |postcode|
      count += 1
      search_url = "#{URL}#{postcode.to_i}"
      puts search_url
      page = Nokogiri::HTML(open(search_url))
      number_of_clubs = page.at_css('.full .full strong').text[/([0-9]+)\D+([0-9]+)/, 2]

      unless number_of_clubs.nil?
        pages = number_of_pages(number_of_clubs)
        (1..pages).each do |num|
          extract_ta_clubs_info(page)
          if pages > num
            puts "#{search_url}&page=#{num + 1}"
            page = Nokogiri::HTML(open("#{search_url}&page=#{num + 1}"))
          end
        end
      end
    end

    save_ta_clubs
  end


  private

  def load_australian_postcodes
    if @postcode_list.empty?
      if File.file?(@postcode_file)
        CSV.foreach(@postcode_file, :headers => true) do |line|
          if line['Category'].downcase.include? 'delivery'
            @postcode_list << line['Pcode'] unless @postcode_list.include? line['Pcode']
          end
        end
      else
        puts "The file: #{@postcode_file} does not exist."
        exit
      end

      puts "loaded #{@postcode_list.size} postcodes."
    end
  end

  def number_of_pages(number_of_clubs)
    number_of_pages = 1
    float_result = number_of_clubs.to_f / 5
    int_result = number_of_clubs.to_i / 5
    if float_result > int_result
      number_of_pages += number_of_pages
    end

    number_of_pages
  end

  def extract_ta_clubs_info(page)
    page.css('.vcard').each do |vcard|
      name = vcard.at_css('.org').nil? ? '' : vcard.at_css('.org').text
      courts = vcard.at_css('.courts').nil? ? '' : vcard.at_css('.courts').text
      address = vcard.at_css('.adr').nil? ? '' : vcard.at_css('.adr').text
      phone = vcard.at_css('.tel').nil? ? '' : vcard.at_css('.tel').text
      website = (vcard.at_css('.outbound').nil? ? '' : vcard.at_css('.outbound')[:href])
      latitude = vcard.at_css('.lat').nil? ? '' : vcard.at_css('.lat').text
      longitude = vcard.at_css('.lng').nil? ? '' : vcard.at_css('.lng').text

      club_details = [name, courts, address, phone, website, latitude, longitude]
      @clubs << club_details unless @clubs.include? club_details

      if @debug
        puts 'name: ' + vcard.at_css('.org').text unless vcard.at_css('.org').nil?
        puts 'courts: ' + vcard.at_css('.courts').text unless vcard.at_css('.courts').nil?
        puts 'address: ' + vcard.at_css('.adr').text unless vcard.at_css('.adr').nil?
        puts 'phone: ' + vcard.at_css('.tel').text unless vcard.at_css('.tel').nil?
        puts 'website: ' + (vcard.at_css('.outbound').nil? ? 'no info' : vcard.at_css('.outbound')[:href])
        puts '=========================='
      end
    end
  end

  def save_ta_clubs
    CSV.open(@output_file, 'wb') do |csv|
      @clubs.each do |club|
        csv << club
      end
    end
  end

end

options = {}
parser = OptionParser.new do |opts|
  opts.banner = 'Usage: ruby harvest_courts.rb -f australia_post_file -o output_file'

  opts.on('-f', '--require FILE', 'The postcode file') do |f|
    options[:postcode_file] = f
  end

  opts.on('-o', '--require FILE', 'The output file') do |o|
    options[:output_file] = o
  end

  opts.on('-h', '--help', 'Display this screen') do
    puts opts
    exit
  end
end

begin 
  parser.parse!
  mandatory = [:postcode_file, :output_file]  
  missing = mandatory.select{|arg| options[arg].nil?} 
  unless missing.empty?                                    
    puts "Missing options: #{missing.join(', ')}"         
    puts parser                                          
    exit                                                
  end                                                  
rescue OptionParser::InvalidOption, OptionParser::MissingArgument 
  puts $ERROR_INFO.to_s                                                   
  puts parser                                                   
  exit                                                         
end                                                

harvest_courts = HarvestCourts.new(options[:postcode_file], options[:output_file])
harvest_courts.from_tennis_australia
