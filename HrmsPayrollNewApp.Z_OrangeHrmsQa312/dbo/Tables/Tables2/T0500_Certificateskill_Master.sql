CREATE TABLE [dbo].[T0500_Certificateskill_Master] (
    [Certi_Id]         NUMERIC (18)   NOT NULL,
    [Cmp_Id]           NUMERIC (18)   NULL,
    [Certificate_Name] VARCHAR (2000) NULL,
    [Certificate_Code] VARCHAR (2000) NULL,
    [Cat_Id]           NUMERIC (18)   NULL,
    [SubCat_Id]        NUMERIC (18)   NULL,
    [Sorting_No]       NUMERIC (18)   NULL,
    [Created_By]       NUMERIC (18)   NULL,
    [Created_Date]     DATETIME       NULL,
    CONSTRAINT [PK_T0500_Certificateskill_Master] PRIMARY KEY CLUSTERED ([Certi_Id] ASC) WITH (FILLFACTOR = 95)
);

