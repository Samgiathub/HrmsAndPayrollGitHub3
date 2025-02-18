using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0110LtaMedicalApplication
{
    public decimal CmpId { get; set; }

    public decimal LmAppId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime? AppDate { get; set; }

    public string? AppCode { get; set; }

    public decimal? AppAmount { get; set; }

    public string? AppComments { get; set; }

    public string? FileName1 { get; set; }

    public string? FileName { get; set; }

    public DateTime? SystemDate { get; set; }

    public int AppStatus { get; set; }

    public DateTime? LeaveFromDate { get; set; }

    public DateTime? LeaveToDate { get; set; }

    public int? NoOfDays { get; set; }

    public int? TypeId { get; set; }

    public string? TypeName { get; set; }

    public decimal? EmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string? Status { get; set; }

    public string? EmpFirstName { get; set; }

    public decimal? LmAprId { get; set; }

    public decimal? BranchId { get; set; }
}
