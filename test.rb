require 'open-uri'
require 'nokogiri'
require 'awesome_print'
doc = Nokogiri::HTML(open("http://espn.go.com/nhl/standings/_/group/1")) do |config|
  config.strict.nonet
end

#table = doc.xpath('//table')

#table2 = doc.xpath('//table/tr')

#teamsname = doc.xpath('//table/tr/td[1]/a/text()')

rows = doc.xpath('//table/tr')
teams = rows.collect do |row|
  detail = {}
  [
    [:name, 'td[1]/a/text()'],
    [:games_played, 'td[2]/text()'],
    [:points, 'td[6]/text()'],
  ].each do |name, xpath|
    detail[name] = row.at_xpath(xpath).to_s.strip
  end
  detail
end
#ap teams

teams.each{ |team|
  team[:games_played] = team[:games_played].to_i
  team[:points] = team[:points].to_i
  games_left = {:games_left => 82-team[:games_played] }
  team.merge!(games_left)
  max_points = {:max_points => team[:games_left]*2 + team[:points]}
  team.merge!(max_points)

}

sharks = teams.find {|team| team[:name] == "San Jose"}

worse_teams = teams.select {|team| team[:max_points] <= sharks[:points]}

puts "The sharks can finish a maximum of " + (worse_teams.count+1).to_s
