CREATE TABLE [dbo].[T0100_Employee_Template_Response] (
    [ETR_Id]        INT            NOT NULL,
    [Cmp_Id]        INT            NULL,
    [Emp_Id]        INT            NULL,
    [T_Id]          INT            NULL,
    [F_Id]          INT            NULL,
    [Answer]        NVARCHAR (MAX) NULL,
    [Created_Date]  DATETIME       NULL,
    [Response_Flag] INT            NULL,
    CONSTRAINT [PK_T0100_Employee_Template_Response] PRIMARY KEY CLUSTERED ([ETR_Id] ASC) WITH (FILLFACTOR = 80)
);

