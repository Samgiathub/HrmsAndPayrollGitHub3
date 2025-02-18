using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100LeaveEncashApplicationBackupDivyaraj18012024
{
    public decimal LvEncashAppId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LeaveId { get; set; }

    public decimal EmpId { get; set; }

    public string LvEncashAppCode { get; set; } = null!;

    public DateTime LvEncashAppDate { get; set; }

    public decimal? LvEncashAppDays { get; set; }

    public string LvEncashAppStatus { get; set; } = null!;

    public string LvEncashAppComments { get; set; } = null!;

    public decimal LoginId { get; set; }

    public DateTime SystemDate { get; set; }

    public string LeaveName { get; set; } = null!;

    public string? EmpFullName { get; set; }

    public decimal? BasicSalary { get; set; }

    public decimal GrdId { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public decimal BranchId { get; set; }

    public decimal EmpCode { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? LeaveCompOffDates { get; set; }

    public decimal LeaveCount { get; set; }

    public string? DefaultShortName { get; set; }

    public decimal? MaxAccumulateBalance { get; set; }

    public int ApplyHourly { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal LeaveEncashAmount { get; set; }
}
