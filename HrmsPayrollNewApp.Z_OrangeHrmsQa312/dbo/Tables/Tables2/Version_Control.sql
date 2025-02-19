CREATE TABLE [dbo].[Version_Control] (
    [Version_ID]           INT           IDENTITY (1, 1) NOT NULL,
    [Version_Name]         VARCHAR (200) NULL,
    [Version_Type]         VARCHAR (200) NULL,
    [Version_Description]  VARCHAR (200) NULL,
    [Version_Release_Date] DATETIME      NULL,
    [Version_Code]         VARCHAR (200) NULL,
    CONSTRAINT [PK_Version_Control] PRIMARY KEY CLUSTERED ([Version_ID] ASC) WITH (FILLFACTOR = 95)
);

