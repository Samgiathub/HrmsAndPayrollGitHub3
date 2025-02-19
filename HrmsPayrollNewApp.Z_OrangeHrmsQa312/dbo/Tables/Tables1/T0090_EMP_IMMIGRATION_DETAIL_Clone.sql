CREATE TABLE [dbo].[T0090_EMP_IMMIGRATION_DETAIL_Clone] (
    [Emp_ID]             NUMERIC (18)  NOT NULL,
    [Row_ID]             NUMERIC (18)  NOT NULL,
    [Cmp_ID]             NUMERIC (18)  NOT NULL,
    [Loc_ID]             NUMERIC (18)  NULL,
    [Imm_Type]           VARCHAR (20)  NOT NULL,
    [Imm_No]             VARCHAR (20)  NOT NULL,
    [Imm_Issue_Date]     DATETIME      NULL,
    [Imm_Issue_Status]   VARCHAR (20)  NOT NULL,
    [Imm_Date_of_Expiry] DATETIME      NULL,
    [Imm_Review_Date]    DATETIME      NULL,
    [Imm_Comments]       VARCHAR (250) NOT NULL,
    [System_Date]        DATETIME      NOT NULL,
    [Login_id]           NUMERIC (18)  NOT NULL
);

