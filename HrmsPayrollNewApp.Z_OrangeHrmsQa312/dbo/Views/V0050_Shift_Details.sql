





CREATE VIEW [dbo].[V0050_Shift_Details]
AS
SELECT     dbo.T0050_SHIFT_DETAIL.Shift_Tran_ID, dbo.T0050_SHIFT_DETAIL.Shift_ID, dbo.T0050_SHIFT_DETAIL.Cmp_ID, 
                      dbo.T0050_SHIFT_DETAIL.From_Hour, dbo.T0050_SHIFT_DETAIL.To_Hour, dbo.T0050_SHIFT_DETAIL.Minimum_Hour, 
                      dbo.T0050_SHIFT_DETAIL.Calculate_Days, dbo.T0050_SHIFT_DETAIL.OT_Applicable, dbo.T0040_SHIFT_MASTER.Shift_Name, 
                      dbo.T0050_SHIFT_DETAIL.OT_Start_Time, dbo.T0040_SHIFT_MASTER.Inc_Auto_Shift,dbo.T0050_SHIFT_DETAIL.OT_End_Time
FROM         dbo.T0040_SHIFT_MASTER WITH (NOLOCK) INNER JOIN
                      dbo.T0050_SHIFT_DETAIL WITH (NOLOCK)  ON dbo.T0040_SHIFT_MASTER.Shift_ID = dbo.T0050_SHIFT_DETAIL.Shift_ID




