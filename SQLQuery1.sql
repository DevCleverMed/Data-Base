---1-----
create database Agence 
go
use Agence
go

create table Station (
nomStation varchar(30) primary key , 
Capacite int ,
lieu varchar(30) ,
region varchar (30) ,
tarif int 
)

create table Activite (
nomStation varchar(30) foreign key references Station(nomStation) ,
libelle varchar (30) ,
prix varchar(30)
)

create table Client (
idCient int primary key ,
Nom varchar (30) ,
Prenom varchar (30),
ville varchar (30) ,
region varchar (30) ,
solde float )

create table Sejour (
idCient int foreign key references Client (idCient) ,
nomStation varchar (30) foreign key references Station (nomStation) ,
debut date ,
Nbplaces int
primary key (idCient,nomStation,debut)
 )



insert into Station values ('venus ' ,350, 'gadeloupe','Antilles',1200)
insert into activite values ('venus', 'voile',150)
insert into activite values ('venus', 'plongee',120)
insert into client values (10, 'Gogg','Philipes','Londres','Europe',1246.5)
insert into client values (20, 'Pscal', 'Blais','Paris', 'Europe',6763)
insert into client values (30, 'Kerouac', 'Jack ' , 'NewYork', 'Amerique', 9812)
insert into sejour values(20, 'venus', '03/08/2003 ',4 )

select* from station
select* from activite
select*from client
select*from sejour


-------2----------

create proc NomClient(@id int)
as
declare @nom varchar(25),@prenom varchar(25)
declare curseur CURSOR for select nom,prenom from Client where idCient=@id
open curseur
fetch curseur into @nom,@prenom
while(@@FETCH_STATUS=0)
begin
print @nom+' '+@prenom
fetch curseur into @nom,@prenom
end
close curseur
deallocate curseur

EXEC NomClient 10
---------3------
create Function Activites (@ns varchar(30))
returns table 
as 
return (select NomStation , STRING_AGG(Libelle, ',' ) as 'Activites' From activite
where nomStation = @ns + ''
Group by nomStation 
)
Select * from dbo.Activites('Venus')
------------4--------
create view vix4
as
select * ,dbo.Activites(NomStation)as 'Activies' from Station

select *from vix4


------5
Create proc ActualiserQ5(@pourcentage int,@nomStation varchar(25))
as
if(@pourcentage<0 or @pourcentage>100)
print 'Pourcentage invalide!'
else
begin
update Station set tarif+=(tarif*(@pourcentage*0.01)) where nomStation=@nomStation
update Activite set prix+=(prix*(@pourcentage*0.01)) where nomStation=@nomStation
print 'Modifié'
end

EXEC ActualiserQ5 1 , Venus
select tarif from Station 
select prix from Activite

-----6-----

create trigger trig6
on activite
after update
as 
declare @Df float
select @Df=d.prix-i.prix from inserted i,deleted d
update Station set tarif+=@Df
end 


--------7
 --a) 
alter table station add Nbact int default 0

-- b)
Create trigger NbrAct on activite for insert, update, delete
as
update station set Nbact=(select count(*) from activite
 where activite.nomStation=station.nomStation)
where nomStation in (select nomStation from station union select nomStation from
deleted)
select * from station
select * from activite  
insert into activite values ('Venus','Libel1',150)
--------8Create trigger Ex8 on sejour for insert
as
Begin
if (select solde-(Nbplaces*tarif) from client,inserted, station
 where client.idCient=inserted.idCient and inserted.nomStation=station.nomstation)<0
 Begin
 Raiserror('Ne trouve pas Le solde !',14,2 )
 rollback tran
 End
End 