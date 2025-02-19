-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SP_LEAVE_CF_Display_Duplicate

AS
BEGIN

	
	DECLARE @counter INT = 299;
	
	WHILE @counter <= 3415
    BEGIN
    exec SP_LEAVE_CF_Display @leave_Cf_ID=0,@Cmp_ID=13,@From_Date='2024-06-01 00:00:00',@To_Date='2024-06-30 00:00:00',@For_Date='2024-07-01 00:00:00',
	@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID =@counter,@Constraint='',@P_LeavE_ID=73,@Segment_ID =0,@subBranch_ID =0,
	@Vertical_ID =0,@SubVertical_ID =0	

      SET @counter = @counter + 1;
    END;
	

	


END
