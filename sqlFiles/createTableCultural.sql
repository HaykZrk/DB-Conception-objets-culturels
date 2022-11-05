create table USERS
(
	Id_login varchar(10) PRIMARY KEY NOT NULL, 
    Id_password varchar(30) NOT NULL,
    Last_name varchar(30) NOT NULL,
    First_name varchar(30) NOT NULL,
    Address varchar(50),
	Date_birth date,
    Date_register date NOT NULL
);

create table COLLECTIONS
(
	Id_collection INT PRIMARY KEY NOT NULL,
    Id_login varchar(10) NOT NULL,
    Type_cultural varchar(30) NOT NULL,
    FOREIGN KEY (Id_login) REFERENCES USERS
);

create sequence Id_collection minvalue 1 start with 1 cache 10;

create table OBJECTS_REFERENCES
(
	Id_object_reference INT PRIMARY KEY NOT NULL,
    Name_object varchar(50) NOT NULL,
    Author_object varchar(30),
    Description_object varchar(100)
);

create sequence Id_object_reference minvalue 1 start with 1 cache 10;

create table LISTS
( 
	Id_list INT PRIMARY KEY NOT NULL,
    Id_collection INT NOT NULL,
    Name_list varchar(30) NOT NULL,
    Type_list varchar(30) NOT NULL,
    Description_list varchar(100),
    Note_list number(2), CHECK (Note_list > 0 AND Note_list < 21),
    FOREIGN KEY (Id_collection) REFERENCES COLLECTIONS
);

create sequence Id_list minvalue 1 start with 1 cache 10;

create table OBJECTS_USERS
(
	Id_object_user INT PRIMARY KEY NOT NULL,
    Id_object_reference INT NOT NULL,
    Id_list INT NOT NULL,
    Note_object number(2), CHECK (Note_object > -1 AND Note_object < 21),
    Comment_object varchar(100),
    Have1_wish0 number(1) NOT NULL,
    Date_register date NOT NULL,
    FOREIGN KEY (Id_object_reference) REFERENCES OBJECTS_REFERENCES,
    FOREIGN KEY (Id_list) REFERENCES LISTS
);

create sequence Id_object_user minvalue 1 start with 1 cache 10;
