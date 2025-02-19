CREATE TABLE [dbo].[T0081_Emp_LetterRef_Details] (
    [Tran_Id]      NUMERIC (18)  NOT NULL,
    [Cmp_Id]       NUMERIC (18)  NOT NULL,
    [Emp_Id]       NUMERIC (18)  NOT NULL,
    [Letter_Name]  VARCHAR (200) NOT NULL,
    [Reference_No] VARCHAR (100) NOT NULL,
    [Issue_Date]   DATETIME      NOT NULL,
    CONSTRAINT [PK_T0081_Emp_LetterRef_Details] PRIMARY KEY CLUSTERED ([Tran_Id] ASC)
);

