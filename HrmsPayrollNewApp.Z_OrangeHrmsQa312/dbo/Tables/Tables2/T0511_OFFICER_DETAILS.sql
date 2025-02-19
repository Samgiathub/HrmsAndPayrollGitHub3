CREATE TABLE [dbo].[T0511_OFFICER_DETAILS] (
    [Srno]               INT            IDENTITY (1, 1) NOT NULL,
    [Cmp_id]             NUMERIC (18)   NULL,
    [Officer_Name]       VARCHAR (50)   NULL,
    [Officer_Branch]     NUMERIC (18)   NULL,
    [Officer_Department] VARCHAR (50)   NULL,
    [Emailid]            NVARCHAR (500) NULL,
    [Contact]            NUMERIC (18)   NULL,
    [Address]            VARCHAR (500)  NULL,
    PRIMARY KEY CLUSTERED ([Srno] ASC) WITH (FILLFACTOR = 95)
);

