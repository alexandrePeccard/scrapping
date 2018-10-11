require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'time'

class Parser
	attr_accessor :base_url
	
	def initialize
		@base_url = ""
	end

	def clean_url(url)
		begin
			url = [url.inner_html.split('.')[1].split('/')[2].capitalize, @base_url + url.inner_html.split('.')[1] + ".html"]
		rescue StandardError => e
			puts e.class
			puts e.message
		end

		return url 
	end

	def get_the_email_of_a_townhal_from_its_webpage(url)
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
		begin
			data.css('body table tr td .lientxt @href').each { | link | links << link }
		rescue StandardError => e
			puts e.class
			puts e.message
		end

		return links
	end

	def scrapping_cities
		@base_url = 'http://annuaire-des-mairies.com'
		links = get_all_the_urls_of_val_doise_townhalls('http://annuaire-des-mairies.com/val-d-oise.html')
		emails = []
		links.each do | url |
			city, url = clean_url(url)
			email = get_the_email_of_a_townhal_from_its_webpage(url)
			myhash = { city => email }
			emails << myhash
		end

		puts emails
	end

	def scrapping_crypomonney
		@base_url = 'https://coinmarketcap.com/all/views/all/'
		data = get_content(base_url)
		values = []
		data.css('table tr[id*="id-"]').each do |line|
			price = line.css('td')[4].css('a').inner_html
			brand = line.css('td')[1].css('a')[1].inner_html
			values << { brand => price }
		end

		puts values
		puts Time.now

		return values
	end

	def scrap_deputes
		@base_url = "https://www.nosdeputes.fr/deputes"
		data = get_content(@base_url)
		links = []
		begin
			lines = data.css('tr td a @href')
			lines.each do |line|
				links << @base_url.split('/deputes')[0] + line.inner_html
			end

			deputes = {}
			links.each do | url |
				begin
				data = get_content(url)
				nom = data.css('div .info_depute h1').inner_html
				puts nom
				mail =  data.css('div[id="b1"] ul')[2].css('li a @href').inner_html.split("mailto:")
				deputes[nom] = []
				mail.each do |m|
					if m.size > 0
						deputes[nom] << m
						puts m
					end
				end
				rescue StandardError => e
					puts e.class
					puts e.message
				end
			end
			puts deputes
		rescue StandardError => e
			puts e.class
			puts e.message
		end
	end
end

def run
	 #Instanciation de l'objet Parser
	parser = Parser.new

	# Appel de la méthode scrapping_cities pour afficher les villes et leurs mails 
	
	# parser.scrapping_cities

	# Appel de la méthode scrapping_crypomonney pour récupérer les noms et valeurs des cryptomonnaies 	
	# Dans une boucle infinie pour relancer le script toutes les 15 secondes
	
	# while true
	# 	parser.scrapping_crypomonney
	# 	sleep(15)
	# end

	# Appel de la méthode scrapping_deputes pour récupérer les noms et adresses mails des députés 
	parser.scrap_deputes
end

run