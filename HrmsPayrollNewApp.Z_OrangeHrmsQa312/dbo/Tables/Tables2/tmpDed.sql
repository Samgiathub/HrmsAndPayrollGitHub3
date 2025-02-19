CREATE TABLE [dbo].[tmpDed] (
    [Emp_ID]            NUMERIC (18)    NOT NULL,
    [For_Date]          DATETIME        NOT NULL,
    [Employee_PF]       NUMERIC (38, 2) NULL,
    [ESIC]              NUMERIC (38, 2) NULL,
    [Sal_Generate_Date] DATETIME        NOT NULL,
    [Damage_Deduction]  NUMERIC (38, 2) NULL,
    [Fine_Deduction]    NUMERIC (38, 2) NULL,
    [Loss_Deduction]    NUMERIC (38, 2) NULL
);

