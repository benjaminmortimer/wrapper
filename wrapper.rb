require 'sinatra'
require 'net/http'
require 'json'

set :port, 8080
set :static, true
set :public_folder, "static"
set :views, "views"

get '/' do
	erb :index, 
	:locals => {
		:title => "Live GOV.UK content, not on GOV.UK",
		:wrapper_name => "An experiment",
		:footer_content => "An experiment",
		:service_name => "Live GOV.UK content, but not on GOV.UK",
		:introductory_paragraph => "<p>This website makes requests to the GOV.UK content API and displays the content that’s returned.</p><p>This means it is always up to date with GOV.UK.</p><p>Currently, it can only handle the ‘start page’ format. Put your favourite start page slug after the root url in the address bar to see the results.</p><p>For example, you could try <a href=\"/register-to-vote\">/register-to-vote</a></p>",
		:start_button_text => "A button",
		:other_ways_to_apply => "Offline channels and so on."
		}
end

get '/:service_name' do
	erb :index,
		:locals => content_for(params['service_name'])
end

class ContentItem
	def initialize(slug)
		@slug = slug
		@api_address = 'https://www.gov.uk/api/content/'
	end
	def request
		Net::HTTP.get(URI(@api_address + @slug))
	end
	def interpret
		JSON.parse(request)
	end
	def details
		interpret['details']
	end
	def title
		interpret['title']
	end
end

class StartPage < ContentItem
	def introductory_paragraph
		details['introductory_paragraph']
	end
	def start_button_text
		details['start_button_text']
	end
	def transaction_start_link
		details['transaction_start_link']
	end
	def other_ways_to_apply
		details['other_ways_to_apply']
	end
end


def content_for(slug)
	page = StartPage.new(slug)
	{
		:title => page.title,
		:wrapper_name => configurable["org_name"],
		:footer_content => configurable["footer_content"],
		:service_name => page.title,
		:introductory_paragraph => page.introductory_paragraph,
		:start_button_text => page.start_button_text,
		:other_ways_to_apply => page.other_ways_to_apply
	}
end

def configurable
	{	"org_name" => "Some org",
		"footer_content" => "The footer"
	}
end
