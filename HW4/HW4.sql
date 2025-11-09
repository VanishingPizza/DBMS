create database assignment4;
use assignment4;
-- Safe Updates
set SQL_SAFE_UPDATES=0;
set FOREIGN_KEY_CHECKS=0;

-- Constraints for actor table
alter table actor
add constraint actors_pk primary key (actor_id);-- Primary key 

-- Constraints for address table
alter table address
add constraint address_pk primary key (address_id), -- Primary key 
add constraint address_fk foreign key (city_id) references city (city_id) on update cascade on delete cascade; -- Foreign key 

-- Constraints for category table
alter table category
add constraint category_pk primary key (category_id), -- Primary key 
add constraint chck_category_name check(name in ('Animation','Comedy','Family','Foreign','Sci-Fi','Travel','Children','Drama','Horror','Action','Classics','Games','New','Documentary','Sports','Music')); -- Required name constraint

-- Constraints for city table
alter table city 
add constraint city_pk primary key (city_id), -- Primary key 
add constraint city_fk foreign key (country_id) references country (country_id) on update cascade on delete cascade; -- Foreign key 

-- Constraints for country table
alter table country
add constraint country_pk primary key (country_id); -- Primary Key 

-- Constraints for customer table
alter table customer
add constraint customer_pk primary key (customer_id), -- Primary Key 
add constraint customer_fk1 foreign key (store_id) references store (store_id) on update cascade on delete cascade, -- Foreign key
add constraint customer_fk2 foreign key (address_id) references address (address_id) on update cascade on delete cascade,
add constraint check_active check(active between 0 and 1); -- Required active constraint

-- Constraints for film table
alter table film
add constraint film_pk primary key (film_id), -- Primary key 
add constraint film_fk foreign key (language_id) references language (language_id) on update cascade on delete cascade, -- Foreign key
add constraint chck_film_features check(special_features in('Behind The Scenes','Commentaries','Deleted Scenes','Trailers')), -- Required special features constraint
add constraint chck_film_rental_duration check(rental_duration between 2 and 8), -- Required rental duration constraint
add constraint chck_film_rate check(rental_rate between 0.99 and 6.99), -- Required rental rate contraint
add constraint chck_film_length check(length between 30 and 200), -- Required film length constraint
add constraint chck_film_rating check(rating in('PG','G','NC-17','PG-13','R')), -- Required ratings constraint
add constraint chck_film_cost check(replacement_cost between 5.00 and 100.00), -- Required replacement cost constraint
add constraint chck_film_year check(release_year <=2025); -- Valid year constraint

-- Constraints for film_actor table
alter table film_actor
add constraint film_actor_pk primary key(actor_id,film_id), -- Primary key
	-- Foreign keys
add constraint film_actor_fk1 foreign key (actor_id) references actor (actor_id) on update cascade on delete cascade,
add constraint film_actor_fk2 foreign key (film_id) references film (film_id) on update cascade on delete cascade; 

-- Constraints for film_category table
alter table film_category
add constraint film_cat_pk primary key(film_id,category_id), -- Primary key
	-- Foreign keys
add constraint film_cat_fk1 foreign key (film_id) references film (film_id) on update cascade on delete cascade,
add constraint film_cat_fk2 foreign key (category_id) references category (category_id) on update cascade on delete cascade;

-- Constraints for inventory table 
alter table inventory
add constraint inventory_pk primary key (inventory_id), -- Primary Key
	-- Foreign keys
add constraint inventory_fk1 foreign key (film_id) references film (film_id) on update cascade on delete cascade,
add constraint invenotry_fk2 foreign key (store_id) references store (store_id) on update cascade on delete cascade;

-- Constraints for language table
alter table language
add constraint language_pk primary key (language_id); -- Primary key

-- Constraints for payment table
alter table payment
add constraint payment_pk primary key (payment_id), -- Primary key
add constraint chck_amount check(amount >=0), -- Required amount constraint
add constraint chck_payment_date check(payment_date<='2025-11-09'), -- Required valid date constraint 
	-- Foreign keys
add constraint payment_fk1 foreign key (customer_id) references customer (customer_id) on update cascade on delete cascade,
add constraint payment_fk2 foreign key (staff_id) references staff (staff_id) on update cascade on delete cascade,
add constraint payment_fk3 foreign key (rental_id) references rental (rental_id) on update cascade on delete cascade;

-- Constraints for rental table
alter table rental
add constraint rental_pk primary key (rental_id), -- Primary key
add constraint rental_unique unique (rental_date, inventory_id,customer_id), -- Unique constraint
-- Required valid date constraints
add constraint chck_rental_date check(rental_date<='2025-11-09'), 
add constraint chck_return_date check(return_date<='2025-11-09'), 
	-- Foreign keys
add constraint rental_fk1 foreign key (inventory_id) references inventory (inventory_id) on update cascade on delete cascade,
add constraint rental_fk2 foreign key (customer_id) references customer (customer_id) on update cascade on delete cascade;

-- Constraints for staff table
alter table staff
add constraint staff_pk primary key (staff_id), -- Primary key
add constraint chck_staff_active check(active between 0 and 1), -- required active constraint 
	-- Foreign keys
add constraint staff_fk1 foreign key (address_id) references address (address_id) on update cascade on delete cascade,
add constraint staff_fk2 foreign key (store_id) references store (store_id) on update cascade on delete cascade;

-- Constraint for store table
alter table store
add constraint store_pk primary key (store_id), -- Primary key
add constraint store_fk foreign key (address_id) references address (address_id) on update cascade on delete cascade; -- foreign key


-- Query 1 : Finding average length of films in each category and listing result in alphabetical order of categories
select category.name, round(avg(length),2) as Average_Length
from category inner join film_category using(category_id) inner join film using (film_id)
group by category.name
order by category.name;


-- Query 2: Finding which categories have the longest and shortest film lengths
-- Finding category with longest average film
(Select category.name, round(avg(length),2) as Average_Length 
from category inner join film_category using(category_id) inner join film using(film_id)
group by category.name
having avg(length) >=all(
	select avg(length) 
    from category inner join film_category using(category_id) inner join film using(film_id) 
    group by category.name)
) 

union

-- Finding category with shortest average film
(Select category.name, round(avg(length),2) as Average_Length 
from category inner join film_category using(category_id) inner join film using(film_id) 
group by category.name
order by Average_Length
limit 1);


-- Query 3: Finding which customers rented action but not comedy or classic movies
Select distinct customer.customer_id, customer.first_name, customer.last_name
from category inner join film_category using(category_id) inner join film using(film_id) inner join inventory using(film_id) 
inner join rental using (inventory_id) inner join customer using(customer_id)
where category.name = 'Action' and customer.active=1 and customer.customer_id not in(
Select distinct customer.customer_id
from category inner join film_category using(category_id) inner join film using(film_id) inner join inventory using(film_id) 
inner join rental using (inventory_id) inner join customer using(customer_id)
where category.name in('Comedy','Classics')); 


-- Query 4: Finding which actor has appeared in the most English-language movies
Select distinct actor.actor_id, actor.first_name, actor.last_name, count(film_id) as Films
from actor inner join film_actor using(actor_id) inner join film using(film_id) inner join language using(language_id)
where language.name='English'
group by actor.actor_id
having count(film_id) >=all (
	select count(film_id) 
    from actor inner join film_actor using(actor_id) inner join film using(film_id) inner join language using(language_id)
    where language.name='English' 
    group by actor.actor_id
    );
    
-- Query 5: How many distinct movies were rented for exactly 10 days from the store where Mike works
Select count(distinct film_id) as Number_of_Movies
from film inner join inventory using(film_id) inner join store using(store_id) inner join staff using(store_id) inner join rental using(staff_id)
where staff.first_name ='Mike' and datediff(rental.return_date,rental_date)=10;

-- Query 6: Listing actors who appear in the movie with the largest cast of actors in alphabetical order
