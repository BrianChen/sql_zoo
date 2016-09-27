# == Schema Information
#
# Table name: stops
#
#  id          :integer      not null, primary key
#  name        :string
#
# Table name: routes
#
#  num         :string       not null, primary key
#  company     :string       not null, primary key
#  pos         :integer      not null, primary key
#  stop_id     :integer

require_relative './sqlzoo.rb'

def num_stops
  # How many stops are in the database?
  execute(<<-SQL)
    SELECT
      count(distinct stop_id)
    FROM routes
  SQL
end

def craiglockhart_id
  # Find the id value for the stop 'Craiglockhart'.
  execute(<<-SQL)
  SELECT
    id
  FROM stops
  WHERE name = 'Craiglockhart'
  SQL
end

def lrt_stops
  # Give the id and the name for the stops on the '4' 'LRT' service.
  execute(<<-SQL)
  SELECT
    stops.id,
    stops.name
  FROM routes
  JOIN stops
    ON routes.stop_id = stops.id
  WHERE routes.num = '4' AND routes.company = 'LRT'
  SQL
end

def connecting_routes
  # Consider the following query:
  #
  # SELECT
  #   company,
  #   num,
  #   COUNT(*)
  # FROM
  #   routes
  # WHERE
  #   stop_id = 149 OR stop_id = 53
  # GROUP BY
  #   company, num
  #
  # The query gives the number of routes that visit either London Road
  # (149) or Craiglockhart (53). Run the query and notice the two services
  # that link these stops have a count of 2. Add a HAVING clause to restrict
  # the output to these two routes.
  execute(<<-SQL)
  SELECT
    company,
    num,
    COUNT(*)
  FROM
    routes
  WHERE
    stop_id = 149 OR stop_id = 53
  GROUP BY
    company, num
  HAVING count(*) >= 2
  SQL
end

def cl_to_lr
  # Consider the query:
  #
  #
  # Observe that b.stop_id gives all the places you can get to from
  # Craiglockhart, without changing routes. Change the query so that it
  # shows the services from Craiglockhart to London Road.
  execute(<<-SQL)
  SELECT
    a.company,
    a.num,
    a.stop_id,
    b.stop_id
  FROM
    routes a
  JOIN
    routes b ON (a.company = b.company AND a.num = b.num)
  JOIN stops stops_a
    ON stops_a.id = a.stop_id
  JOIN stops stops_b
    ON stops_b.id = b.stop_id
  WHERE stops_a.name = 'Craiglockhart' AND stops_b.name = 'London Road'
  SQL
end

def cl_to_lr_by_name
  # Consider the query:
  #
  # SELECT
  #   a.company,
  #   a.num,
  #   stopa.name,
  #   stopb.name
  # FROM
  #   routes a
  # JOIN
  #   routes b ON (a.company = b.company AND a.num = b.num)
  # JOIN
  #   stops stopa ON (a.stop_id = stopa.id)
  # JOIN
  #   stops stopb ON (b.stop_id = stopb.id)
  # WHERE
  #   stopa.name = 'Craiglockhart'
  #
  # The query shown is similar to the previous one, however by joining two
  # copies of the stops table we can refer to stops by name rather than by
  # number. Change the query so that the services between 'Craiglockhart' and
  # 'London Road' are shown.
  execute(<<-SQL)
  SELECT
    a.company,
    a.num,
    stops_a.name,
    stops_b.name
  FROM
    routes a
  JOIN
    routes b ON (a.company = b.company AND a.num = b.num)
  JOIN stops stops_a
    ON stops_a.id = a.stop_id
  JOIN stops stops_b
    ON stops_b.id = b.stop_id
  WHERE stops_a.name = 'Craiglockhart' AND stops_b.name = 'London Road'
  SQL
end

def haymarket_and_leith
  # Give the company and num of the services that connect stops
  # 115 and 137 ('Haymarket' and 'Leith')
  execute(<<-SQL)
  SELECT distinct a.company, a.num
  FROM routes a
  JOIN routes b
    on b.company = a.company and b.num = a.num
  WHERE
    a.stop_id = 115 and b.stop_id = 137
  SQL
end

def craiglockhart_and_tollcross
  # Give the company and num of the services that connect stops
  # 'Craiglockhart' and 'Tollcross'
  execute(<<-SQL)
  SELECT distinct a.company, a.num
  FROM routes a
  JOIN routes b
    on b.company = a.company and b.num = a.num
  JOIN stops s_a
    on s_a.id = a.stop_id
  JOIN stops s_b
    on s_b.id = b.stop_id
  WHERE
    s_a.name = 'Craiglockhart' AND s_b.name ='Tollcross'
  SQL
end

def start_at_craiglockhart
  # Give a distinct list of the stops that can be reached from 'Craiglockhart'
  # by taking one bus, including 'Craiglockhart' itself. Include the stop name,
  # as well as the company and bus no. of the relevant service.
  execute(<<-SQL)
  SELECT DISTINCT s_a.name, a.company, a.num
  FROM stops s_a
  JOIN routes a
    on a.stop_id = s_a.id
  join routes b
    on b.company = a.company AND a.num = b.num
  JOIN stops s_b
    on s_b.id = b.stop_id
  where s_b.name = 'Craiglockhart'
  SQL
end

def craiglockhart_to_sighthill
  # Find the routes involving two buses that can go from Craiglockhart to
  # Sighthill. Show the bus no. and company for the first bus, the name of the
  # stop for the transfer, and the bus no. and company for the second bus.
  execute(<<-SQL)
  SELECT distinct a_start.num as start_num, a_start.company as start_company, transfer.name as transfer_stop, b_end.num as finish_num, b_end.company as finish_company
  FROM routes a_start
  join routes a_end
    ON a_start.company = a_end.company and a_start.num = a_end.num
  JOIN routes b_start
    ON a_end.stop_id = b_start.stop_id
  JOIN routes b_end
    on b_start.company = b_end.company and b_start.num = b_end.num
  JOIN stops start
    on a_start.stop_id = start.id
  JOIN stops transfer
    on a_end.stop_id = transfer.id
  JOIN stops finish
    on finish.id = b_end.stop_id
  WHERE
    start.name = 'Craiglockhart' and finish.name = 'Sighthill'
  SQL
end
