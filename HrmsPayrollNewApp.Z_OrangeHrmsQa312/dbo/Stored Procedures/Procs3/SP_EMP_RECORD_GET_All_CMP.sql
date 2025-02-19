
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_RECORD_GET_All_CMP]      
 
 @FROM_DATE  DATETIME      
 ,@TO_DATE  DATETIME       
 ,@BRANCH_ID  NUMERIC   
 ,@CAT_ID  NUMERIC 
 ,@GRD_ID  NUMERIC 
 ,@TYPE_ID  NUMERIC  
 ,@DEPT_ID  NUMERIC  
 ,@DESIG_ID  NUMERIC 
 ,@EMP_ID  numeric 
 ,@Constraint varchar(5000) = ''      
 ,@Type char(1) = '' -- added by Prakash Patel for Employee Transport Registration   

AS      
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON   
       
      
 if @Branch_ID = 0      
  set @Branch_ID = null      
 if @Cat_ID = 0      
  set @Cat_ID = null      
         
 if @Type_ID = 0      
  set @Type_ID = null      
 if @Dept_ID = 0      
  set @Dept_ID = null      
 if @Grd_ID = 0      
  set @Grd_ID = null      
 if @Emp_ID = 0      
  set @Emp_ID = null      
        
 If @Desig_ID = 0      
  set @Desig_ID = null      
        

       
 CREATE table #Emp_Cons 
 (      
	Emp_ID numeric ,     
	Branch_ID numeric,
	Increment_ID numeric    
 )    
 --EXEC SP_RPT_FILL_EMP_CONS  0,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0,0,0,0,0,0,0,0,2 



       
 if @Constraint <> ''      
  begin      
   Insert Into #Emp_Cons      
   select  cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) from dbo.Split (@Constraint,'#')       
  end      

 else      
  begin      

			Insert Into #Emp_Cons      
		      select Distinct emp_id,branch_id,Increment_ID 
			  from V_Emp_Cons where 
		        Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
		   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
		   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
		   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
		   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
		   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
		   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
		      and Increment_Effective_Date <= @To_Date 
		      and 
                       ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
						or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
						or (Left_date is null and @To_Date >= Join_Date)      
						or (@To_Date >= left_date  and  @From_Date <= left_date ))
						order by Emp_ID
				
				-- Deepal add the below query ON DT :- 14102022	For resolving the performance
				--delete  from #emp_cons where Increment_ID not in (select max(Increment_ID) from T0095_Increment WITH (NOLOCK)
				--	where  Increment_effective_Date <= @to_date
				--	group by emp_ID)         
				delete  from #emp_cons where Increment_ID not in (select max(Increment_ID) from T0095_Increment
				where  Increment_effective_Date <= @to_date AND #emp_cons.Emp_ID=T0095_Increment.Emp_ID
				group by emp_ID)  
				-- Deepal add the below query ON DT :- 14102022	For resolving the performance
  end     
  

  
 IF @Type = 'R'
	BEGIN
		SELECT I_Q.*,E.Alpha_Emp_Code as Emp_Code,CAST(E.Alpha_Emp_Code AS varchar) + ' - '+E.Emp_Full_Name AS 'Emp_Full_Name',Lo.Login_ID,--,E.Emp_Full_Name as Emp_Full_Name_Only
		E.Emp_Full_Name AS 'Emp_Full_Name_only',Emp_superior ,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,
		Date_of_Join,Gender,BM.Comp_Name,BM.Branch_Address,E.Cmp_ID , CM.Cmp_Name,Cm.Cmp_address,E.Emp_Left,
		ISNULL(EM.Route_ID,0) AS 'Route_ID',ISNULL(EM.Pickup_ID,0) AS 'Pickup_ID',ISNULL(EM.Designation_ID,0) AS 'Designation_ID',EM.Transport_Type
		FROM T0080_EMP_MASTER E WITH (NOLOCK)
		INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on E.Cmp_ID = CM.Cmp_ID 
		LEFT OUTER JOIN 
		(
			--T0100_LEFT_EMP EL on E.Emp_Id=EL.Emp_Id inner join        
			SELECT I.Emp_Id,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID 
			FROM T0095_Increment I WITH (NOLOCK)
			INNER JOIN 
			(
				SELECT MAX(I.Increment_ID) AS Increment_ID,I.Emp_ID 
				FROM T0095_Increment I WITH (NOLOCK)
				INNER JOIN 
				(
					SELECT MAX(Increment_effective_Date) AS 'For_Date',Emp_ID 
					FROM T0095_Increment WITH (NOLOCK)
					WHERE Increment_Effective_date <= @To_Date      
					GROUP BY emp_ID 
				) Qry ON I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date 
				GROUP BY I.Emp_ID
			) AS qry_1 ON qry_1.Increment_ID = I.Increment_ID AND qry_1.Emp_ID = I.Emp_ID  
		) I_Q ON E.Emp_ID = I_Q.Emp_ID  
		INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
		LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
		LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
		LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
		INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
		INNER JOIN T0011_Login LO  WITH (NOLOCK) ON LO.Emp_Id = E.Emp_Id 
		INNER JOIN #Emp_Cons as Ec ON Ec.Emp_ID = E.Emp_ID --Added By Jaina 28-08-2015
		LEFT JOIN
		(
			SELECT TRT.Transport_Reg_ID,TRT.Emp_ID, TRT.Transport_Status,TRT.Route_ID,TRT.Pickup_ID,TRT.Designation_ID,TRT.Transport_Type 
			FROM T0040_Employee_Transport_Registration TRT WITH (NOLOCK)
			INNER JOIN 
			(
				SELECT MAX(ET.Transport_Reg_ID) AS 'Transport_Reg_ID',ET.Emp_ID  
				FROM T0040_Employee_Transport_Registration ET WITH (NOLOCK)
				INNER JOIN 
				(
					SELECT MAX(Effective_Date) AS 'Date',Emp_ID FROM T0040_Employee_Transport_Registration WITH (NOLOCK)
					GROUP BY Emp_ID
				) ETR ON ET.Emp_ID = ETR.Emp_ID 
				--WHERE ET.Tranport_Status = 1
				GROUP BY ET.Emp_ID
			)TERT ON TRT.Transport_Reg_ID = TERT.Transport_Reg_ID 
		) EM ON Ec.Emp_ID = EM.Emp_ID 
		 
		WHERE Emp_Left <>'Y' AND (EM.Transport_Reg_ID IS NULL OR EM.Transport_Status = 0 )
		-- And E.Emp_ID in (select Emp_ID From #Emp_Cons)  Comment By Jaina 28-08-2015
		ORDER BY CASE WHEN IsNumeric(e.Alpha_Emp_Code) = 1 THEN Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
		WHEN IsNumeric(e.Alpha_Emp_Code) = 0 THEN Left(e.Alpha_Emp_Code + Replicate('',21), 20) ELSE e.Alpha_Emp_Code END
	
	END
ELSE IF @Type = 'U'
	BEGIN
		SELECT I_Q.*,E.Alpha_Emp_Code as Emp_Code,CAST(E.Alpha_Emp_Code AS varchar) + ' - '+E.Emp_Full_Name AS 'Emp_Full_Name',Lo.Login_ID,--,E.Emp_Full_Name as Emp_Full_Name_Only
		E.Emp_Full_Name AS 'Emp_Full_Name_only',Emp_superior ,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,
		Date_of_Join,Gender,BM.Comp_Name,BM.Branch_Address,E.Cmp_ID , CM.Cmp_Name,Cm.Cmp_address,E.Emp_Left,
		ISNULL(EM.Route_ID,0) AS 'Route_ID',ISNULL(EM.Pickup_ID,0) AS 'Pickup_ID',ISNULL(EM.Designation_ID,0) AS 'Designation_ID',EM.Transport_Type
		FROM T0080_EMP_MASTER E WITH (NOLOCK)
		INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on E.Cmp_ID = CM.Cmp_ID 
		LEFT OUTER JOIN 
		(
			--T0100_LEFT_EMP EL on E.Emp_Id=EL.Emp_Id inner join        
			SELECT I.Emp_Id,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID 
			FROM T0095_Increment I WITH (NOLOCK)
			INNER JOIN 
			(
				SELECT MAX(I.Increment_ID) AS Increment_ID,I.Emp_ID 
				FROM T0095_Increment I WITH (NOLOCK)
				INNER JOIN 
				(
					SELECT MAX(Increment_effective_Date) AS 'For_Date',Emp_ID 
					FROM T0095_Increment WITH (NOLOCK)
					WHERE Increment_Effective_date <= @To_Date      
					GROUP BY emp_ID 
				) Qry ON I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date 
				GROUP BY I.Emp_ID
			) AS qry_1 ON qry_1.Increment_ID = I.Increment_ID AND qry_1.Emp_ID = I.Emp_ID  
		) I_Q ON E.Emp_ID = I_Q.Emp_ID  
		INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
		LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
		LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
		LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
		INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
		INNER JOIN T0011_Login LO  WITH (NOLOCK) ON LO.Emp_Id = E.Emp_Id 
		INNER JOIN #Emp_Cons as Ec ON Ec.Emp_ID = E.Emp_ID --Added By Jaina 28-08-2015
		INNER JOIN
		(
			SELECT TRT.Transport_Reg_ID,TRT.Emp_ID,TRT.Transport_Status,TRT.Route_ID,TRT.Pickup_ID,TRT.Designation_ID,Transport_Type 
			FROM T0040_Employee_Transport_Registration TRT WITH (NOLOCK)
			INNER JOIN 
			(
				SELECT MAX(ET.Transport_Reg_ID) AS 'Transport_Reg_ID',ET.Emp_ID  
				FROM T0040_Employee_Transport_Registration ET WITH (NOLOCK)
				INNER JOIN 
				(
					SELECT MAX(Effective_Date) AS 'Date',Emp_ID FROM T0040_Employee_Transport_Registration WITH (NOLOCK)
					GROUP BY Emp_ID
				) ETR ON ET.Emp_ID = ETR.Emp_ID 
			
				GROUP BY ET.Emp_ID
			)TERT ON TRT.Transport_Reg_ID = TERT.Transport_Reg_ID 
			WHERE TRT.Transport_Status = 1
		) EM ON Ec.Emp_ID = EM.Emp_ID 
		WHERE Emp_Left <>'Y' AND (EM.Transport_Reg_ID IS NOT NULL OR EM.Transport_Status = 1)
		-- And E.Emp_ID in (select Emp_ID From #Emp_Cons)  Comment By Jaina 28-08-2015
		ORDER BY CASE WHEN IsNumeric(e.Alpha_Emp_Code) = 1 THEN Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
		WHEN IsNumeric(e.Alpha_Emp_Code) = 0 THEN Left(e.Alpha_Emp_Code + Replicate('',21), 20) ELSE e.Alpha_Emp_Code END
	END
ELSE  
	BEGIN  
	
		SELECT	I_Q.* ,E.Alpha_Emp_Code as Emp_Code, cast( E.Alpha_Emp_Code as varchar) + ' - '+E.Emp_Full_Name as Emp_Full_Name,Lo.Login_ID,E.Emp_Full_Name as Emp_Full_Name_only,Emp_superior      
				,E.Emp_Full_Name as Emp_Full_Name_Only,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender      
				,BM.Comp_Name,BM.Branch_Address,CM.Cmp_Name,Cm.Cmp_address,E.Emp_Left      
		FROM	T0080_EMP_MASTER E WITH (NOLOCK)
				INNER JOIN  T0010_company_master Cm WITH (NOLOCK) on E.Cmp_ID = Cm.Cmp_ID 
				LEFT OUTER JOIN (
								--T0100_LEFT_EMP EL on E.Emp_Id=EL.Emp_Id inner join        
								SELECT I.Emp_Id,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID 
								FROM T0095_Increment I  WITH (NOLOCK)
								INNER JOIN 
								(
									SELECT MAX(I.Increment_ID) AS Increment_ID,I.Emp_ID 
									FROM T0095_Increment I WITH (NOLOCK)
									INNER JOIN 
									(
										SELECT MAX(Increment_effective_Date) AS 'For_Date',Emp_ID 
										FROM T0095_Increment WITH (NOLOCK)
										WHERE Increment_Effective_date <= @To_Date      
										GROUP BY emp_ID 
									) Qry ON I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date 
									GROUP BY I.Emp_ID
								) AS qry_1 ON qry_1.Increment_ID = I.Increment_ID AND qry_1.Emp_ID = I.Emp_ID  
							)  I_Q    on E.Emp_ID = I_Q.Emp_ID  
				INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
				LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
				LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
				LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
				INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
				INNER JOIN T0011_Login LO  WITH (NOLOCK) ON LO.Emp_Id = E.Emp_Id 
				INNER JOIN #Emp_Cons as Ec ON Ec.Emp_ID = E.Emp_ID --Added By Jaina 28-08-2015
	WHERE		Emp_Left<>'Y'  --and 
				or getdate()  < Emp_Left_Date
    --    And E.Emp_ID in (select Emp_ID From #Emp_Cons)  Comment By Jaina 28-08-2015
	Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
				When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
					Else e.Alpha_Emp_Code
				End
    --ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500)      
	END
 RETURN
