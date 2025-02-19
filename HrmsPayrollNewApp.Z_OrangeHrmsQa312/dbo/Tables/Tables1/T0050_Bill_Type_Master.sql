CREATE TABLE [dbo].[T0050_Bill_Type_Master] (
    [Bill_Id]           INT           IDENTITY (1, 1) NOT NULL,
    [Cmp_Id]            INT           NULL,
    [Bill_Name]         VARCHAR (50)  NULL,
    [Bill_Fieldtype_Id] VARCHAR (50)  NULL,
    [System_Date]       SMALLDATETIME NULL,
    CONSTRAINT [PK_T0050_Bill_Type_Master] PRIMARY KEY CLUSTERED ([Bill_Id] ASC)
);

