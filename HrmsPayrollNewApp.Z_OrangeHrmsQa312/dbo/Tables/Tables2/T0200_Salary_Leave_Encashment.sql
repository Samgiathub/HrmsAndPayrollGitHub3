CREATE TABLE [dbo].[T0200_Salary_Leave_Encashment] (
    [Leave_Encash_ID]   INT             IDENTITY (1, 1) NOT NULL,
    [Leave_ID]          NUMERIC (18)    NOT NULL,
    [Sal_Tran_Id]       NUMERIC (18)    NOT NULL,
    [L_Day_Salary]      NUMERIC (18, 3) NOT NULL,
    [Encashment_Rate]   NUMERIC (18, 3) NOT NULL,
    [Encashment_Days]   NUMERIC (18, 2) NOT NULL,
    [Encashment_Amount] NUMERIC (18, 3) NOT NULL,
    [L_Cal_Encash_Days] NUMERIC (18)    NOT NULL,
    [Month_St_Date]     DATETIME        NOT NULL,
    [Month_End_Date]    DATETIME        NOT NULL,
    [Emp_ID]            NUMERIC (18)    NOT NULL,
    [Cmp_ID]            NUMERIC (18)    NOT NULL,
    [Lv_Encash_Cal_On]  VARCHAR (50)    NULL,
    [Cal_Amount]        NUMERIC (18, 3) NULL,
    CONSTRAINT [PK_T0200_Salary_Leave_Encashment] PRIMARY KEY CLUSTERED ([Leave_Encash_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0200_Salary_Leave_Encashment_T0040_LEAVE_MASTER] FOREIGN KEY ([Leave_ID]) REFERENCES [dbo].[T0040_LEAVE_MASTER] ([Leave_ID])
);

