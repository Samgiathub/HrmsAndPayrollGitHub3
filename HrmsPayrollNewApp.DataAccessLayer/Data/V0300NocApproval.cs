using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0300NocApproval
{
    public string? EmpFullName { get; set; }

    public string? DeptName { get; set; }

    public decimal CmpId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal EmpId { get; set; }

    public string? NocStatus { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? AEmpId { get; set; }

    public string? Remarks { get; set; }

    public decimal? ApprovalId { get; set; }

    public string? EmpName { get; set; }

    public decimal? UpdatedBy { get; set; }

    public decimal? CenterId { get; set; }

    public string? CenterName { get; set; }

    public decimal? ExitId { get; set; }

    public decimal? BranchId { get; set; }
}
