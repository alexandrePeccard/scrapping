require 'rubygems'
require 'nokogiri'
require 'open-uri'

class Parser
	attr_accessor :nokogiri, :base_url

	def initialize
		@nokogiri = Nokogiri::HTML
		@base_url = ""
	end

	def clean_url(url)
		return "http://annuaire-des-mairies.com" + url.inner_html.split('.')[1] + ".html"
	end

	def get_the_email_of_a_townhal_from_its_webpage(url)
		url = clean_url(url)
		data = get_content(url)
		email = ""
		data.css('table tbody tr td').each do | line | 
			begin
				email = line.inner_html if /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i.match?(line.inner_html)
			rescue StandardError => e
				puts e.class
				puts e.message
			end
		end

		return email
	end

	def get_content(url)
		return Nokogiri::HTML(open(url))
	end

	def get_all_the_urls_of_val_doise_townhalls(url)
		data = get_content(url)
		links = []
		data.css('body table tr td .lientxt @href').each { | link | links << link }

		return links
	end

	#Scrapping des villes
	def scrapping_cities
		base_url = 'http://annuaire-des-mairies.com'
		links = get_all_the_urls_of_val_doise_townhalls('http://annuaire-des-mairies.com/val-d-oise.html')
		emails = []
		links.each do | url |
			email = get_the_email_of_a_townhal_from_its_webpage(url)
			myhash = { "test" => email }
			emails << myhash
		end

		puts emails
	end

	def scrapping_crypomonney
		base_url = 'https://coinmarketcap.com/all/views/all/'
		data = get_content(base_url)
		values = []
		data.css('table tr[id*="id-"]').each do |line|
			price = line.css('td')[4].css('a').inner_html
			brand = line.css('td')[1].css('a')[1].inner_html
			values << { brand => price }
		end
		return values
	end

	def scrapping_deputes
		base_url = "https://wiki.laquadrature.net/Contactez_vos_d%C3%A9put%C3%A9s"
		data = Nokogiri::HTML(open(base_url))
		members = []
		begin
			data.css('#mw-content-text ul li').each do | line |

				line.inner_html.split(" ").each do |tocheck|
					if /\w/.match?(tocheck)
						puts tocheck
						# return false
					end
					# puts "#{line[0]}#{line[1]}"
				# 	puts tocheck
				# 	# /<li>/
				# 	# return false
				# 	members << tocheck if /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i.match?(tocheck)
				end
			end
			return false
		rescue StandardError => e
			puts e.class
			puts e.message
		end

		return members
	end
end
parser = Parser.new
# parser.scrapping_cities
# puts parser.scrapping_crypomonney
parser.scrapping_deputes