
 --exec Emp_Details_Form_A_Format1 @Company_Id=119,@From_Date='2020-01-01 00:00:00',@To_Date='2020-01-31 00:00:00',@Branch_ID='',@Cat_ID='',@Grade_ID='',@Type_ID='',@Dept_ID='',@Desig_ID='',@Emp_ID=0,@Constraint='18412#14938',@Report_Type='ESIC'    
     
CREATE PROCEDURE [dbo].[Emp_Details_Form_A_Format1]            
   @Company_Id NUMERIC                
  ,@From_Date  DATETIME            
  ,@To_Date   DATETIME            
  ,@Branch_ID  VarChar             
  ,@Cat_ID   VarChar          
  ,@Grade_ID   VarChar            
  ,@Type_ID   VarChar            
  ,@Dept_ID   VarChar            
  ,@Desig_ID   VarChar            
  ,@Emp_ID   VarChar            
  ,@Constraint VARCHAR(MAX)            
 ,@Report_Type varchar(50)          
-- ,@is_Column  tinyint = 0            
          
AS       
begin      
SET NOCOUNT ON             
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED            
SET ARITHABORT ON          
        
      
  IF @Branch_ID = '0' or @Branch_ID = ''      
  SET @Branch_ID = NULL      
      
 IF @Cat_ID = '0' or  @Cat_ID = ''      
  SET @Cat_ID = NULL      
         
 IF @Type_ID = '0' or @Type_ID = ''      
  SET @Type_ID = NULL      
 IF @Dept_ID = '0' or @Dept_ID = ''      
  SET @Dept_ID = NULL      
 IF @Grade_ID = '0' or @Grade_ID = ''      
  SET @Grade_ID = NULL      
      
       
 IF @Desig_ID = '0' or @Desig_ID = ''      
  SET @Desig_ID = NULL      
       
 IF @Branch_ID= '0' OR @Branch_ID=''  --Added By Jaina 21-09-2015      
  SET @Branch_ID = NULL      
 IF @Constraint= '0' OR @Constraint=''  --Added By Jaina 21-09-2015      
  SET @Constraint = NULL      
       
         
  CREATE table #Emp_Cons       
 (            
  Emp_ID NUMERIC ,           
  Branch_ID NUMERIC,      
  Increment_ID NUMERIC      
 )       
  exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Company_Id,@From_Date,@To_Date,@Branch_Id,@Cat_ID,@Grade_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Constraint,0,0,0,0,0,0,0,0,0,0,0,0  --Check and verify the above parameter      
       
   --added by mansi start 29-7-21          
    IF @Constraint <> ''      
  Begin        
   INSERT INTO #Emp_Cons      
   SELECT cast(data  as numeric),0,0 FROM dbo.Split(@Constraint,'#') T        
  End      
        
 IF @Constraint <> ''            
   BEGIN            
  --   select Emp_code as [Employee/Workmen/Worker_Code], Emp_First_Name AS Name,Emp_Last_Name as Surname,Gender,Father_name as [Father's/Spouse_Name],Date_Of_Birth,Nationality,Qual_Name as Education_Level,          
  --Date_Of_Join,Desig_Name as Designation,'' as [Category_Address_*_(HS/S/SS/US)],TM.Type_Name as [Type_of_Employment],Mobile_No,UAN_No,Pan_No,SIN_No AS ESIC_IP_No,          
  --  case when isnull(EM.Is_Lwf,0) =0 then 'No' else 'Yes' end LWF ,Aadhar_Card_No as Aadhaar,    
  --(select Bank_Ac_No from T0040_BANK_MASTER where Bank_ID= Inc_Qry.Bank_ID)as Bank_Ac_No,    
  --  (select Bank_Name from T0040_BANK_MASTER where Bank_ID= Inc_Qry.Bank_ID)as Bank_Name,    
  -- -- ( '="' + Inc_Qry.Inc_Bank_Ac_No + '"') as Bank_A/c_No,          
  -- --BN.Bank_Name As Bank,          
  --   Inc_Qry.Bank_Branch_Name As [Branch_(IFSC)],          
  --  Present_Street as Present_Address,Street_1 AS [Permanent_Address]--,'' as [Remarks],Street_1 AS [Permanent_Address],'' as [Service Book No],'' as [Specimen Signature / Thumb],'' as ['' as [Specimen Signature/Thumb]]          
  --,Emp_Left_Date as Date_of_Exit,RM.Reason_Name as Reason_of_Exit,Emp_Mark_Of_Identification as Mark_of_Identification,Image_Name as Photo     
  --,isnull(Signature_Image_Name,'') as [Specimen_Signature/Thumb_Impression]    
  --  ,'' as [Remarks]      
  --from T0080_EMP_MASTER EM         
  --Inner join #Emp_Cons EC on EC.Emp_ID=EM.Emp_ID     
  --inner join T0100_LEFT_EMP LE with (NoLock) on LE.Emp_ID=EM.Emp_ID    
  -- inner join T0040_Reason_Master RM with(Nolock) on RM.Res_Id=Le.Left_Reason    
  --INNER JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON EM.Desig_Id = DM.Desig_Id            
  --INNER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON EM.Type_Id = TM.Type_Id            
  -- --LEFT OUTER JOIN T0040_BANK_MASTER BN WITH (NOLOCK) ON Inc_Qry.Bank_Id = BN.Bank_Id           
  --    right outer join T0090_EMP_QUALIFICATION_DETAIL Q1 WITH (NOLOCK) ON EC.Emp_ID = Q1.Emp_ID  AND EM.Cmp_ID=Q1.Cmp_ID            
  --    inner join T0040_QUALIFICATION_MASTER QM WITH (NOLOCK) on QM.Qual_ID=Q1.Qual_ID            
  -- INNER JOIN (SELECT T0095_INCREMENT.Emp_Id,           
  --  Bank_Branch_Name,Bank_ID              
  --    FROM T0095_INCREMENT WITH (NOLOCK)            
  --  INNER JOIN (             
  --     SELECT MAX(I.INCREMENT_ID) AS INCREMENT_ID, I.EMP_ID             
  --   FROM T0095_INCREMENT I WITH (NOLOCK)            
  --   INNER JOIN             
  --   (            
  --     SELECT MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID            
  --     FROM T0095_INCREMENT I3 WITH (NOLOCK)            
  --     WHERE I3.Increment_effective_Date <= @To_Date            
  --     GROUP BY I3.EMP_ID              
  --    ) I3 ON I.Increment_Effective_Date=I3.Increment_Effective_Date AND I.EMP_ID=I3.Emp_ID             
  --     WHERE I.INCREMENT_EFFECTIVE_DATE <= @To_Date and I.Cmp_ID = @Company_Id            
  --     GROUP BY I.emp_ID              
  --     ) Qry ON T0095_INCREMENT.Emp_ID = Qry.Emp_ID AND T0095_INCREMENT.Increment_ID = Qry.Increment_Id               
  --    WHERE cmp_id = @Company_Id            
  --   ) Inc_Qry ON EM.Emp_ID = Inc_Qry.Emp_ID  
  	          select 
			 distinct  EM.Emp_ID,Emp_code as [Employee/Workmen/Worker_Code], Emp_First_Name AS [Name],Emp_Last_Name as Surname,Gender,
			 Father_name as [Father/Spouse_Name],
		
			convert(varchar(50), Date_Of_Birth,103) as Date_Of_Birth ,Nationality,
	   Qual_Name as Education_Level,          
        convert(varchar(50),Date_Of_Join ,103) as Date_Of_Join,
	   Desig_Name as Designation,'' as [Category_Address_*_(HS/S/SS/US)],
	   TM.Type_Name as [Type_of_Employment],
	   Mobile_No,UAN_No,Pan_No,SIN_No AS ESIC_IP_No,          
       case when isnull(EM.Is_Lwf,0) =0 then 'No' else 'Yes' end LWF ,Aadhar_Card_No as Aadhaar,      
	   --(select Bank_Ac_No from T0040_BANK_MASTER where Bank_ID= Inc_Qry.Bank_ID)as Bank_Ac_No,    
	   --(select Bank_Name from T0040_BANK_MASTER where Bank_ID= Inc_Qry.Bank_ID)as Bank_Name,    
       Inc_Qry.Inc_Bank_AC_No as [Bank_A/C],
        BK.Bank_Name As Bank_Name, bk.Bank_Branch_Name, 
	   EM.Ifsc_Code as [IFSC_Code],
       Present_Street as Present_Address,Street_1 AS [Permanent_Address]--,'' as [Remarks],Street_1 AS [Permanent_Address],'' as [Service Book No],'' as [Specimen Signature / Thumb],'' as ['' as [Specimen Signature/Thumb]]          
	   ,'' as Service_Book_No
       ,convert(varchar(50),Emp_Left_Date ,103) as Date_of_Exit,
	   RM.Reason_Name as Reason_of_Exit,
	   --RM.Reason_Name as Reason_of_Exit,
	   Emp_Mark_Of_Identification as Mark_of_Identification,Image_Name as Photo    
		,isnull(Signature_Image_Name,'') as [Specimen_Signature/Thumb_Impression]    
		,'' as [Remarks]     
		into #tempFormA
		FROM T0080_EMP_MASTER EM   
	    Inner join #Emp_Cons EC on EC.Emp_ID=EM.Emp_ID     
		Left outer   join T0100_LEFT_EMP LE with (NoLock) on LE.Emp_ID=EM.Emp_ID    
		Left Outer  join T0040_Reason_Master RM with(Nolock) on RM.Res_Id=Le.Res_Id    
		Left Outer JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON EM.Desig_Id = DM.Desig_Id            
		Left Outer JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON EM.Type_Id = TM.Type_Id            
   	    LEFT Outer JOIN T0090_EMP_QUALIFICATION_DETAIL Q1 WITH (NOLOCK) ON EM.Emp_ID = Q1.Emp_ID  AND EM.Cmp_ID=Q1.Cmp_ID            
		LEFT OUTER JOIN T0040_QUALIFICATION_MASTER QM WITH (NOLOCK) on QM.Qual_ID=Q1.Qual_ID    
		inner JOIN (SELECT T0095_INCREMENT.Emp_Id,Inc_Bank_AC_No ,T0095_INCREMENT.Bank_ID            
					FROM T0095_INCREMENT WITH (NOLOCK)            
					left JOIN (             
						SELECT MAX(I.INCREMENT_ID) AS INCREMENT_ID, I.EMP_ID ,I.Bank_ID
						FROM T0095_INCREMENT I WITH (NOLOCK)          
							   inner JOIN             
							   (            
								 SELECT MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID   ,I3.Bank_ID         
								 FROM T0095_INCREMENT I3 WITH (NOLOCK)            
								 WHERE I3.Increment_effective_Date <= @To_Date     
								 GROUP BY I3.EMP_ID ,I3.Bank_ID          
								) I3 ON I.Increment_Effective_Date=I3.Increment_Effective_Date AND I.EMP_ID=I3.Emp_ID             
								 WHERE I.INCREMENT_EFFECTIVE_DATE <=  @To_Date and I.Cmp_ID = @Company_Id            
								 GROUP BY I.emp_ID , I.Bank_ID            
         ) Qry ON T0095_INCREMENT.Emp_ID = Qry.Emp_ID AND T0095_INCREMENT.Increment_ID = Qry.Increment_Id               
        WHERE cmp_id = @Company_Id            
       ) Inc_Qry ON EM.Emp_ID = Inc_Qry.Emp_ID      
	   Left Outer join  T0040_BANK_MASTER Bk on bk.Bank_ID = Inc_Qry.Bank_ID
	   select (ROW_NUMBER() OVER(ORDER BY [Employee/Workmen/Worker_Code])) AS SrNo,* into #tmp2 from #tempFormA
	   --select distinct * from #tmp2


	 ----  commented by mansi start 
	 --  Select ROW_NUMBER() OVER(ORDER BY [Employee/Workmen/Worker_Code]) AS SrNo , ca.ColName, ca.ColValue 
	 --   into #tmp1
	 --  from #tmp2 d
	 --  CROSS APPLY (
		--			  Values
		--			  ('Sr_No',cast(SrNo as varchar)),
		--			  ('Emp_ID',cast(Emp_ID as varchar)),
		--			  ('Employee/Workmen/Worker_Code' ,cast([Employee/Workmen/Worker_Code]as varchar)),
		--			  ('Name',[Name]),
		--			  ('Surname',Surname),
		--			  ('Gender',Gender),
		--			  ('Father/Spouse_Name',[Father/Spouse_Name]),
		--			  ('Date_Of_Birth',Date_Of_Birth),
		--			  ('Nationality',Nationality),
		--			  ('Education_Level',Education_Level),
		--			  ('Date_Of_Join',Date_Of_Join),
		--			  ('Designation',Designation),
		--			  ('Category_Address_*_(HS/S/SS/US)',[Category_Address_*_(HS/S/SS/US)]),
		--			  ('Type_of_Employment',Type_of_Employment),
		--			  ('Mobile',Mobile_No),
		--			  ('UAN',UAN_No),
		--			  ('PAN',Pan_No),
		--			  ('ESIC_IP',ESIC_IP_No),
		--			  ('LWF',LWF),
		--			  ('AADHAAR',Aadhaar),
		--			  ('Bank_A/c_Number',[Bank_A/C]),
		--			  ('Bank',Bank_Name),
		--			  ('Branch_IFSC',IFSC_Code),
		--			  ('Present_Address',Present_Address),
		--			  ('Permanent_Address',Permanent_Address),
		--			  ('Service_Book_No',Service_Book_No),
		--			  ('Date_of_Exit',Date_of_Exit),
		--			  ('Reason_of_Exit',Reason_of_Exit),
		--			  ('Mark_of_Identification',Mark_of_Identification),
		--			  ('Photo',Photo),
		--			  ('[Specimen_Signature/Thumb_Impression]',[Specimen_Signature/Thumb_Impression]),
		--			  ('Remarks',Remarks)
	 --  ) as CA (ColName, ColValue)
	 -- --commented by mansi end

	   Select --ROW_NUMBER() OVER(ORDER BY [Employee/Workmen/Worker_Code]) AS SrNo ,
	   replace(ca.srno,0,'')as srno,ca.ColName,ca.ColValue,replace(ca.srno1,0,'')as srno1,ca.ColName1,ca.ColValue1
	   --,d.Emp_ID
	    into #tmp1
	   from #tmp2 d
	   CROSS APPLY (
					  Values
					  (1,'Sr_No',cast(SrNo as varchar),'','',''),
					 -- ('Emp_ID',cast(Emp_ID as varchar),'',''),
					  (2,'Employee/Workmen/Worker_Code' ,cast([Employee/Workmen/Worker_Code]as varchar),'','',''),
					  (3,'Name',[Name],23,'Permanent_Address',Permanent_Address),
					  (4,'Surname',Surname,'','',''),
					  (5,'Gender',Gender,'','',''),
					  (6,'Father/Spouse_Name',[Father/Spouse_Name],'','',''),
					  (7,'Date_Of_Birth',Date_Of_Birth,'','',''),
					  (8,'Nationality',Nationality,24,'Permanent_Address',Permanent_Address),
					  (9,'Education_Level',Education_Level,'','',''),
					  (10,'Date_Of_Join',Date_Of_Join,'','',''),
					  (11,'Designation',Designation,25,'Service_Book_No',Service_Book_No),
					  (12,'Category_Address_*_(HS/S/SS/US)',[Category_Address_*_(HS/S/SS/US)],26,'Date_of_Exit',Date_of_Exit),
					  (13,'Type_of_Employment',Type_of_Employment,27,'Reason_of_Exit',Reason_of_Exit),
					  (14,'Mobile',Mobile_No,28,'Mark_of_Identification',Mark_of_Identification),
					  (15,'UAN',UAN_No,29,'Photo',Photo),
					  (16,'PAN',Pan_No,'','',''),
					  (17,'ESIC_IP',ESIC_IP_No,'','',''),
					  (18,'LWF',LWF,'','',''),
					  (19,'AADHAAR',Aadhaar,30,'Specimen_Signature/Thumb_Impression',[Specimen_Signature/Thumb_Impression]),
					  (20,'Bank_A/c_Number',[Bank_A/C],'','',''),
					  (21,'Bank',Bank_Name,31,'Remarks',Remarks),
					  (22,'Branch_IFSC',IFSC_Code,'','',''),
					  ('','','','','','')
					  --,('Present_Address',Present_Address),
					  --('Permanent_Address',Permanent_Address),
					  --('Service_Book_No',Service_Book_No),
					  --('Date_of_Exit',Date_of_Exit),
					  --('Reason_of_Exit',Reason_of_Exit),
					  --('Mark_of_Identification',Mark_of_Identification),
					  --('Photo',Photo),
					  --('[Specimen_Signature/Thumb_Impression]',[Specimen_Signature/Thumb_Impression]),
					  --('Remarks',Remarks)
	   ) as CA (srno,ColName, ColValue,srno1,ColName1,ColValue1)
	  
	  select * from #tmp1-- group by Emp_ID
	--select * into #tf1 from #tmp1 
	--where ColName not in ('Present_Address','Permanent_Address','Service_Book_No','Date_of_Exit','Reason_of_Exit','Mark_of_Identification','Photo','[Specimen_Signature/Thumb_Impression]','Remarks')
	--select SrNo as SrNo1, ColName as ColName1,ColValue as ColValue1 into #tf2 from #tmp1	--where ColName  in ('Present_Address','Permanent_Address','Service_Book_No','Date_of_Exit','Reason_of_Exit','Mark_of_Identification','Photo','[Specimen_Signature/Thumb_Impression]','Remarks')
   
 --  select * from #tf1
 --   select * from #tf2
 --  select * from #tf1 f1  
	-- join  #tf2 f2 on f2.ColName1=f1.ColName
	--group by emp
    
   END        
  ELSE        
	   select ROW_NUMBER() OVER(ORDER BY EM.Emp_Id) AS SrNo,Emp_code as [Employee/Workmen/Worker_Code]
	   , Emp_First_Name AS Name,Emp_Last_Name as Surname,Gender,Father_name as [Father's/Spouse_Name],
	   convert(varchar(50),Date_Of_Birth ,103) as Date_Of_Birth ,Nationality,
	   Qual_Name as Education_Level,          
       convert(varchar(50),Date_Of_Join ,103) as Date_Of_Join,
	   Desig_Name as Designation,'' as [Category_Address_*_(HS/S/SS/US)],
	   TM.Type_Name as [Type_of_Employment],
	   Mobile_No,UAN_No,Pan_No,SIN_No AS ESIC_IP_No,          
       case when isnull(EM.Is_Lwf,0) =0 then 'No' else 'Yes' end LWF 
	   ,Aadhar_Card_No as Aadhaar,      
			--(select Bank_Ac_No from T0040_BANK_MASTER where Bank_ID= Inc_Qry.Bank_ID)as Bank_Ac_No,    
			--(select Bank_Name from T0040_BANK_MASTER where Bank_ID= Inc_Qry.Bank_ID)as Bank_Name,    
        -- ( '="' + Inc_Qry.Inc_Bank_Ac_No + '"') as Bank_A/c_No,          
        --BN.Bank_Name As Bank,          
          Inc_Qry.Inc_Bank_AC_No as [Bank_A/C],
        Bk.Bank_Name as Bank_name,
	   EM.Ifsc_Code as [IFSC_Code],        
       Present_Street as Present_Address,Street_1 AS [Permanent_Address]--,'' as [Remarks],Street_1 AS [Permanent_Address],'' as [Service Book No],'' as [Specimen Signature / Thumb],'' as ['' as [Specimen Signature/Thumb]]          
	   ,'' as Service_Book_No
       ,convert(varchar(50),Emp_Left_Date ,103) as Date_of_Exit,
	   LE.Left_Reason as Reason_of_Exit,
	   Emp_Mark_Of_Identification as Mark_of_Identification,Image_Name as Photo    
		,isnull(Signature_Image_Name,'') as [Specimen_Signature/Thumb_Impression]    
		,'' as [Remarks]      
       from T0080_EMP_MASTER EM         
		left outer join T0100_LEFT_EMP LE with (NoLock) on LE.Emp_ID=EM.Emp_ID    
		left outer join T0040_Reason_Master RM with(Nolock) on RM.Res_Id=Le.Left_Reason    
		Left outer join T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON EM.Desig_Id = DM.Desig_Id            
		Left outer join T0040_TYPE_MASTER TM WITH (NOLOCK) ON EM.Type_Id = TM.Type_Id            
        left join T0090_EMP_QUALIFICATION_DETAIL Q1 WITH (NOLOCK) ON EM.Emp_ID = Q1.Emp_ID  AND EM.Cmp_ID=Q1.Cmp_ID            
        left outer join T0040_QUALIFICATION_MASTER QM WITH (NOLOCK) on QM.Qual_ID=Q1.Qual_ID    
		
		INNER JOIN (
		SELECT T0095_INCREMENT.Emp_Id,   Inc_Bank_AC_No ,T0095_INCREMENT.Bank_ID   
		FROM T0095_INCREMENT WITH (NOLOCK)            
		left JOIN (             
				   SELECT MAX(I.INCREMENT_ID) AS INCREMENT_ID, I.EMP_ID     ,Bank_ID        
				   FROM T0095_INCREMENT I WITH (NOLOCK)          
				   INNER JOIN             
				   (            
					 SELECT MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID            
					 FROM T0095_INCREMENT I3 WITH (NOLOCK)            
					 WHERE I3.Increment_effective_Date <= @To_Date     
					 GROUP BY I3.EMP_ID ,i3.Bank_ID             
					) I3 ON I.Increment_Effective_Date=I3.Increment_Effective_Date AND I.EMP_ID=I3.Emp_ID             
					 WHERE I.INCREMENT_EFFECTIVE_DATE <=  @To_Date and I.Cmp_ID = @Company_Id            
					 GROUP BY I.emp_ID ,Bank_ID             
         ) Qry ON T0095_INCREMENT.Emp_ID = Qry.Emp_ID AND T0095_INCREMENT.Increment_ID = Qry.Increment_Id      
		
        WHERE cmp_id = @Company_Id            
       ) Inc_Qry ON EM.Emp_ID = Inc_Qry.Emp_ID      
	    Left Outer join  T0040_BANK_MASTER Bk on bk.Bank_ID = Inc_Qry.Bank_ID
 --END            
    end      
   -- RETURN
