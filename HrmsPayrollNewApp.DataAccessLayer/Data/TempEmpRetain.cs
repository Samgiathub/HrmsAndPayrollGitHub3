using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TempEmpRetain
{
    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? GrdId { get; set; }

    public DateTime? JoinDate { get; set; }

    public DateTime? StartDate { get; set; }

    public DateTime? EndDate { get; set; }

    public decimal? Period { get; set; }

    public decimal? BasicSalary { get; set; }

    public string? Mode { get; set; }

    public decimal? Amount { get; set; }

    public decimal? NetAmount { get; set; }

    public decimal? AdId { get; set; }

    public decimal? OtherAmount { get; set; }

    public int? TranId { get; set; }

    public int? EmpRetCount { get; set; }

    public int? MonLockTransId { get; set; }
}
