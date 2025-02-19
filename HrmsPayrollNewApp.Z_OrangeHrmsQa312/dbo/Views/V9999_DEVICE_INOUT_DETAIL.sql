




CREATE VIEW [dbo].[V9999_DEVICE_INOUT_DETAIL]    
    
as    
    
 select distinct * from 
 (
 select  a.* from T9999_DEVICE_INOUT_DETAIL as a  WITH (NOLOCK)   
 left outer join (    
 select e.Emp_ID,    
 --case when Enroll_No = 0 then Alpha_Emp_Code else Enroll_No end  as Enroll_No,          
 Enroll_No,          
 case when isnull(In_Time,'01-01-1900')  > isnull(Out_Time,'01-01-1900') then            
 In_Time           
 else          
 Out_Time           
 end as For_Date ,    
 In_Time,    
 Out_time  ,    
 Duration
 From T0080_Emp_Master e WITH (NOLOCK)  inner join           
 (         
 select eir.Emp_ID ,(In_Time) as In_Time,(Out_time) as Out_Time ,eir.Duration          
 from T0150_Emp_Inout_Record eir     
 where ISNULL(In_Time,'')='' or ISNULL(Out_time,'') =''     
 ) q on e.emp_ID = q.emp_ID          
 where isnull(emp_Left,'N') <> 'Y'    
 ) as b    
 on a.Enroll_No=b.Enroll_No    
 and cast(cast(a.IO_DateTime as varchar(11)) as datetime ) = cast( cast(b.For_Date as varchar(11))  as datetime)  
 --and cast(a.IO_DateTime as datetime ) = cast( b.For_Date as datetime)  

 
 union all      
    
 select a.*  from T9999_DEVICE_INOUT_DETAIL as a  WITH (NOLOCK)       
 left outer join (    
 select e.Emp_ID,    
 --case when Enroll_No = 0 then Alpha_Emp_Code else Enroll_No end  as Enroll_No,          
 Enroll_No,          
 case when isnull(In_Time,'01-01-1900')  > isnull(Out_Time,'01-01-1900') then            
 In_Time           
 else          
 Out_Time           
 end as For_Date         
 From T0080_Emp_Master e WITH (NOLOCK)  Inner join           
 (         
 select eir.Emp_ID ,max(In_Time) as In_Time,max(Out_time) as Out_Time          
 from T0150_Emp_Inout_Record eir WITH (NOLOCK)  group by emp_ID         
 ) q on e.emp_ID = q.emp_ID          
 where isnull(emp_Left,'N') <> 'Y'    
 ) as b    
 on a.Enroll_No=b.Enroll_No    
 --and a.IO_DateTime >= b.For_Date  
 and (a.IO_DateTime >= dateadd(day,-60,b.For_Date))
  
 ) as Data




