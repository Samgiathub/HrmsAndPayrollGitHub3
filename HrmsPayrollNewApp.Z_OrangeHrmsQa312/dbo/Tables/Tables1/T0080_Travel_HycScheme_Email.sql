CREATE TABLE [dbo].[T0080_Travel_HycScheme_Email] (
    [Srno]         NUMERIC (18) IDENTITY (1, 1) NOT NULL,
    [RptLevel]     NUMERIC (18) NULL,
    [SchemeIId]    NUMERIC (18) NULL,
    [DynHierId]    NUMERIC (18) NULL,
    [TravelTypeId] VARCHAR (50) NULL,
    [AppEmp]       NUMERIC (18) NULL,
    [AppId]        NUMERIC (18) NULL,
    [RptEmp]       NUMERIC (18) NULL,
    [CreateDate]   DATETIME     NULL,
    CONSTRAINT [PK_T0080_Travel_HycScheme_Email] PRIMARY KEY CLUSTERED ([Srno] ASC) WITH (FILLFACTOR = 95)
);

