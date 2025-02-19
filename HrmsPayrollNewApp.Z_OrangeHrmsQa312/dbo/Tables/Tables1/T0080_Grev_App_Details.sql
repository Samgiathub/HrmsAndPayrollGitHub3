CREATE TABLE [dbo].[T0080_Grev_App_Details] (
    [Grev_App_ID]           NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Grev_App_Code]         VARCHAR (50)  NULL,
    [Grev_App_Name]         VARCHAR (50)  NULL,
    [Grev_Type]             VARCHAR (500) NULL,
    [Grev_App_Date]         DATETIME      NULL,
    [Grev_Desc]             VARCHAR (MAX) NULL,
    [Grev_Ename]            VARCHAR (50)  NULL,
    [Grev_Committee]        NUMERIC (18)  NULL,
    [Grev_Committee_Member] VARCHAR (MAX) NULL,
    [Grev_Meeting_Date]     DATETIME      NULL,
    [ReviewOfGrev_App]      VARCHAR (MAX) NULL,
    CONSTRAINT [PK_T0080_Grev_App_Details] PRIMARY KEY CLUSTERED ([Grev_App_ID] ASC) WITH (FILLFACTOR = 95)
);

