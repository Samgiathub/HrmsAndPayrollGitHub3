﻿CREATE TABLE [dbo].[T0100_EMP_GRADE_DETAIL] (
    [Tran_ID]     NUMERIC (18) NOT NULL,
    [Emp_ID]      NUMERIC (18) NOT NULL,
    [Cmp_ID]      NUMERIC (18) NOT NULL,
    [For_Date]    DATETIME     NOT NULL,
    [Grd_ID]      NUMERIC (18) NOT NULL,
    [System_Date] DATETIME     NULL,
    [OT_Grd_ID]   NUMERIC (18) NULL,
    CONSTRAINT [PK_T0100_EMP_GRADE_DETAIL] PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0100_EMP_GRADE_DETAIL_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0100_EMP_GRADE_DETAIL_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

