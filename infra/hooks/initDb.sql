drop user if exists "$(MSIapiAppName)"
go
CREATE USER "$(MSIapiAppName)" FROM EXTERNAL PROVIDER
go
ALTER ROLE db_datareader ADD MEMBER "$(MSIapiAppName)"
go
ALTER ROLE db_datawriter ADD MEMBER "$(MSIapiAppName)"
go
GRANT ALTER ON SCHEMA :: dbo TO "$(MSIapiAppName)"
go
GRANT CREATE TABLE TO "$(MSIapiAppName)"
go
GRANT REFERENCES TO "$(MSIapiAppName)"
go