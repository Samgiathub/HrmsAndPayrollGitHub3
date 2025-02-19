CREATE TABLE [dbo].[T0100_AD_Grade_Branch_Wise] (
    [Tran_ID]         NUMERIC (18)    NOT NULL,
    [Cmp_ID]          NUMERIC (18)    NULL,
    [AD_ID]           NUMERIC (18)    NULL,
    [AD_CALCULATE_ON] VARCHAR (100)   NULL,
    [Effective_Date]  DATETIME        NULL,
    [Grd_ID]          NUMERIC (18)    NULL,
    [Branch_ID]       NUMERIC (18)    NULL,
    [AD_Amount]       NUMERIC (18, 2) NULL,
    [SysDatetime]     DATETIME        NULL,
    [UserID]          NUMERIC (18)    NULL,
    PRIMARY KEY CLUSTERED ([Tran_ID] ASC),
    CONSTRAINT [FK__T0100_AD___AD_ID__2B45628C] FOREIGN KEY ([AD_ID]) REFERENCES [dbo].[T0050_AD_MASTER] ([AD_ID]),
    CONSTRAINT [FK__T0100_AD___Branc__2C3986C5] FOREIGN KEY ([Branch_ID]) REFERENCES [dbo].[T0030_BRANCH_MASTER] ([Branch_ID]),
    CONSTRAINT [FK__T0100_AD___Grd_I__2D2DAAFE] FOREIGN KEY ([Grd_ID]) REFERENCES [dbo].[T0040_GRADE_MASTER] ([Grd_ID])
);

