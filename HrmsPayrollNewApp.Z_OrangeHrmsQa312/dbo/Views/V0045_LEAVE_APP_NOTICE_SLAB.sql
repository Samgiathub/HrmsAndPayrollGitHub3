


CREATE VIEW [dbo].[V0045_LEAVE_APP_NOTICE_SLAB]
AS
SELECT     Tran_ID, Cmp_ID, Leave_ID, For_Date, Leave_Period, Notice_Days
FROM         dbo.T0045_LEAVE_APP_NOTICE_SLAB WITH (NOLOCK)

