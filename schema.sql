drop table person;
create table person (
    id integer primary key autoincrement,
    firstname varchar,
    lastname varchar,
    email varchar,
    accesskey varchar
);

drop table vote;
create table vote (
    id integer primary key autoincrement,
    person_id integer,
    vote_type integer, -- 0=no, 1=yes, 2=cond.yes
    cond_min integer,
    
    foreign key (person_id) references person(id)
);
