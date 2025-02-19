CREATE TABLE [dbo].[T0040_VEHICLE_TYPE_MASTER] (
    [Vehicle_ID]                 INT           IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]                     NUMERIC (18)  NOT NULL,
    [Vehicle_Type]               VARCHAR (500) NULL,
    [Vehicle_Max_Limit]          FLOAT (53)    NULL,
    [Desig_Wise_Limit]           TINYINT       NULL,
    [Grade_Wise_Limit]           TINYINT       NULL,
    [Branch_Wise_Limit]          TINYINT       NULL,
    [Attach_Mandatory]           BIT           NULL,
    [Vehicle_Allow_Beyond_Limit] TINYINT       NULL,
    [No_Of_Year_Limit]           INT           NULL,
    [Eligible_Joining_Months]    INT           DEFAULT ((0)) NOT NULL,
    [Deduction_Percentage]       FLOAT (53)    DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0040_VEHICLE_TYPE_MASTER] PRIMARY KEY CLUSTERED ([Vehicle_ID] ASC)
);

