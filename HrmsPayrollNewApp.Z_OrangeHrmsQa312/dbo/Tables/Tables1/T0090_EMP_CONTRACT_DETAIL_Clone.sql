CREATE TABLE [dbo].[T0090_EMP_CONTRACT_DETAIL_Clone] (
    [Tran_ID]     NUMERIC (18)  NOT NULL,
    [Cmp_ID]      NUMERIC (18)  NOT NULL,
    [Emp_ID]      NUMERIC (18)  NOT NULL,
    [Prj_ID]      NUMERIC (18)  NOT NULL,
    [Start_Date]  DATETIME      NOT NULL,
    [End_Date]    DATETIME      NOT NULL,
    [Is_Renew]    TINYINT       NOT NULL,
    [Is_Reminder] TINYINT       NOT NULL,
    [Comments]    VARCHAR (200) NULL,
    [System_Date] DATETIME      NOT NULL,
    [Login_Id]    NUMERIC (18)  NOT NULL
);

