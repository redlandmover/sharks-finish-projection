require 'sinatra'
require 'open-uri'
require 'nokogiri'
require 'awesome_print'
require 'active_support/inflector'

get '/' do
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
      [:row, 'td[7]/text()']
    ].each do |name, xpath|
      detail[name] = row.at_xpath(xpath).to_s.strip
    end
    detail
  end
  #ap teams

  percentages = [20, 13.5, 11.5, 9.5, 8.5,7.5,6.5,6,5,3.5,3,2.5,2,1]

  teams.each{ |team|
    team[:games_played] = team[:games_played].to_i
    team[:points] = team[:points].to_i
    team[:row] = team[:row].to_i
    games_left = {:games_left => 82-team[:games_played] }
    team.merge!(games_left)
    max_points = {:max_points => team[:games_left]*2 + team[:points]}
    team.merge!(max_points)

  }

  sharks = teams.find {|team| team[:name] == "San Jose"}

  worst_teams = teams.select {|team| team[:max_points] <= sharks[:points]}

  ap worst_teams

  if worst_teams[0][:maxPoints] == sharks[:points] && worst_teams[0][:row] < sharks[:row]
    worst_teams.delete_at(0)
  end

  ap worst_teams

  return "With " + sharks[:games_left].to_s + " games remaining, the sharks can finish a minimum of " + ActiveSupport::Inflector.ordinalize(worst_teams.count+1) +
    " and have a " + percentages[(worst_teams.count)].to_s + ' % chance at McDavid'

end
