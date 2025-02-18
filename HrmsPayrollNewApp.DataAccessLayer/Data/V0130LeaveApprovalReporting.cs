using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0130LeaveApprovalReporting
{
    public decimal? LeaveApplicationId { get; set; }

    public decimal LeaveApprovalId { get; set; }

    public string? EmpFullName { get; set; }

    public string LeaveName { get; set; } = null!;

    public DateTime FromDate { get; set; }

    public DateTime ToDate { get; set; }

    public decimal LeavePeriod { get; set; }

    public string LeaveAssignAs { get; set; } = null!;

    public string? LeaveReason { get; set; }

    public string? LeaveApprover { get; set; }

    public string CmpName { get; set; } = null!;

    public string CmpAddress { get; set; } = null!;

    public string CmpPhone { get; set; } = null!;

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public string ApplicationCode { get; set; } = null!;

    public string? EmpLeft { get; set; }
}
