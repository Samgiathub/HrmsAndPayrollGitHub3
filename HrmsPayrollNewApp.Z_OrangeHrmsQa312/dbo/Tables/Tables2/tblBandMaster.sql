CREATE TABLE [dbo].[tblBandMaster] (
    [BandId]          NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [BandName]        VARCHAR (100) NULL,
    [BandCode]        VARCHAR (10)  NULL,
    [SortingNo]       NUMERIC (18)  NULL,
    [Cmp_Id]          INT           NULL,
    [CreatedBy]       NUMERIC (18)  NULL,
    [CreatedDate]     DATETIME      NULL,
    [IsActive]        BIT           NULL,
    [IsActiveEffDate] VARCHAR (50)  NULL,
    CONSTRAINT [PK_tblBandMaster] PRIMARY KEY CLUSTERED ([BandId] ASC)
);

