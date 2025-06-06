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
-- Purpose: Roll Back Script for the Main Sql for the Central Security Service Sql Server Database.
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
-- Drop Tables.
--------------------------------------------------------------------------------

IF OBJECT_ID(N'$(Schema).CentralSecurityServiceDatabaseVersions', N'U') IS NOT NULL
BEGIN
	IF EXISTS (SELECT 1 FROM $(Schema).CentralSecurityServiceDatabaseVersions WHERE Major = $(DatabaseVersionMajor) AND Minor = $(DatabaseVersionMinor) AND Patch = $(DatabaseVersionPatch) AND Build = N'$(DatabaseVersionBuild)')
	BEGIN
		DELETE FROM $(Schema).CentralSecurityServiceDatabaseVersions
		WHERE Major = $(DatabaseVersionMajor) AND Minor = $(DatabaseVersionMinor) AND Patch = $(DatabaseVersionPatch) AND Build = N'$(DatabaseVersionBuild)';
	END
END
GO

-- NOTE: In Future Versions *ONLY* DELETE the relevant Database Version Row and leave the Table otherwise intact.
DROP TABLE IF EXISTS $(Schema).CentralSecurityServiceDatabaseVersions;

--------------------------------------------------------------------------------
-- Drop the Unique Reference Id if/as appropriate.
--------------------------------------------------------------------------------

DROP SEQUENCE $(Schema).UniqueReferenceId;

--------------------------------------------------------------------------------
-- Drop Schema if/as appropriate.
--------------------------------------------------------------------------------

DROP SCHEMA IF EXISTS $(Schema);

--------------------------------------------------------------------------------

GO

--------------------------------------------------------------------------------
-- End Of File.
--------------------------------------------------------------------------------
