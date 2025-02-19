CREATE TABLE [dbo].[tmp_Email] (
    [Alpha_Emp_Code]    VARCHAR (50)   NULL,
    [Emp_Full_Name]     VARCHAR (250)  NULL,
    [Login_ID]          NUMERIC (18)   NOT NULL,
    [Email_id]          VARCHAR (100)  NULL,
    [Designation]       VARCHAR (10)   NOT NULL,
    [Emp_Left]          CHAR (1)       NULL,
    [Branch_id_multi]   NVARCHAR (MAX) NULL,
    [Branch_Name_multi] NVARCHAR (MAX) NULL
);

