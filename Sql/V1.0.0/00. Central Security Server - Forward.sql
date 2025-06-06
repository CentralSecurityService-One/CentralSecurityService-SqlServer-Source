 --------------------------------------------------------------------------------
-- Copyright © 2025+ Éamonn Anthony Duffy. All Rights Reserved.
--------------------------------------------------------------------------------
--
-- Version: V1.0.0.
--
-- Created: Éamonn A. Duffy, 6-June-2025.
--
-- Updated: Éamonn A. Duffy, 6-June-2025.
--
-- Purpose: Forward Script for the Main Sql for the Central Security Service Sql Server Database.
--
-- Assumptions:
--
--  0.  The Sql Server Database has already been Created by some other means, and has been selected for Use.
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Some Variables.
--------------------------------------------------------------------------------

:SETVAR DatabaseVersionMajor                     1
:SETVAR DatabaseVersionMinor                     0
:SETVAR DatabaseVersionPatch                     0
:SETVAR DatabaseVersionBuild                    "0"
:SETVAR DatabaseVersionDescription              "Beta Build."

:SETVAR Schema                                  "Dad"

--------------------------------------------------------------------------------
-- Begin the Main Transaction.
--------------------------------------------------------------------------------

SET CONTEXT_INFO    0x00;

BEGIN TRANSACTION
GO

--------------------------------------------------------------------------------
-- Create Schema if/as appropriate.
--------------------------------------------------------------------------------

IF SCHEMA_ID(N'$(Schema)') IS NULL
BEGIN
    PRINT N'Creating the Schema: $(Schema)';

    EXECUTE(N'CREATE SCHEMA $(Schema);');
END
GO

DECLARE @Error AS Int = @@ERROR;
IF (@Error != 0)
BEGIN
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    BEGIN TRANSACTION;
    SET CONTEXT_INFO 0x01;
END
GO

--------------------------------------------------------------------------------
-- Create the Unique Reference Id Sequence if/as appropriate.
--------------------------------------------------------------------------------

IF NOT EXISTS (SELECT * FROM sys.sequences WHERE name = 'UniqueReferenceId' AND schema_id = SCHEMA_ID('$(Schema)'))
BEGIN
    PRINT N'Creating the Unique Reference Id Sequence: $(Schema).UniqueReferenceId';

    CREATE SEQUENCE $(Schema).UniqueReferenceId
        START WITH 0
        INCREMENT BY 1
        NO CACHE;
END

DECLARE @Error AS Int = @@ERROR;
IF (@Error != 0)
BEGIN
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    BEGIN TRANSACTION;
    SET CONTEXT_INFO 0x01;
END
GO

--------------------------------------------------------------------------------
-- Create Tables if/as appropriate.
--------------------------------------------------------------------------------

IF OBJECT_ID(N'$(Schema).CentralSecurityServiceDatabaseVersions', N'U') IS NULL
BEGIN
    PRINT N'Creating the CentralSecurityServiceDatabaseVersions Table.';

    CREATE TABLE $(Schema).CentralSecurityServiceDatabaseVersions
    (
        DatabaseVersionId           Int NOT NULL CONSTRAINT PK_$(Schema)_CentralSecurityServiceDatabaseVersions PRIMARY KEY IDENTITY(0, 1),
        Major                       Int NOT NULL,
        Minor                       Int NOT NULL,
        Patch                       Int NOT NULL,
        Build                       NVarChar(128) NOT NULL,
        Description                 NVarChar(256) NOT NULL,
        CreatedDateTimeUtc          DateTime2(7) NOT NULL CONSTRAINT DF_$(Schema)_CentralSecurityServiceDatabaseVersions_CreatedDateTimeUtc DEFAULT GetUtcDate(),
        LastUpdatedDateTimeUtc      DateTime2(7) NULL,
        
        CONSTRAINT UQ_$(Schema)_CentralSecurityServiceDatabaseVersions_Version UNIQUE (Major, Minor, Patch, Build)
    );
END
GO

DECLARE @Error AS Int = @@ERROR;
IF (@Error != 0)
BEGIN
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    BEGIN TRANSACTION;
    SET CONTEXT_INFO 0x01;
END
GO

--------------------------------------------------------------------------------
-- Insert Version.
--------------------------------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM $(Schema).CentralSecurityServiceDatabaseVersions WHERE Major = $(DatabaseVersionMajor) AND Minor = $(DatabaseVersionMinor) AND Patch = $(DatabaseVersionPatch) AND Build = N'$(DatabaseVersionBuild)')
BEGIN
    PRINT N'Inserting the Database Version.';

    INSERT INTO $(Schema).CentralSecurityServiceDatabaseVersions
        (Major, Minor, Patch, Build, Description)
    VALUES
        ($(DatabaseVersionMajor), $(DatabaseVersionMinor), $(DatabaseVersionPatch), N'$(DatabaseVersionBuild)', N'$(DatabaseVersionDescription)');
END
GO

DECLARE @Error AS Int = @@ERROR;
IF (@Error != 0)
BEGIN
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    BEGIN TRANSACTION;
    SET CONTEXT_INFO 0x01;
END
GO

--------------------------------------------------------------------------------
-- End.
--------------------------------------------------------------------------------

IF CONTEXT_INFO() != 0x00
BEGIN
    PRINT N'Script Failed - One or more Errors Occurred. Rolling Back the Transaction.';

    ROLLBACK TRANSACTION;
END
ELSE
BEGIN
    PRINT N'Script Succeeded. Committing the Transaction.';

    COMMIT TRANSACTION;
END

PRINT N'End.';
GO

--------------------------------------------------------------------------------
-- End Of File.
--------------------------------------------------------------------------------

/*

SELECT NEXT VALUE FOR Dad.UniqueReferenceId;

ALTER SEQUENCE Dad.UniqueReferenceId RESTART WITH 0;

*/
