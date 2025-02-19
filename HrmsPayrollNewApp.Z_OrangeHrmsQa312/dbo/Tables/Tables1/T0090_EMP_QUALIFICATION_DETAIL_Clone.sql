CREATE TABLE [dbo].[T0090_EMP_QUALIFICATION_DETAIL_Clone] (
    [Emp_ID]         NUMERIC (18)  NOT NULL,
    [Row_ID]         NUMERIC (18)  NOT NULL,
    [Cmp_ID]         NUMERIC (18)  NOT NULL,
    [Qual_ID]        NUMERIC (18)  NOT NULL,
    [Specialization] VARCHAR (100) NULL,
    [Year]           NUMERIC (18)  NULL,
    [Score]          VARCHAR (20)  NULL,
    [St_Date]        DATETIME      NULL,
    [End_Date]       DATETIME      NULL,
    [Comments]       VARCHAR (250) NULL,
    [System_Date]    DATETIME      NOT NULL,
    [Login_Id]       NUMERIC (18)  NOT NULL
);

