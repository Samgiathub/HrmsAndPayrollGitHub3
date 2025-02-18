using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0080GetEmpDataJoinLeft
{
    public int RowId { get; set; }

    public string? CmpCode { get; set; }

    public decimal? EmpId { get; set; }

    public string? Firstname { get; set; }

    public string? Lastname { get; set; }

    public string? Emailaddress { get; set; }

    public string? Designation { get; set; }

    public string? Branchname { get; set; }

    public decimal? Employeecode { get; set; }

    public string? Buisness { get; set; }

    public string? AssocitedphoneNumber { get; set; }

    public string? Manageruser { get; set; }

    public string? Deactivation { get; set; }

    public DateTime? Leftdate { get; set; }

    public string? Status { get; set; }

    public DateTime? CreatedDate { get; set; }

    public DateTime? ModifyDate { get; set; }
}
