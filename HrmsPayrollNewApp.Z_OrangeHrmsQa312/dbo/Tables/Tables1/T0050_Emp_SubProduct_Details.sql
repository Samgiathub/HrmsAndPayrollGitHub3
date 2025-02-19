CREATE TABLE [dbo].[T0050_Emp_SubProduct_Details] (
    [Tran_ID]        NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [Emp_ID]         NUMERIC (18)    NOT NULL,
    [Cmp_ID]         NUMERIC (18)    NOT NULL,
    [Product_ID]     NUMERIC (18)    NOT NULL,
    [SubProduct_ID]  NUMERIC (18)    NOT NULL,
    [Effective_Date] DATETIME        NOT NULL,
    [Rate]           NUMERIC (18, 4) NOT NULL,
    [From_Limit]     NUMERIC (18, 2) NOT NULL,
    [To_Limit]       NUMERIC (18, 2) NOT NULL,
    [Login_ID]       NUMERIC (18)    NOT NULL,
    [System_Date]    DATETIME        NULL,
    CONSTRAINT [PK_T0050_Emp_SubProduct_Details] PRIMARY KEY CLUSTERED ([Tran_ID] ASC),
    CONSTRAINT [FK_T0050_Emp_SubProduct_Details_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0050_Emp_SubProduct_Details_T0040_Product_Master] FOREIGN KEY ([Product_ID]) REFERENCES [dbo].[T0040_Product_Master] ([Product_ID]),
    CONSTRAINT [FK_T0050_Emp_SubProduct_Details_T0040_SubProduct_Master] FOREIGN KEY ([SubProduct_ID]) REFERENCES [dbo].[T0040_SubProduct_Master] ([SubProduct_ID]),
    CONSTRAINT [FK_T0050_Emp_SubProduct_Details_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

