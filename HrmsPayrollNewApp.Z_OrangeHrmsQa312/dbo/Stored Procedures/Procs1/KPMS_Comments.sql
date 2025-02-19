--truncate table kpms_tblcomment
CREATE PROCEDURE [dbo].[KPMS_Comments]	
(
@Emp_ID INT,
@Comment varchar(200),
@goalAlt_id int
,@Cmp_ID int
)
as
BEGIN
	
	DECLARE @lResult VARCHAR(MAX)=''

	 --DECLARE @Rpt_ID VARCHAR(MAX)=''
		
	 --Select @Rpt_ID = @Rpt_ID + convert(varchar,R_Emp_ID)  from    T0090_EMP_REPORTING_DETAIL  R inner join (      
  --   SELECT Max(effect_date) AS Effect_Date      
  --   FROM   T0090_EMP_REPORTING_DETAIL       
  --   WHERE  effect_date <= Getdate() AND Emp_ID = @Emp_ID       
  --   ) Q on q.Effect_Date = r.Effect_Date      
  --   and Emp_ID = @Emp_ID  


		INSERT INTO [kpms_tblComment]
				( -- [Rpt_id],			  
				   [Eid]
					 ,[comment]
				   ,[date]
				   ,[goalAlt_id]
				   ,[Cmp_Id]
				  )
		 VALUES
			   (
				--   @Rpt_ID,
				   @Emp_ID,
				   @Comment,
				   GETDATE(),
				   @goalAlt_id
				   ,@Cmp_ID
				   
			)
	select @lResult = @lResult + comment from kpms_tblComment 

	select @lResult as Result

END


