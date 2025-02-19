CREATE TABLE [dbo].[T0250_Perquisites_Employee_Monthly_Rent] (
    [Perq_Tran_Id] NUMERIC (18)    NOT NULL,
    [Month]        NUMERIC (18)    NOT NULL,
    [Year]         NUMERIC (18)    NOT NULL,
    [Amount]       NUMERIC (18, 2) CONSTRAINT [DF_T0250_Perquisites_Employee_Monthly_Rent_Amount] DEFAULT ((0)) NOT NULL
);

