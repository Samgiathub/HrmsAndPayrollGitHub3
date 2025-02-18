using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0120LeaveEncashApprovalDetail
{
    public decimal LvEncashAprId { get; set; }

    public decimal? LvEncashAppId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LeaveId { get; set; }

    public decimal EmpId { get; set; }

    public string LvEncashAprCode { get; set; } = null!;

    public DateTime LvEncashAprDate { get; set; }

    public decimal? LvEncashAprDays { get; set; }

    public string LvEncashAprStatus { get; set; } = null!;

    public string LvEncashAprComments { get; set; } = null!;

    public decimal LoginId { get; set; }

    public DateTime SystemDate { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public string? EmpFullName { get; set; }

    public string LeaveName { get; set; } = null!;

    public decimal EmpCode { get; set; }

    public decimal BranchId { get; set; }

    public byte? EffInSalary { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? LeaveCompOffDates { get; set; }

    public int ApplyHourly { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }
}
