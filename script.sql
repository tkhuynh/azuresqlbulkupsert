/****** Object:  Table [dbo].[mycontroltable]    Script Date: 6/20/2019 3:46:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[mycontroltable](
	[state] [varchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[mysourcetable]    Script Date: 6/20/2019 3:46:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[mysourcetable](
	[id] [int] NULL,
	[value] [varchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[mytargettable]    Script Date: 6/20/2019 3:46:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[mytargettable](
	[id] [int] NULL,
	[value] [varchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[spCreateTempTable]    Script Date: 6/20/2019 3:46:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spCreateTempTable] 
@timeout int = 60
AS
BEGIN
	IF OBJECT_ID('tempdb..##mytemptable') IS NULL
		BEGIN
			CREATE TABLE ##mytemptable (id int, value varchar(255))
			CREATE INDEX ncltemp on ##mytemptable(id)
		END

	IF OBJECT_ID('mycontroltable') IS NULL
		BEGIN
			CREATE TABLE mycontroltable (state varchar(255))
		END

	TRUNCATE TABLE mycontroltable
	INSERT INTO mycontroltable VALUES('started')

	WHILE(1=1)
	BEGIN
		WAITFOR DELAY '00:00:05'
		IF EXISTS (SELECT state FROM mycontroltable WHERE state='finished')
		BEGIN
			BREAK
		END
	END
END
GO
/****** Object:  StoredProcedure [dbo].[spMergeData]    Script Date: 6/20/2019 3:46:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spMergeData]
AS
BEGIN
	MERGE mytargettable AS target
	USING ##mytemptable AS source
	ON (target.id = source.id)
	WHEN MATCHED THEN
		UPDATE SET value = source.value
    WHEN NOT matched THEN
    	INSERT (id,value)
      VALUES (source.id,source.value);
    
    TRUNCATE TABLE ##mytemptable
	UPDATE mycontroltable SET state='finished'
END
GO
