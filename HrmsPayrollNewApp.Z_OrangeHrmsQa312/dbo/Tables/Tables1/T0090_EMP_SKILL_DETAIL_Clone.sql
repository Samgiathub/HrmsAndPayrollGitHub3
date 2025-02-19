CREATE TABLE [dbo].[T0090_EMP_SKILL_DETAIL_Clone] (
    [Row_ID]           NUMERIC (18)  NOT NULL,
    [Emp_ID]           NUMERIC (18)  NOT NULL,
    [Cmp_ID]           NUMERIC (18)  NOT NULL,
    [Skill_ID]         NUMERIC (18)  NOT NULL,
    [Skill_Comments]   VARCHAR (250) NOT NULL,
    [Skill_Experience] VARCHAR (20)  NOT NULL,
    [System_Date]      DATETIME      NOT NULL,
    [Login_Id]         NUMERIC (18)  NOT NULL
);

