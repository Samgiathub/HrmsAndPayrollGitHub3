CREATE TABLE [dbo].[T0052_Hrms_Training_Event_Calender_Yearly] (
    [Event_id]      NUMERIC (18) NOT NULL,
    [Cmp_ID]        NUMERIC (18) CONSTRAINT [DF_Table_1_cmp_ID] DEFAULT ((0)) NOT NULL,
    [Training_date] DATETIME     NOT NULL,
    [Training_id]   NUMERIC (18) CONSTRAINT [DF_T0052_Hrms_Training_Event_Calender_Yearly_Training_id] DEFAULT ((0)) NOT NULL
);

