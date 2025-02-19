CREATE TABLE [dbo].[T0010_Emp_Gallery] (
    [Gallery_ID]     NUMERIC (18)   NOT NULL,
    [Type]           VARCHAR (50)   NULL,
    [Purpose]        VARCHAR (150)  NULL,
    [Name]           VARCHAR (MAX)  NULL,
    [Cmp_ID]         NUMERIC (18)   NULL,
    [Upload_By]      NUMERIC (18)   NULL,
    [Upload_Date]    DATETIME       NULL,
    [Emp_Id_Multi]   NVARCHAR (MAX) NULL,
    [Emp_Code_Multi] NVARCHAR (MAX) NULL,
    [Gallery_Name]   VARCHAR (500)  NULL,
    [expiry_Date]    DATETIME       CONSTRAINT [DF_T0010_Emp_Gallery_expiry_Date] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_T0010_Emp_Gallery] PRIMARY KEY CLUSTERED ([Gallery_ID] ASC) WITH (FILLFACTOR = 80)
);

