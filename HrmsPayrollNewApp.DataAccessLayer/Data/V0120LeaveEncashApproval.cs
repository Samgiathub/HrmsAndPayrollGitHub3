using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0120LeaveEncashApproval
{
    public decimal LvEncashAprId { get; set; }

    public decimal? LvEncashAppId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal LeaveId { get; set; }

    public string LvEncashAprCode { get; set; } = null!;

    public DateTime LvEncashAprDate { get; set; }

    public decimal? LvEncashAprDays { get; set; }

    public string LvEncashAprStatus { get; set; } = null!;

    public string LvEncashAprComments { get; set; } = null!;

    public decimal LoginId { get; set; }

    public DateTime SystemDate { get; set; }

    public string LvEncashAppStatus { get; set; } = null!;

    public DateTime LvEncashAppDate { get; set; }

    public string LvEncashAppCode { get; set; } = null!;

    public string LeaveName { get; set; } = null!;

    public string? EmpFullName { get; set; }

    public string? OtherEmail { get; set; }

    public decimal GrdId { get; set; }

    public byte? EffInSalary { get; set; }

    public byte? IsFnf { get; set; }

    public DateTime? UptoDate { get; set; }

    public string? LeaveCompOffDates { get; set; }

    public string? DefaultShortName { get; set; }

    public decimal LeaveEncashAmount { get; set; }

    public decimal BranchId { get; set; }
}
