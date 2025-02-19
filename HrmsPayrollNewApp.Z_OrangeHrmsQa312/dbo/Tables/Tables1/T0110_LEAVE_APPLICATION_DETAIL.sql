CREATE TABLE [dbo].[T0110_LEAVE_APPLICATION_DETAIL] (
    [Leave_Application_ID]  NUMERIC (18)    NOT NULL,
    [Cmp_ID]                NUMERIC (18)    NOT NULL,
    [Leave_ID]              NUMERIC (18)    NOT NULL,
    [From_Date]             DATETIME        NOT NULL,
    [To_Date]               DATETIME        NOT NULL,
    [Leave_Period]          NUMERIC (18, 2) NOT NULL,
    [Leave_Assign_As]       VARCHAR (15)    NOT NULL,
    [Leave_Reason]          NVARCHAR (MAX)  NULL,
    [Row_ID]                NUMERIC (18)    NOT NULL,
    [Login_ID]              NUMERIC (18)    NOT NULL,
    [System_Date]           DATETIME        NOT NULL,
    [Half_Leave_Date]       DATETIME        NULL,
    [Leave_App_Doc]         VARCHAR (MAX)   NULL,
    [leave_Out_time]        DATETIME        NULL,
    [leave_In_time]         DATETIME        NULL,
    [Leave_Actual_out_time] DATETIME        NULL,
    [Leave_Actual_In_time]  DATETIME        NULL,
    [NightHalt]             NUMERIC (18)    CONSTRAINT [DF_T0110_LEAVE_APPLICATION_DETAIL_NightHalt] DEFAULT ((0)) NOT NULL,
    [Leave_CompOff_Dates]   VARCHAR (MAX)   NULL,
    [Half_Payment]          TINYINT         CONSTRAINT [DF_T0110_LEAVE_APPLICATION_DETAIL_Half_Payment] DEFAULT ((0)) NOT NULL,
    [Warning_flag]          TINYINT         CONSTRAINT [DF_T0110_LEAVE_APPLICATION_DETAIL_Warning_flag] DEFAULT ((0)) NOT NULL,
    [Rules_violate]         TINYINT         CONSTRAINT [DF_T0110_LEAVE_APPLICATION_DETAIL_Rules_violate] DEFAULT ((0)) NOT NULL,
    [Is_Import]             TINYINT         CONSTRAINT [DF_T0110_LEAVE_APPLICATION_DETAIL_Is_Import] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [FK_T0110_LEAVE_APPLICATION_DETAIL_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0110_LEAVE_APPLICATION_DETAIL_T0040_LEAVE_MASTER] FOREIGN KEY ([Leave_ID]) REFERENCES [dbo].[T0040_LEAVE_MASTER] ([Leave_ID]),
    CONSTRAINT [FK_T0110_LEAVE_APPLICATION_DETAIL_T0100_LEAVE_APPLICATION] FOREIGN KEY ([Leave_Application_ID]) REFERENCES [dbo].[T0100_LEAVE_APPLICATION] ([Leave_Application_ID])
);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0110_LEAVE_APPLICATION_DETAIL_24_955150448__K2_K1_K4_K5]
    ON [dbo].[T0110_LEAVE_APPLICATION_DETAIL]([Cmp_ID] ASC, [Leave_Application_ID] ASC, [From_Date] ASC, [To_Date] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0110_LEAVE_APPLICATION_DETAIL_8_802101898__K2_K1_K3_K9_4_5_6_8]
    ON [dbo].[T0110_LEAVE_APPLICATION_DETAIL]([Cmp_ID] ASC, [Leave_Application_ID] ASC, [Leave_ID] ASC, [Row_ID] ASC)
    INCLUDE([From_Date], [To_Date], [Leave_Period], [Leave_Reason]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0110_LEAVE_APPLICATION_DETAIL_8_802101898__K1_K3_K9_K2_4_5_6_8]
    ON [dbo].[T0110_LEAVE_APPLICATION_DETAIL]([Leave_Application_ID] ASC, [Leave_ID] ASC, [Row_ID] ASC, [Cmp_ID] ASC)
    INCLUDE([From_Date], [To_Date], [Leave_Period], [Leave_Reason]) WITH (FILLFACTOR = 80);


GO
CREATE STATISTICS [_dta_stat_802101898_1_2]
    ON [dbo].[T0110_LEAVE_APPLICATION_DETAIL]([Leave_Application_ID], [Cmp_ID]);


GO
CREATE STATISTICS [_dta_stat_802101898_1_3]
    ON [dbo].[T0110_LEAVE_APPLICATION_DETAIL]([Leave_Application_ID], [Leave_ID]);


GO
CREATE STATISTICS [_dta_stat_802101898_3_2]
    ON [dbo].[T0110_LEAVE_APPLICATION_DETAIL]([Leave_ID], [Cmp_ID]);


GO
CREATE STATISTICS [_dta_stat_802101898_1_2_3]
    ON [dbo].[T0110_LEAVE_APPLICATION_DETAIL]([Leave_Application_ID], [Cmp_ID], [Leave_ID]);


GO
CREATE STATISTICS [_dta_stat_955150448_4_1]
    ON [dbo].[T0110_LEAVE_APPLICATION_DETAIL]([From_Date], [Leave_Application_ID]);


GO
CREATE STATISTICS [_dta_stat_955150448_5_2_4]
    ON [dbo].[T0110_LEAVE_APPLICATION_DETAIL]([To_Date], [Cmp_ID], [From_Date]);


GO
CREATE STATISTICS [_dta_stat_955150448_2_4]
    ON [dbo].[T0110_LEAVE_APPLICATION_DETAIL]([Cmp_ID], [From_Date]);


GO
CREATE STATISTICS [_dta_stat_955150448_1_5_2]
    ON [dbo].[T0110_LEAVE_APPLICATION_DETAIL]([Leave_Application_ID], [To_Date], [Cmp_ID]);


GO
CREATE STATISTICS [_dta_stat_802101898_9_2_3]
    ON [dbo].[T0110_LEAVE_APPLICATION_DETAIL]([Row_ID], [Cmp_ID], [Leave_ID]);

