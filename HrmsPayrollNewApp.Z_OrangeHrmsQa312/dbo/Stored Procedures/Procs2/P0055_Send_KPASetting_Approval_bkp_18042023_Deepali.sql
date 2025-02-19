

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
create  PROCEDURE [dbo].[P0055_Send_KPASetting_Approval_bkp_18042023_Deepali]
	 @cmp_id  numeric(18,0)
	,@app_emp_id  numeric(18,0)
	,@From_date	datetime 	
	,@condition	varchar(800)='' 	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

	
	DECLARE @rm_Id  NUMERIC(18,0)
	DECLARE @hodId  NUMERIC(18,0)
	DECLARE @GHId   NUMERIC(18,0)
	DECLARE @KPA_InitId   NUMERIC(18,0)
	DECLARE @EmpId  NUMERIC(18,0)
	DECLARE @InitStatus INT
	DECLARE @RMReq INT
	DECLARE @final_Approval INT
	--DECLARE @App_Type  VARCHAR(3)
	
	CREATE TABLE #FinTable
	(
		 Emp_id			 NUMERIC(18,0)
		,KPA_InitiateId  NUMERIC(18,0)
		,Initiate_Status NUMERIC(18,0)
		,Rpt_Level		 INT
		,final_Approval	 INT
		,App_Type		 VARCHAR(3)		
	)
	
	
	DECLARE cur CURSOR
	FOR
		SELECT Emp_Id,KPA_InitiateId,R_Emp_Id,GH_Id,Hod_Id,Initiate_Status,RM_Required
		FROM   V0055_Hrms_Initiate_KPASetting
		WHERE  Cmp_Id=@cmp_id and (Initiate_Status > 0 AND Initiate_Status <> 4)
	OPEN cur
		FETCH NEXT FROM cur INTO @EmpId,@KPA_InitId,@rm_Id,@GHId,@hodId,@InitStatus,@RMReq
		WHILE @@fetch_status = 0
			BEGIN --select @InitStatus,@EmpId
				IF (@InitStatus >= 2 OR @InitStatus = 1 )
					BEGIN 
						IF @RMReq = 1 
							BEGIN  
								IF @rm_Id = @app_emp_id
									BEGIN   
										IF (@hodId <> 0 or @GHId<>0)
											SET @final_Approval =  0
										ELSE
											SET @final_Approval =  1
											
										IF NOT EXISTS(SELECT 1 FROM #FinTable WHERE Emp_id = @EmpId and KPA_InitiateId = @KPA_InitId)	
											BEGIN
												INSERT INTO #FinTable
												VALUES (@EmpId,@KPA_InitId,@InitStatus,1,@final_Approval,'RM')
											END
									END
							END
						ELSE 
							BEGIN 
								IF ISNULL(@hodId,0) <> 0
									BEGIN
										IF @hodId = @app_emp_id
											BEGIN
												IF (@GHId<>0)
													SET @final_Approval =  0
												ELSE
													SET @final_Approval =  1
												
												IF NOT EXISTS(SELECT 1 FROM #FinTable WHERE Emp_id = @EmpId and KPA_InitiateId = @KPA_InitId)	
												BEGIN	
													INSERT INTO #FinTable
													VALUES (@EmpId,@KPA_InitId,@InitStatus,1,@final_Approval,'HOD')
												END
											END
									END
								ELSE IF ISNULL(@GHId,0)<>0
									BEGIN
										IF @GHId = @app_emp_id
											BEGIN
												IF NOT EXISTS(SELECT 1 FROM #FinTable WHERE Emp_id = @EmpId and KPA_InitiateId = @KPA_InitId)	
													BEGIN
														INSERT INTO #FinTable
														VALUES (@EmpId,@KPA_InitId,@InitStatus,1,1,'GH')
													END
											END
									END
							END
					END
				 IF (@InitStatus >= 5 or @InitStatus = 1)
					BEGIN  
						IF @hodId <>0
							BEGIN 
								IF @hodId = @app_emp_id
									BEGIN
										
										IF (@GHId<>0)
											SET @final_Approval =  0
										ELSE
											SET @final_Approval =  1
									
										IF NOT EXISTS(SELECT 1 FROM #FinTable WHERE Emp_id = @EmpId and KPA_InitiateId = @KPA_InitId)	
											BEGIN
												INSERT INTO #FinTable
												VALUES (@EmpId,@KPA_InitId,@InitStatus,2,@final_Approval,'HOD')
											END
									END
							END
						ELSE IF ISNULL(@GHId,0)<>0
							BEGIN
								IF @GHId = @app_emp_id
									BEGIN
										IF NOT EXISTS(SELECT 1 FROM #FinTable WHERE Emp_id = @EmpId and KPA_InitiateId = @KPA_InitId)	
											BEGIN
												INSERT INTO #FinTable
												VALUES (@EmpId,@KPA_InitId,@InitStatus,2,1,'GH')
											END
									END
							END
					END
				 IF (@InitStatus >= 7 OR @InitStatus = 1 )
					BEGIN
						IF ISNULL(@GHId,0)<>0
							BEGIN
								IF @GHId = @app_emp_id
									BEGIN
										IF NOT EXISTS(SELECT 1 FROM #FinTable WHERE Emp_id = @EmpId and KPA_InitiateId = @KPA_InitId)	
											BEGIN
												INSERT INTO #FinTable
												VALUES (@EmpId,@KPA_InitId,@InitStatus,3,1,'GH')
											END
									END
							END
					END
				FETCH NEXT FROM cur INTO @EmpId,@KPA_InitId,@rm_Id,@GHId,@hodId,@InitStatus,@RMReq
			END
	CLOSE cur
	DEALLOCATE cur
	
	DECLARE @query VARCHAR(MAX)

	--select * into temp_KPA_Approve from #FinTable 
	
	SET @query = 
	'SELECT distinct  F.Emp_id,F.KPA_InitiateId,F.Initiate_Status,Emp_Full_Name,dept_Id,Dept_name,desig_Id,Desig_Name,InitiateStatus,KPA_StartDate,
		  F.Rpt_Level,F.final_Approval,App_Type,Review_Type,ISNULL(R_EMP_ID,0)R_EMP_ID,ISNULL(HOD_ID,0)HOD_ID,
		  ISNULL(GH_ID,0)GH_ID,period
	FROM #FinTable F INNER JOIN
	     V0055_Hrms_Initiate_KPASetting K ON K.KPA_InitiateId = F.KPA_InitiateId  and f.Emp_id = k.Emp_Id and k.R_EMP_ID  ='+ cast(@app_emp_id as numeric(18,0)) +''
	     
	IF @condition =''     
		EXEC (@query) 
	ELSE
	    EXEC (@query + 'where cmp_Id ='+ @cmp_id +''+ @condition)

	PRINT @query+ @condition
--	print @query + 'where cmp_Id ='+ @cmp_id +''+ @condition
	DROP TABLE #FinTable
END
