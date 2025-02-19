CREATE TABLE [dbo].[T0252_Customized_Report] (
    [Tran_Id]      NUMERIC (18)   IDENTITY (1, 1) NOT NULL,
    [Cmp_Id]       NUMERIC (18)   NOT NULL,
    [Name]         NVARCHAR (200) NOT NULL,
    [Report_Type]  NVARCHAR (200) NOT NULL,
    [Report_Field] NVARCHAR (MAX) NOT NULL,
    [modifydate]   DATETIME       CONSTRAINT [DF_T0252_Customized_Report_modifydate] DEFAULT (getdate()) NOT NULL,
    [user_Id]      NUMERIC (18)   CONSTRAINT [DF_T0252_Customized_Report_user_Id] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0252_Customized_Report] PRIMARY KEY CLUSTERED ([Tran_Id] ASC) WITH (FILLFACTOR = 80)
);

