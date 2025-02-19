CREATE TABLE [dbo].[T0000_Import_Data] (
    [tran_id]     NUMERIC (18)   IDENTITY (1, 1) NOT NULL,
    [Name]        VARCHAR (5000) NOT NULL,
    [Right_Name]  VARCHAR (5000) NOT NULL,
    [Value]       NUMERIC (18)   NOT NULL,
    [tab_Name]    VARCHAR (500)  NOT NULL,
    [Module_Name] VARCHAR (500)  NULL,
    [Form_Id]     NUMERIC (18)   NULL,
    [Form_Name]   VARCHAR (500)  NULL
);

