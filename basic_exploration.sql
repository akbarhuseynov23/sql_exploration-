-- The big picture
# How many actors are there in theactors table? - 817718
select count(id) from actors;

# How many directors are there in the directors table? - 86880
select count(id) from directors;

# How many movies are there in the movies table? - 388269
select count(id) from movies;



-- Exploring the movies
# From what year are the oldest and the newest movies? What are the names of those movies? - Roundhay Garden Scene (1888), Traffic Crossing Leeds Bridge (1888), Harry Potter and the Half-Blood Prince (2008)
select name, year from movies
where year = (SELECT MIN(movies.year) from movies)
    or year = (SELECT MAX(movies.year) from movies);

# What movies have the highest and the lowest ranks?
SELECT name FROM movies
where rank = (SELECT MIN(rank) from movies);

SELECT name FROM movies
where rank = (SELECT MAX(rank) from movies);

# What is the most common movie title? - Eurovision Song Contest, The / 49 times
select name, count(name) as most_common from movies
Group BY name
Order BY most_common desc;



-- Understanding the database
# Are there movies with multiple directors?
SELECT movie_id, COUNT(director_id) AS multiple_directors FROM movies_directors
GROUP BY movie_id
ORDER BY multiple_directors DESC;

# What is the movie with the most directors? Why do you think it has so many? - "Bill, The"
select name from movies
where id = "382052";

# On average, how many actors are listed by movie? - 11.4303
select avg(avg_actor_count) from (select count(movie_id) as avg_actor_count from roles group by movie_id) as average;

# Are there movies with more than one “genre”?
select movie_id, COUNT(*) as genre_count  from movies_genres 
group by movie_id 
having count(*) > 1; 



-- Looking for specific movies
# Can you find the movie called “Pulp Fiction”?
# Who directed it? - Quentin Tarantino
# Which actors where casted on it?
select name from movies
where name = "Pulp Fiction";

SELECT m.name as movie_name, d.id as Director_id, d.first_name, d.last_name, a.id as Actor_id, a.first_name, a.last_name from movies m
join movies_directors md ON m.id=md.movie_id
join roles r ON m.id = r.movie_id
join actors a ON r.actor_id = a.id
join directors d ON md.director_id = d.id
WHERE name = "Pulp Fiction";

# Can you find the movie called “La Dolce Vita”?
# Who directed it? - Federico Fellini
# Which actors where casted on it?
SELECT name from movies 
WHERE name LIKE '%Dolce%' 
	AND name LIKE '%Vita%' 
    AND name LIKE '%La%';

SELECT m.name as movie_name, d.id as Director_id, d.first_name, d.last_name, a.id as Actor_id, a.first_name, a.last_name from movies m
join movies_directors md ON m.id=md.movie_id
join roles r ON m.id = r.movie_id
join actors a ON r.actor_id = a.id
join directors d ON md.director_id = d.id
WHERE name = "Dolce vita, La";

# When was the movie “Titanic” by James Cameron released? - 1997
# Hint: there are many movies named “Titanic”. We want the one directed by James Cameron.
# Hint 2: the name “James Cameron” is stored with a weird character on it.
select * from movies
where name = "Titanic";

SELECT * from movies m
join movies_directors md ON m.id=md.movie_id
join roles r ON m.id = r.movie_id
join directors d ON md.director_id = d.id
WHERE name = "Titanic"
	AND first_name LIKE '%James%' 
    AND last_name = 'Cameron'
Limit 1;



-- Actors and directors
# Who is the actor that acted more times as “Himself”? - Adolf Hitler - 206 times
select concat(first_name,' ',last_name) as 'actor_name', count('actor_name') as most_repeared from actors a
join roles r on a.id=r.actor_id
join movies m on r.movie_id=m.id
where role = "Himself"
group by actor_name
order by most_repeared desc;


# What is the most common name for actors? - Shauna MacDonald
# And for directors? - Kaoru UmeZawa
select concat(first_name,' ',last_name) as 'name', count('name') as commomn_name from actors 
group by name
order by commomn_name DESC;

select concat(first_name,' ',last_name) as 'name', count('name') as commomn_name from directors 
group by name
order by commomn_name DESC;



-- Analysing genders
# How many actors are male and how many are female? - M: 513306, F: 304412
select gender, count(gender) as count from actors
group by gender;

# Absolute and relative terms
select gender, count(gender) as count, round((count(gender)/(select COUNT(gender) from actors))*100) as "Percentage" from actors
group by gender;



-- Movies across time
#How many of the movies were released after the year 2000? - 46006
select count(id) from movies
where year > 2000;

# How many of the movies where released between the years 1990 and 2000? - 91138
select count(id) from movies
where year between 1990 and 2000;

where year => 1990
	and year <= 2000;

# Which are the 3 years with the most movies? How many movies were produced on those years? - YEAR 2002: 12056, YEAR 2003: 11890, YEAR 2001: 11690
select year, count(id) AS multiple_movies from movies
group by year
order by multiple_movies desc
limit 3;

# What are the top 5 movie genres?
# What are the top 5 movie genres before 1920?
# What is the evolution of the top movie genres across all the decades of the 20th century?
select genre, count(movie_id) as count from movies_genres
group by genre
order by count desc
limit 5;

select genre, floor(m.year / 10)*10 as decade, count(movie_id) as num_movies from movies m
join movies_genres mg on m.id = mg.movie_id
where year >= 1900
	and year <2000
group by genre, decade
order by decade, num_movies desc;



-- Putting it all together: names, genders and time
# Has the most common name for actors changed over time?

# Get the most common actor name for each decade in the XX century.
select concat(a.first_name,' ',a.last_name) as 'actor_name', count('actor_name') as most_common, floor(mod(m.year,100) / 10)*10 as decade from actors a 
join roles r on a.id = r.actor_id
join movies m on r.movie_id=m.id
group by decade, actor_name
order by decade desc;

# Re-do the analysis on most common names, splitted for males and females.
select concat(a.first_name,' ',a.last_name) as 'actor_name', count('actor_name') as most_common, floor(mod(m.year,100) / 10)*10 as decade from actors a 
join roles r on a.id = r.actor_id
join movies m on r.movie_id=m.id
where a.gender = 'M'
group by decade, actor_name
order by decade desc;

select concat(a.first_name,' ',a.last_name) as 'actor_name', count('actor_name') as most_common, floor(mod(m.year,100) / 10)*10 as decade from actors a 
join roles r on a.id = r.actor_id
join movies m on r.movie_id=m.id
where a.gender = 'F'
group by decade, actor_name
order by decade desc;

# Is the proportion of female directors greater after 1968, compared to before 1968? - After 1968 / 771124 / 22.4689% | Before 1968 / 364050 / 10.6076%
select 'After 1968' as period,  count(actors.id) as count, count(actors.id)/(select count(*) from roles)*100 as percentage from movies 
join roles on roles.movie_id = movies.id
join actors on actors.id = roles.actor_id
where movies.year > 1968
	and actors.gender = 'F'
union
select 'Before 1968' as period, count(actors.id) as count, count(actors.id)/(select count(*) from roles)*100 as percentage from movies 
join roles on roles.movie_id = movies.id
join actors on actors.id = roles.actor_id
where movies.year <= 1968 
	and actors.gender = 'F';

# What is the movie genre where there are the most female directors? Answer the question both in absolute and relative terms.
-- no 'gender' in the directors table

# How many movies had a majority of females among their cast? Answer the question both in absolute and relative terms. Movies: 83578 / 0.2153 - 21 %
select count(*) as num_movies, count(*)/(select count(*) from movies) as Percentage from (select count(movie_id) as count, 100*sum(case when gender = 'F' then 1 else 0 end)/count(*) fem_perc from roles
join actors on actors.id = roles.actor_id group by movie_id) temp
where fem_perc >= 50;