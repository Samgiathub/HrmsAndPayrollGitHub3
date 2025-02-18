using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0135LevaeCancelation
{
    public string? BranchName { get; set; }

    public decimal BranchId { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public string? EmpFullName { get; set; }

    public string LeaveName { get; set; } = null!;

    public decimal LvCanTranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LeaveId { get; set; }

    public decimal LeavePeriod { get; set; }

    public DateTime ForDate { get; set; }

    public decimal LvCanDay { get; set; }

    public decimal LvCanStatus { get; set; }

    public string LvCanComments { get; set; } = null!;

    public DateTime? OutTime { get; set; }

    public DateTime? InTime { get; set; }

    public decimal LeaveApprovalId { get; set; }

    public decimal EmpCode { get; set; }

    public string? DefaultShortName { get; set; }
}
