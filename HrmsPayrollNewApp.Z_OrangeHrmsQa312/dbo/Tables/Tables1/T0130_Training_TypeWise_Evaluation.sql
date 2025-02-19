CREATE TABLE [dbo].[T0130_Training_TypeWise_Evaluation] (
    [Training_Evaluation_ID] NUMERIC (18) NOT NULL,
    [Cmp_ID]                 NUMERIC (18) NOT NULL,
    [Emp_ID]                 NUMERIC (18) NOT NULL,
    [Financial_Year]         VARCHAR (50) NOT NULL,
    [Training_Type_ID]       NUMERIC (18) NOT NULL,
    [Training_ID]            NUMERIC (18) NOT NULL,
    [Desired]                NUMERIC (18) NOT NULL,
    [Present]                NUMERIC (18) NOT NULL,
    CONSTRAINT [PK_T0130_Training_TypeWise_Evaluation] PRIMARY KEY CLUSTERED ([Training_Evaluation_ID] ASC)
);

